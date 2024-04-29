#!/usr/bin/env bash

# https://atmarkit.itmedia.co.jp/ait/articles/1805/10/news023.html
# パイプやサブシェルで実行したコマンドが1つでもエラーになったら直ちにシェルを終了する
set -o errexit
# パラメーター展開中に、設定していない変数があったらエラーとする（特殊パラメーターである「@」と「*」は除く）
set -o nounset
# パイプラインの返り値を、最後のエラー終了値（0以外で終了した際の値、全ての実行が成功した場合は0）にする
set -o pipefail

if [ "$#" -ne 6 ]; then
  echo "usage: $0 <db_host> <db_port> <db_name> <username> <password> <command>"
  exit 1
fi

db_host=$1
db_port=$2
db_name=$3
db_username=$4

if [ -e "$5" ]; then
  db_password=`cat $5`
else
  db_password=$5
fi

command=$6

echo "Waiting for MySQL to start..."
until mysql -h $db_host -P $db_port -u $db_username -p$db_password -e "show databases;" &> /dev/null; do
  >&2 echo "MySQL is unavailable - sleeping"
  sleep 1
done
echo "MySQL is up - executing command"

migrate -path ./history -database mysql://$db_username:$db_password@tcp\($db_host:$db_port\)/$db_name $command
