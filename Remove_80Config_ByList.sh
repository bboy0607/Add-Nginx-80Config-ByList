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

#讀取設定檔
source config.txt

#列出要刪除的檔案名稱
echo "--------------------------------------"
echo "讀取清單中"
echo "--------------------------------------"

while IFS="" read -r server_name || [ -n "$server_name" ]
do
  echo "- ${nginx_conf_dir}/${server_name}.conf"
done < $list_file

#使用者問答輸入
read -p '以上設定將會被刪除，請問是否繼續執行?(Y/N): ' answer

case $answer in
  [yY])
    ;;
  *)
    echo -e "\n\e[1;31m停止執行\e[0m"
    exit
    ;;
esac

echo "--------------------------------------"
echo "開始刪除"
echo "--------------------------------------"

#讀取清單加入Nginx設定檔目錄
while IFS="" read -r server_name || [ -n "$server_name" ]
do
  echo "- 刪除 ${nginx_conf_dir}/${server_name}.conf"
  rm -rf ${nginx_conf_dir}/${server_name}.conf
done < $list_file

echo -e "\n\e[1;31m完成! 請重新啟用Nginx服務\e[0m"
