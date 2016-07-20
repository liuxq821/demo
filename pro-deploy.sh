#!/bin/bash

#Date/Time
CDATE=$(date "+%Y-%m-%d")
CTIME=$(date "+%Y-%m-%d-%H-%M")

#Shell
CODE_DIR="/deploy/code/demo"
CONFIG_DIR="/deploy/config"
TMP_DIR="/deploy/tmp"
TAR_DIR="/deploy/tar"


usage(){
    echo $"Usage: $0 [ deploy | rollback-list | rollback-pro ver ]"
}

git_pro(){
  echo "begin git pull"
  cd "$CODE_DIR" && git pull
  ARI_VERL=$(git show|grep commit|cut -d ' ' -f2)
  ARI_VER=$(echo ${ARI_VERL:0:6})
  cp -r "$CODE_DIR" "$TMP_DIR"
}

config_pro(){
  echo "add pro config"
  /bin/cp "$CONFIG_DIR"/* "$TMP_DIR"/demo
  TAR_VER="$ARI_VER-$CTIME"
  cd "$TMP_DIR" && mv demo pro_demo_"$TAR_VER"
}

tar_pro(){
  echo "tar pro"
  cd $TMP_DIR && tar czf pro_demo_"$TAR_VER".tar.gz pro_demo_"$TAR_VER"
  echo "tar end pro_demo_"$TAR_VER".tar.gz"
}

scp_pro(){
  echo "begin scp"
  /bin/cp $TMP_DIR/pro_demo_"$TAR_VER".tar.gz  /tmp
}

deploy_pro(){
  echo "begin deploy"
  cd /tmp && tar zxf pro_demo_"$TAR_VER".tar.gz
  rm -f /var/www/html/demo
  ln -s /tmp/pro_demo_"$TAR_VER" /var/www/html/demo
}

test_pro(){
  echo "test bing"
  # curl | grep "200"
  echo "test ok"
}
# 注意 测试要在部署完一台服务后便进行，如果有问题，此脚本便退出。不在对其他节点进行部署。
#      如果测试成功，再进行其他节点部署

rollback_list(){
  ls -l /tmp/*.tar.gz | awk '{print $9}'| awk -F/ '{print $3}'|awk -F. '{print $1}'
}

rollback_pro(){
  rm -r /var/www/html/demo
  ln -s /tmp/$1 /var/www/html/demo
}


main(){
  case $1 in
    deploy)
      git_pro;
      config_pro;
      tar_pro;
      scp_pro;
      deploy_pro;
      test_pro;
      ;;
    rollback-list)
       rollback_list;
      ;;
    rollback-pro)
       rollback_pro $2;
      ;;
       *)
      usage;
    esac
}

main $1 $2
