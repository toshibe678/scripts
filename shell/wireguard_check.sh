#!/bin/bash

# 前回の状態を保存するファイル
PREV_STATE_FILE="/tmp/wireguard_prev_state"

# 現在の状態を取得
CURRENT_STATE=$(sudo wg show all dump)

# 前回の状態を読み込む
if [ -f "$PREV_STATE_FILE" ]; then
  PREV_STATE=$(cat "$PREV_STATE_FILE")
else
  PREV_STATE=""
fi

# 新規接続と切断を検出
NEW_CONNECTIONS=$(diff <(echo "$PREV_STATE") <(echo "$CURRENT_STATE") | grep "^>" | cut -d' ' -f3)
DISCONNECTIONS=$(diff <(echo "$PREV_STATE") <(echo "$CURRENT_STATE") | grep "^<" | cut -d' ' -f3)

# Slackに通知を送信
if [ ! -z "$NEW_CONNECTIONS" ]; then
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"新規接続: $NEW_CONNECTIONS\"}" "$SLACK_WEBHOOK_URL"
fi

if [ ! -z "$DISCONNECTIONS" ]; then
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"切断: $DISCONNECTIONS\"}" "$SLACK_WEBHOOK_URL"
fi

# 現在の状態を保存
echo "$CURRENT_STATE" > "$PREV_STATE_FILE"
