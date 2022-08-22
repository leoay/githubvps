#!/bin/bash

echo ----------------`who am I`-----------------------

echo `PWD`

if [[ -z "$NGROK_TOKEN" ]]; then
  echo "Please set 'NGROK_TOKEN'"
  exit 2
fi

if [[ -z "$USER_PASS" ]]; then
  echo "Please set 'USER_PASS' for user: $USER"
  exit 3
fi

echo "Install Frp"

wget https://github.com/fatedier/frp/releases/download/v0.41.0/frp_0.41.0_darwin_amd64.tar.gz
tar xvf frp_0.41.0_darwin_amd64.tar.gz



echo "[common]" >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "server_addr" = $REHOST >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "server_port" = $RESEPORT  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo ""
echo "[web5656]"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "type = tcp"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "local_ip = 127.0.0.1"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "local_port = 8080"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "remote_port = 5656"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini

echo ""
echo "[ssh1]"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "type = tcp"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "local_ip = 127.0.0.1"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "local_port = 22"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "remote_port = 4020"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini

./frp_0.41.0_darwin_amd64/frpc -c ./frp_0.41.0_darwin_amd64/frpc8787.ini

echo "=========process:" $(ps -ef | grep frpc)

mkdir -p ~/.config/code-server

chmod +x ./timehash

password=$(./timehash)

echo "密码： ==================: "$(./timehash)

echo bind-addr: 0.0.0.0:8080 >> ~/.config/code-server/config.yaml
echo auth: password >> ~/.config/code-server/config.yaml
echo password: $password >> ~/.config/code-server/config.yaml
echo cert: false >> ~/.config/code-server/config.yaml

wget https://github.com/coder/code-server/releases/download/v3.9.3/code-server-3.9.3-macos-amd64.tar.gz
tar xvf code-server-3.9.3-macos-amd64.tar.gz

cat .ngrok.log

if [[ -z "$HAS_ERRORS" ]]; then
  echo ""
  echo "=========================================="
  echo "To connect: $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")"
  echo "=========================================="

  echo "To connect: $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")" > /tmp/portlog

else
  echo "$HAS_ERRORS"
  exit 4
fi

echo ">>>>>>>>>>>>当前目录："$PWD

crontab -l > /tmp/crontab.bak
echo '* * * * * sh /Users/runner/work/githubvps/githubvps/code.sh' >> /tmp/crontab.bak
crontab /tmp/crontab.bak

cat /tmp/portlog

echo $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")

curl -H "Content-Type: application/json" -X POST -d "{\"text\": {\"content\": \"在线MacOS地址: $REHOST:5656\n登陆密码：  $password\"},\"msgtype\": \"text\"}" "$DINGBOTURL"

./timer/timer