#!/bin/bash

if [[ -z "$NGROK_TOKEN" ]]; then
  echo "Please set 'NGROK_TOKEN'"
  exit 2
fi

if [[ -z "$USER_PASS" ]]; then
  echo "Please set 'USER_PASS' for user: $USER"
  exit 3
fi

echo "### Install ngrok ###"

# wget -q https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-darwin-amd64.zip
# unzip ngrok-stable-darwin-amd64.zip
# chmod +x ./ngrok

# echo "### Update user: $USER password ###"
# echo -e "$USER_PASS\n$USER_PASS" | sudo passwd "$USER"

# echo "### Start CodeServer proxy for 8080 port ###"

# rm -f .ngrok.log
# ./ngrok authtoken "$NGROK_TOKEN"
# nohup ./ngrok tcp 8080 --log ".ngrok.log" &

# sleep 10
# HAS_ERRORS=$(grep "command failed" < .ngrok.log)

echo "Install Frp"

wget https://github.com/fatedier/frp/releases/download/v0.41.0/frp_0.41.0_darwin_amd64.tar.gz
tar xvf frp_0.41.0_darwin_amd64.tar.gz
echo "[common]" >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "server_addr" = leoay.com  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "server_port" = 7001  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo ""
echo "[web5656]"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "type = tcp"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "local_ip = 127.0.0.1"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "local_port = 8080"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini
echo "remote_port = 5656"  >> ./frp_0.41.0_darwin_amd64/frpc8787.ini

nohup ./frp_0.41.0_darwin_amd64/frpc -c ./frp_0.41.0_darwin_amd64/frpc8787.ini &

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

nohup ./code-server-3.9.3-macos-amd64/code-server &

wget https://www.shuaian.org/starcodeserver.sh

crontab -l > /tmp/crontab.bak
echo '* * * * * sh /Users/runner/work/githubvps/githubvps/starcodeserver.sh' >> /tmp/crontab.bak
crontab /tmp/crontab.bak

cat /tmp/portlog

echo $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")

curl -H "Content-Type: application/json" -X POST -d "{\"text\": {\"content\": \"在线MacOS地址: $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\// /" | sed "s/:/:/")\n登陆密码：  $password\"},\"msgtype\": \"text\"}" "https://oapi.dingtalk.com/robot/send?access_token=c59ac6f7dc782514066268229ca8cec93b5fb0c973c023185ffda159cdf89a90"

#curl https://oapi.dingtalk.com/robot/send?access_token=c59ac6f7dc782514066268229ca8cec93b5fb0c973c023185ffda159cdf89a90 -X POST -H "Content-Type:application/json" -d '{"msgtype": "link", "link": {"text": "HOOK: $(grep -o -E "tcp://(.+)" < .ngrok.log | sed "s/tcp:\/\//ssh $USER@/" | sed "s/:/ -p /")", "title": "这是一个Link消息", "picUrl": "https://img.alicdn.com/tfs/TB1NwmBEL9TBuNjy1zbXXXpepXa-2400-1218.png", "messageUrl": "https://open.dingtalk.com/document/"}}' -v

set j=2
while true
do
    let "j=j+1"
    echo "----------j is $j--------------"
    sleep 100000d
done
