#!/data/data/com.termux/files/usr/bin/bash
set -e
GREEN='\e[32m'; RESET='\e[0m'

echo -e "${GREEN}[*] Verificando termux-clipboard-get...${RESET}"
if ! command -v termux-clipboard-get &> /dev/null; then
    echo -e "${GREEN}[*] Baixando termux-api .deb oficial...${RESET}"
    curl -Lo termux-api.deb https://github.com/termux/termux-api/releases/download/v0.49/termux-api_v0.49_aarch64.deb
    dpkg -i termux-api.deb
    apt-get install -f -y
fi

echo -e "${GREEN}[*] Criando Tasker XML auto-importável...${RESET}"
cat > /sdcard/grok_auto.tasker.xml << 'XML'
<TaskerData sr="" dvi="1" tv="6.1.3">
<Profile sr="prof0" ve="2">
<cdate>1712345678900</cdate>
<edate>1712345678900</edate>
<flags>8</flags>
<id>1</id>
<mid>0</mid>
<nme>Grok Auto</nme>
<Event sr="con0" ve="2">
<code>155</code>
<pri>0</pri>
<Str sr="arg0" ve="3">android.intent.action.CLIPBOARD_CHANGED</Str>
<Str sr="arg1" ve="3"/>
<Int sr="arg2" val="0"/>
<Str sr="arg3" ve="3"/>
<Str sr="arg4" ve="3"/>
<Str sr="arg5" ve="3">termux</Str>
</Event>
</Profile>
<Task sr="task0">
<cdate>1712345678900</cdate>
<edate>1712345678900</edate>
<id>1</id>
<nme>Grok Execute</nme>
<pri>100</pri>
<Action sr="act0" ve="7">
<code>123</code>
<Str sr="arg0" ve="3">am startservice --user 0 -n com.termux/com.termux.app.TermuxService -a execute -e com.termux.execute.EXTRA_EXECUTE_PATH /data/data/com.termux/files/usr/bin/bash -e com.termux.execute.EXTRA_ARGUMENTS '/data/data/com.termux/files/usr/bin/termux-clipboard-get > /sdcard/grok_last.txt && /data/data/com.termux/files/usr/bin/python /data/data/com.termux/files/home/grok-executor/termux/ge.py'</Str>
<Str sr="arg1" ve="3"/>
<Int sr="arg2" val="0"/>
<Str sr="arg3" ve="3"/>
<Str sr="arg4" ve="3"/>
<Str sr="arg5" ve="3"/>
</Action>
</Task>
</TaskerData>
XML

echo -e "${GREEN}[✔] Auto-fix concluído!${RESET}"
echo "Importe o arquivo /sdcard/grok_auto.tasker.xml no Tasker:"
echo "Tasker → menu → Import → From Storage → grok_auto.tasker.xml"
