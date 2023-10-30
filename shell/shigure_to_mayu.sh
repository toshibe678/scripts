#!/bin/bash
# このシェルはto側で実行される

# 共通処理読み込み
. "`dirname $0`/common.sh"

# 容量全体がこのサイズ以下だったら警告(マウントできてない場合)
MOUNT_DISK_SIZE=1000000

# rsync setting
USER="toshi"
HOST="172.28.177.100"
DOC_ROOT_SRC="/share/share/"
DOC_ROOT_DST="/share/share/"
RSYNC_EXCLUDE=" \
        --exclude .zfs \
"
RSYNC="${RSYNC_BIN} -auhzl --delete"

PARTITION_SIZE=`${DF} -m ${DOC_ROOT_DST} | ${AWK} 'NR==2' | ${AWK} '{print $4}'`

# まずDFでパスの値が取れたかのチェック
if $(echo ${PARTITION_SIZE} | grep [0-9]* > /dev/null 2>&1); then
    if [[ ${PARTITION_SIZE} -gt ${MOUNT_DISK_SIZE} ]]; then
        send_mail root root@${HOSTNAME} "Backup start ${HOSTNAME}" "Backup start ${NOW_DATE}"
        set -x
        ${RSYNC} ${RSYNC_EXCLUDE} -e "ssh -i /home/toshi/.ssh/id_rsa" ${USER}@${HOST}:${DOC_ROOT_SRC} ${DOC_ROOT_DST}
        set +x
    else
        # 容量が設定以下。マウントできてない
        send_mail root root@${HOSTNAME} "Backup error Disc not mounted!!" "no Disc"
    fi
else
    # df: /hoge: そのようなファイルやディレクトリはありません の場合のエラー
    send_mail root root@${HOSTNAME} "Backup error Directory not!! ${DOC_ROOT_DST} " "no Directory ${DOC_ROOT_DST}"
fi

END_DATE=`date +"%Y/%m/%d %H:%M:%S"`
send_mail root root@${HOSTNAME} "Backup End ${HOSTNAME}" "Backup End ${END_DATE}"
