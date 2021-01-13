#!/bin/bash
#--------------------------------------------------------------------
# 變數
#--------------------------------------------------------------------
#設定檔名稱
config_name="config.txt"

#--------------------------------------------------------------------
# 程式碼
#--------------------------------------------------------------------
#擷取父程式目錄位置並轉跳
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

cd "$parent_path"

source $config_name

#使用者問答輸入
read -p '請輸入後端主機IP: ' server_ip

echo "--------------------------------------"
echo "開始設定"
echo "--------------------------------------"

#讀取清單加入Nginx設定檔目錄
while IFS="" read -r server_name || [ -n "$server_name" ]
do
  echo "- 設定 ${nginx_conf_dir}/${server_name}.conf"
  cat << EOF > ${nginx_conf_dir}/${server_name}.conf
#-----------------------------------------------------------
##Port 80
server {
    listen  80;
    server_name  $server_name;
    location / {
        proxy_set_header Host $server_name;
        proxy_set_header remote_addr \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_pass http://$server_ip;
        proxy_redirect default;
   }
}
EOF
done < $list_file

echo -e "\n\e[1;31m完成! 請重新啟用Nginx服務\e[0m"
