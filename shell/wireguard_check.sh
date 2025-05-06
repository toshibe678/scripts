#!/bin/bash

# 前回の状態を保存するファイル
PREV_STATE_FILE="/tmp/wireguard_prev_state"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-YOUR_WEBHOOK_URL}"

# 現在の状態を取得
CURRENT_STATE=$(sudo wg show all dump)

# 接続している端末のPublicKeyとIPアドレスを抽出する関数
extract_connected_peers() {
  local input_data=$1
  echo "$input_data" | awk '$4 != "(none)" {print $2 " " $5}' | sort
}

# 前回の状態を読み込む
if [ -f "$PREV_STATE_FILE" ]; then
  PREV_STATE=$(cat "$PREV_STATE_FILE")
else
  PREV_STATE=""
fi

# 前回と今回の接続されているピアを抽出
PREV_CONNECTED=$(extract_connected_peers "$PREV_STATE")
CURRENT_CONNECTED=$(extract_connected_peers "$CURRENT_STATE")

# 新規接続の検出（今回あって前回なかった）
NEW_CONNECTIONS=$(comm -13 <(echo "$PREV_CONNECTED") <(echo "$CURRENT_CONNECTED"))

# 切断の検出（前回あって今回ない）
DISCONNECTIONS=$(comm -23 <(echo "$PREV_CONNECTED") <(echo "$CURRENT_CONNECTED"))

# 接続情報を読みやすくフォーマットする関数
format_peer_info() {
  local peers_data=$1
  local result=""
  
  while read -r line; do
    if [ -n "$line" ]; then
      local pubkey=$(echo "$line" | awk '{print $1}')
      local ip=$(echo "$line" | awk '{print $2}' | sed 's|/32||')
      result="${result}• ${ip} (${pubkey:0:8}...)\n"
    fi
  done <<< "$peers_data"
  
  echo -e "$result"
}

# Slackに通知を送信
if [ -n "$NEW_CONNECTIONS" ]; then
  formatted_new=$(format_peer_info "$NEW_CONNECTIONS")
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"🟢 *WireGuard新規接続*:\n$formatted_new\"}" "$SLACK_WEBHOOK_URL"
fi

if [ -n "$DISCONNECTIONS" ]; then
  formatted_disc=$(format_peer_info "$DISCONNECTIONS")
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"🔴 *WireGuard切断*:\n$formatted_disc\"}" "$SLACK_WEBHOOK_URL"
fi

# 現在の状態を保存
echo "$CURRENT_STATE" > "$PREV_STATE_FILE"
