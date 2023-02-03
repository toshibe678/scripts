#!/bin/bash -x
# 1台目にmasterにしたクラスター機で実行するスクリプト
# kubernetesの証明書を同じクラスターに所属する他のマスターコントロールプレーンに転送する

# 共通処理読み込み
. "`dirname $0`/common.sh"

check_root_user

if [ $# -lt 1 ]; then
    echo "Error: invalid number of arguments"
    echo ""
    echo usage: $0 '[to_control_plane1 to_control_plane2]'
    exit
fi

NODE=${1}

for host in ${NODE}; do
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mkdir -p /etc/kubernetes/pki/etcd"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mkdir -p /tmp/pki/etcd; sudo chmod 777 -R /tmp/pki"
  scp -i /home/toshi/.ssh/id_rsa /etc/kubernetes/pki/ca.crt toshi@${host}:/tmp/pki/ca.crt
  scp -i /home/toshi/.ssh/id_rsa /etc/kubernetes/pki/ca.key toshi@${host}:/tmp/pki/ca.key
  scp -i /home/toshi/.ssh/id_rsa /etc/kubernetes/pki/sa.key toshi@${host}:/tmp/pki/sa.key
  scp -i /home/toshi/.ssh/id_rsa /etc/kubernetes/pki/sa.pub toshi@${host}:/tmp/pki/sa.pub
  scp -i /home/toshi/.ssh/id_rsa /etc/kubernetes/pki/front-proxy-ca.crt toshi@${host}:/tmp/pki/front-proxy-ca.crt
  scp -i /home/toshi/.ssh/id_rsa /etc/kubernetes/pki/front-proxy-ca.key toshi@${host}:/tmp/pki/front-proxy-ca.key
  scp -i /home/toshi/.ssh/id_rsa /etc/kubernetes/pki/etcd/ca.crt toshi@${host}:/tmp/pki/etcd/ca.crt
  scp -i /home/toshi/.ssh/id_rsa /etc/kubernetes/pki/etcd/ca.key toshi@${host}:/tmp/pki/etcd/ca.key
  scp -i /home/toshi/.ssh/id_rsa /etc/kubernetes/admin.conf toshi@${host}:/tmp/pki/admin.conf
  #
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mv /tmp/pki/ca.crt /etc/kubernetes/pki/ca.crt"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mv /tmp/pki/ca.key /etc/kubernetes/pki/ca.key"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mv /tmp/pki/sa.key /etc/kubernetes/pki/sa.key"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mv /tmp/pki/sa.pub /etc/kubernetes/pki/sa.pub"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mv /tmp/pki/front-proxy-ca.crt /etc/kubernetes/pki/front-proxy-ca.crt"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mv /tmp/pki/front-proxy-ca.key /etc/kubernetes/pki/front-proxy-ca.key"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mv /tmp/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/ca.crt"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mv /tmp/pki/etcd/ca.key /etc/kubernetes/pki/etcd/ca.key"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mv /tmp/pki/admin.conf /etc/kubernetes/admin.conf"
  # kubectlが特定のユーザーで使用できるようにする
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "mkdir -p /home/toshi/.kube"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "\cp -f -i /etc/kubernetes/admin.conf /home/toshi/.kube/config"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "chown toshi:toshi /home/toshi/.kube/config"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo mkdir -p /root/.kube"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo \cp -f -i /etc/kubernetes/admin.conf /root/.kube/config"
  ssh -i /home/toshi/.ssh/id_rsa -t toshi@${host} "sudo chown root:root /root/.kube/config"
done
