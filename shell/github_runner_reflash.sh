#!/bin/bash

# 共通処理読み込み
. "`dirname $0`/common.sh"

rm -fr /opt/actions-runner/
rm -f /etc/systemd/system/actions.runner.*
