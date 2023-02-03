#!/bin/bash
# 引数にnic名(eth0のような)をつける

# 共通処理読み込み
. "`dirname $0`/common.sh"

if test "$1" = ""; then
    echo usage: $0 '[nic_name]'
    exit
fi

# arpキャッシュクリア
for i in `${IP} addr show dev ${1} | ${GREP} 'inet ' | ${AWK} '{print $2}' | ${AWK} -F/ '{print $1}'`
do
    /sbin/arping -c1 -A -q -I ${1} ${i}
done
