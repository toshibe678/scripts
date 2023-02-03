#!/bin/bash

# 共通処理読み込み
. "`dirname $0`/common.sh"

FROM="monitor-disk"
TO_ALERT1="root"
TO_ALERT9="root"

#****************************************************
# Main
#****************************************************
ALERT1_MAXDIRSPACE=94
ALERT9_MAXDIRSPACE=95

# Check Function
Check_DF () {
    AWK_CMD1="${AWK} -F\" \" '\$6 == \"$1\" { print \$5 }'"
    AWK_CMD2="${AWK} -F\"%\" '{ print \$1 }'"
    USE_DISK_SPACE=`${DF} -Pk | eval ${AWK_CMD1} | eval ${AWK_CMD2}`
    if [[ "${ALERT1_MAXDIRSPACE}" -lt "${USE_DISK_SPACE}" && "${ALERT9_MAXDIRSPACE}" -gt "${USE_DISK_SPACE}" ]]
    then
        errmsg="warning: ${1} Capacity is over ${ALERT1_MAXDIRSPACE}% at `hostname` now ${USE_DISK_SPACE}%"
        send_mail ${TO_ALERT1} ${FROM} "Low disk space warning" "$errmsg"
    elif [[ "${ALERT9_MAXDIRSPACE}" -le "${USE_DISK_SPACE}" ]]
    then
        errmsg="alert: ${1} Capacity is over ${ALERT9_MAXDIRSPACE}% at `hostname` now ${USE_DISK_SPACE}%"
        send_mail ${TO_ALERT9} $FROM "Low disk space alert!!" "$errmsg"
    fi
}
AWKCMD="${AWK} -F\" \" '\$6 == \"$1\" { print \$6 }'"
DISKS=`${DF} -Pk | ${AWK} -F" " '{ print $6 }' | ${GREP} /`
for DISK in ${DISKS}
do
    Check_DF "${DISK}"
done
exit 0
