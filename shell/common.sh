#!/bin/bash
HOST_NAME=`hostname`
PROG_NAME=`basename $0`
SSH_OPTS="-A -t -o StrictHostKeyChecking=yes"
SSH="$(which ssh) ${SSH_OPTS}"
SCP=/usr/bin/scp
SSH_AGENT=/usr/bin/ssh-agent

SEND_MAIL="$(which sendmail)"

LS="$(which ls)"
AWK="$(which awk)"
DF="$(which df)"
PS="$(which ps)"
WC="$(which wc)"
GREP="$(which grep)"
RSYNC_BIN="$(which rsync)"
DATE="$(which date)"
WHOAMI="$(which whoami)"
SYSTEMCTL="$(which systemctl)"
IP="$(which ip)"

# ランダム文字列生成
RAND16=`cat /dev/urandom | tr -dc '[:alnum:]' | tr -d '1Il0O' | head -c 16`
RAND20=`cat /dev/urandom | tr -dc '[:alnum:]' | tr -d '1Il0O' | head -c 20`

# 日付系
NOW_DATE=`date +"%Y/%m/%d %H:%M:%S"`
readonly year=$($DATE +%Y)
readonly month=$($DATE +%m)
readonly day=$($DATE +%Y%m%d)
readonly time=$($DATE +%Y%m%d%H%M%S)

reset_color="\033[0m"
black="\033[30m"
red="\033[31m"
green="\033[32m"
yellow="\033[33m"
blue="\033[34m"
purple="\033[35m"
cyan="\033[36m"

OK="${green}OK${reset_color}"
NG="${red}NG${reset_color}"

RESULT=0

echo_result() {
  if test ${RESULT} -lt 1; then
    echo -e "[${OK}] $1"
  else
    echo -e "[${NG}] $2"
  fi
}

echo_result_and_exit() {
  if test ${RESULT} -lt 1; then
    echo -e "[${OK}] $1"
    exit 0
  else
    echo -e "[${NG}] $2"
    exit 1
  fi
}

echo_and_exec() {
  echo $1
  eval $1
  RESULT_TMP=$?
  if test ${RESULT_TMP} -ne 0; then
    RESULT=`expr ${RESULT} + 1`
  fi
  if test ${RESULT_TMP} -lt 1; then
    echo -e "[${OK}] $1"
  else
    echo -e "[${NG}] $1"
  fi
  return ${RESULT_TMP}
}

echo_return_code_check() {
  if test ${?} -ne 0; then
    echo -e "[${OK}] $1"
  else
    echo -e "[${NG}] $2"
    echo "It suspends processing"
    exit 1
  fi
}

update_remote_repos() {
  host=$1
  dir=$2
  echo "--------------------------------------"
  echo "update $host:$dir"
  echo_and_exec "${SSH} $host \"cd $dir && git pull\""
}

sync_remote_repos() {
  host=$1
  dir=$2
  echo "--------------------------------------"
  echo "update $host:$dir"
  echo_and_exec "${SSH} $host \"cd $dir && bash -c 'git fetch -p && git reset --hard \\\$(git rev-parse --abbrev-ref \\\$(git rev-parse --abbrev-ref HEAD)@{upstream})'\""
  ${SSH} $host "cd $dir && git branch -lvv"
}

#****************************************************
# SendMail
#****************************************************
send_mail() {
  DATE=`date '+%Y/%m/%d %H:%M:%S'`
  if [[ "${4}" != "" ]]; then
    BODY=${4}
  else
    BODY=${3}
  fi
(
echo "To: $1"
echo "From: $2"
echo "Subject:$3"
echo ""
echo "[$DATE] "
echo "${BODY}") | ${SEND_MAIL} -t
}

check_root_user() {
  MYUSER=`${WHOAMI}`
  if [[ "${MYUSER}" != "root" ]]; then
    echo "exec user is only root."
    exit 1
  fi
}

check_toshi_user() {
  MYUSER=`${WHOAMI}`
  if [[ "${MYUSER}" != "toshi" ]]; then
    echo "exec user is only toshi."
    exit 1
  fi
}
