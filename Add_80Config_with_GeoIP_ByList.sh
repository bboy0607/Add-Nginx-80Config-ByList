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
	if (\$allowed_country = no) {
	return 403;
	}
        proxy_set_header Host $server_name;
        proxy_set_header remote_addr \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_pass http://$server_ip;
        proxy_redirect default;
   }

    error_page 400 /ErrorPage/HTTP400.html;
    error_page 401 /ErrorPage/HTTP401.html;
    error_page 402 /ErrorPage/HTTP402.html;
    error_page 403 /ErrorPage/HTTP403.html;
    error_page 404 /ErrorPage/HTTP404.html;
    error_page 500 /ErrorPage/HTTP500.html;
    error_page 501 /ErrorPage/HTTP501.html;
    error_page 502 /ErrorPage/HTTP502.html;
    error_page 503 /ErrorPage/HTTP503.html;
    
    location /ErrorPage/ {
    alias /var/www/ErrorPage/;
    internal;
    }
}
EOF
done < $list_file

echo -e "\n\e[1;31m完成! 請重新啟用Nginx服務\e[0m"
