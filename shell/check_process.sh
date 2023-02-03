#!/bin/bash

# 共通処理読み込み
. "`dirname $0`/common.sh"

TARGET_PROCESS=$1
RESTERT_NAME=$2

RET=`${PS} -ef | ${GREP} ${TARGET_PROCESS} | ${GREP} -v grep | ${GREP} -v ${PROG_NAME} | ${WC} -l`
if [[ "$RET" == "0" ]]; then
    `${SYSTEMCTL} restart ${RESTERT_NAME}`
    sleep 5
    RET2=`/bin/ps -ef | /bin/grep ${TARGET_PROCESS} | /bin/grep -v grep | /bin/grep -v ${PROG_NAME} | /usr/bin/wc -l`
    if [ "$RET2" == "0" ]; then
        send_mail root root@${HOSTNAME} "${TARGET_PROCESS} process restart NG!!!"
    else
        send_mail root root@${HOSTNAME} "${TARGET_PROCESS} process restart OK."
    fi
    exit 0
fi
exit 0
