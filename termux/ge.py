#!/data/data/com.termux/files/usr/bin/python3
import os, re, subprocess, sys, json, time

RAW_FILE   = "/sdcard/grok_last.txt"
WORK_SH    = os.environ["HOME"]+"/.ge_work.sh"
LOG_FILE   = os.environ["HOME"]+"/ge_real.log"
BLACKLIST  = ["rm -rf /", "mkfs", "dd if=", "curl.*sh", "wget.*sh"]
TIMEOUT_S  = 5

def log(msg):
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(f"{time.asctime()}  {msg}\n")

def blacklisted(cmd):
    return any(re.search(p, cmd) for p in BLACKLIST)

def extract_bash_blocks(text):
    # pega tudo entre ```bash ... ```
    pattern = r"```(?:bash|shell)?\n(.*?)```"
    return [m.group(1).strip() for m in re.finditer(pattern, text, re.DOTALL)]

def notify_confirm(script):
    payload = {
        "title": "Executar comando?",
        "text": script[:200]+"..." if len(script) > 200 else script,
        "button1": "Sim",
        "button2": "Não",
        "timeout": TIMEOUT_S
    }
    proc = subprocess.run(["termux-notification", "-c", json.dumps(payload)], capture_output=True, text=True)
    # botão "Sim" (1) ou timeout (1)
    return "1" in proc.stdout or proc.returncode == 0

def run_script(path):
    log("=== início execução ===")
    proc = subprocess.run(["bash", path], capture_output=True, text=True)
    log("stdout:\n" + proc.stdout)
    if proc.stderr:
        log("stderr:\n" + proc.stderr)
    log("exit code: "+str(proc.returncode))
    return proc.returncode == 0, proc.stderr

def push_clipboard(text):
    subprocess.run(["termux-clipboard-set"], input=text, text=True)

def reopen_grok():
    subprocess.run(["am", "start", "--user", "0", "-n", "com.twitter.android/.MainActivity"], stdout=subprocess.DEVNULL)

def main():
    if not os.path.exists(RAW_FILE):
        print("❌ Arquivo", RAW_FILE, "não encontrado.")
        sys.exit(1)

    with open(RAW_FILE, encoding="utf-8") as f:
        raw_text = f.read()

    blocks = extract_bash_blocks(raw_text)
    if not blocks:
        print("Nenhum bloco bash encontrado.")
        sys.exit(0)

    full_script = "\n".join(blocks)
    if blacklisted(full_script):
        print("Comando bloqueado pela blacklist.")
        sys.exit(1)

    if not notify_confirm(full_script):
        print("Cancelado pelo usuário.")
        sys.exit(0)

    with open(WORK_SH, "w", encoding="utf-8") as f:
        f.write("#!/bin/bash\nset -e\n" + full_script + "\n")
    os.chmod(WORK_SH, 0o755)

    success, stderr = run_script(WORK_SH)
    if success:
        subprocess.run(["termux-toast", "✅ Sucesso"], stdout=subprocess.DEVNULL)
    else:
        push_clipboard(stderr[-500:])  # últimas 500 chars
        reopen_grok()
        subprocess.run(["termux-toast", "🔄 Erro enviado ao Grok"], stdout=subprocess.DEVNULL)

    os.remove(RAW_FILE)

if __name__ == "__main__":
    main()
