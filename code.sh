#/bin/bash
echo "==========start frp  vscode============"

ps -fe|grep frpc_vscode_8681.ini |grep -v grep

if [ $? -ne 0 ]
then
echo "start process....."
nohup ./frpc -c ./frpc_vscode_8681.ini >/dev/null 2>&1 &
else
echo "program already runing....."
fi

echo "==========end start frp vscode==========="

echo "==========start frp  vscode============"

ps -fe|grep code-server |grep -v grep

if [ $? -ne 0 ]
then
echo "start process....."
nohup /Applications/codeserver/code-server/code-server &
else
echo "code-server already runing....."
fi

echo "==========end start code-server==========="