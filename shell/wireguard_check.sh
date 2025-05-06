#!/bin/bash

# ログファイル
LOG_FILE="/tmp/wireguard_check.log"
exec >> "$LOG_FILE" 2>&1

# 実行時間記録
echo "$(date): スクリプト実行開始"

# 前回の状態を保存するファイル
PREV_STATE_FILE="/tmp/wireguard_prev_state"
SLACK_WEBHOOK_URL="${SLACK_WEBHOOK_URL:-https://hooks.slack.com/services/your/actual/webhook}"

echo "SLACK_WEBHOOK_URL: ${SLACK_WEBHOOK_URL}"

# 現在の状態を取得
CURRENT_STATE=$(sudo wg show all dump)
if [ -z "$CURRENT_STATE" ]; then
  echo "エラー: wg show コマンドの出力が空です"
  exit 1
fi

# 接続している端末のPublicKeyとIPアドレスを抽出する関数
extract_connected_peers() {
  local input_data=$1
  echo "$input_data" | awk '$4 != "(none)" {print $2 " " $5}' | sort
}

# 前回の状態を読み込む
if [ -f "$PREV_STATE_FILE" ]; then
  PREV_STATE=$(cat "$PREV_STATE_FILE")
  echo "前回の保存状態を読み込みました"
else
  PREV_STATE=""
  echo "前回の保存状態はありません"
fi

# 前回と今回の接続されているピアを抽出
PREV_CONNECTED=$(extract_connected_peers "$PREV_STATE")
CURRENT_CONNECTED=$(extract_connected_peers "$CURRENT_STATE")

echo "前回の接続ピア:"
echo "$PREV_CONNECTED"
echo "現在の接続ピア:"
echo "$CURRENT_CONNECTED"

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
  echo "新規接続を検出:"
  echo "$NEW_CONNECTIONS"
  formatted_new=$(format_peer_info "$NEW_CONNECTIONS")
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"🟢 *WireGuard新規接続*:\n$formatted_new\"}" "$SLACK_WEBHOOK_URL" -v
fi

if [ -n "$DISCONNECTIONS" ]; then
  echo "切断を検出:"
  echo "$DISCONNECTIONS"
  formatted_disc=$(format_peer_info "$DISCONNECTIONS")
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"🔴 *WireGuard切断*:\n$formatted_disc\"}" "$SLACK_WEBHOOK_URL" -v
fi

# 現在の状態を保存
echo "$CURRENT_STATE" > "$PREV_STATE_FILE"
chmod 666 "$PREV_STATE_FILE"
echo "現在の状態を保存しました"
