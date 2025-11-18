#!/data/data/com.termux/files/usr/bin/bash
set -e
GREEN='\e[32m'; RESET='\e[0m'

echo -e "${GREEN}[*] Atualizando repositórios…${RESET}"
pkg update -y -q

echo -e "${GREEN}[*] Instalando dependências…${RESET}"
pkg install -y -q curl git python termux-api jq

echo -e "${GREEN}[*] Clonando repositório…${RESET}"
cd $HOME
[ -d grok-executor ] && rm -rf grok-executor
git clone https://github.com/Wanuk26/grok-executor.git

echo -e "${GREEN}[*] Criando atalho ‘ge’ …${RESET}"
echo 'alias ge="python $HOME/grok-executor/termux/ge.py"' >> .bashrc

echo -e "${GREEN}[✔] Instalação concluída!${RESET}"
echo "Digite:    ge    (ou reinicie o Termux)"
