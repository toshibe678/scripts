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
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"⚠️ *WireGuardエラー*: wg show コマンドの出力が空です\"}" "$SLACK_WEBHOOK_URL"
  exit 1
fi

# サーバー行を除外し、接続されているピア情報を抽出する関数
extract_peers_status() {
  local input_data=$1
  # 先頭行（サーバー情報）をスキップして、2行目以降を処理
  echo "$input_data" | sed '1d' | awk '{print $2 " " $4 " " $5}' | sort
}

# 接続しているピアを抽出する関数（エンドポイントが(none)以外のもの）
extract_connected_peers() {
  local input_data=$1
  echo "$input_data" | sed '1d' | awk '$4 != "(none)" {print $2 " " $4 " " $5}' | sort
}

# 前回の状態を読み込む
if [ -f "$PREV_STATE_FILE" ]; then
  PREV_STATE=$(cat "$PREV_STATE_FILE")
  echo "前回の保存状態を読み込みました"
else
  PREV_STATE=""
  echo "前回の保存状態はありません"
fi

# 前回と今回のピア状態を抽出
PREV_PEERS=$(extract_peers_status "$PREV_STATE")
CURRENT_PEERS=$(extract_peers_status "$CURRENT_STATE")

echo "前回のピア状態:"
echo "$PREV_PEERS"
echo "現在のピア状態:"
echo "$CURRENT_PEERS"

# 新規接続の検出（前回は(none)だったが今回は(none)以外になったもの）
NEW_CONNECTIONS=""
while read -r current_line; do
  if [ -n "$current_line" ]; then
    pubkey=$(echo "$current_line" | awk '{print $1}')
    endpoint=$(echo "$current_line" | awk '{print $2}')
    ip=$(echo "$current_line" | awk '{print $3}' | sed 's|/32||')
    
    # (none)でないエンドポイントを持つピアのみを処理
    if [ "$endpoint" != "(none)" ]; then
      # 前回の状態で同じpubkeyを持つエンドポイントを検索
      prev_endpoint=$(echo "$PREV_PEERS" | grep "^$pubkey" | awk '{print $2}')
      
      # 前回が(none)だったか、存在しなかった場合は新規接続と判断
      if [ "$prev_endpoint" = "(none)" ] || [ -z "$prev_endpoint" ]; then
        NEW_CONNECTIONS="${NEW_CONNECTIONS}${pubkey} ${endpoint} ${ip}\n"
      fi
    fi
  fi
done <<< "$CURRENT_PEERS"

# 切断の検出（前回は(none)以外だったが今回は(none)になったもの）
DISCONNECTIONS=""
while read -r prev_line; do
  if [ -n "$prev_line" ]; then
    pubkey=$(echo "$prev_line" | awk '{print $1}')
    prev_endpoint=$(echo "$prev_line" | awk '{print $2}')
    ip=$(echo "$prev_line" | awk '{print $3}' | sed 's|/32||')
    
    # (none)でないエンドポイントを持つピアのみを処理
    if [ "$prev_endpoint" != "(none)" ]; then
      # 現在の状態で同じpubkeyを持つエンドポイントを検索
      current_endpoint=$(echo "$CURRENT_PEERS" | grep "^$pubkey" | awk '{print $2}')
      
      # 現在が(none)になった場合は切断と判断
      if [ "$current_endpoint" = "(none)" ] || [ -z "$current_endpoint" ]; then
        DISCONNECTIONS="${DISCONNECTIONS}${pubkey} ${prev_endpoint} ${ip}\n"
      fi
    fi
  fi
done <<< "$PREV_PEERS"

# 接続情報を読みやすくフォーマットする関数
format_peer_info() {
  local peers_data=$1
  local result=""
  
  echo "$peers_data" | while read -r line; do
    if [ -n "$line" ]; then
      local pubkey=$(echo "$line" | awk '{print $1}')
      local endpoint=$(echo "$line" | awk '{print $2}')
      local ip=$(echo "$line" | awk '{print $3}')
      result="${result}• ${ip} (${pubkey:0:8}...) from ${endpoint}\n"
    fi
  done
  
  echo -e "$result"
}

# Slackに通知を送信
if [ -n "$NEW_CONNECTIONS" ]; then
  echo "新規接続を検出:"
  echo -e "$NEW_CONNECTIONS"
  formatted_new=$(format_peer_info "$NEW_CONNECTIONS")
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"🟢 *WireGuard新規接続*:\n$formatted_new\"}" "$SLACK_WEBHOOK_URL" -v
fi

if [ -n "$DISCONNECTIONS" ]; then
  echo "切断を検出:"
  echo -e "$DISCONNECTIONS"
  formatted_disc=$(format_peer_info "$DISCONNECTIONS")
  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"🔴 *WireGuard切断*:\n$formatted_disc\"}" "$SLACK_WEBHOOK_URL" -v
fi

# 現在の状態を保存
echo "$CURRENT_STATE" > "$PREV_STATE_FILE"
chmod 666 "$PREV_STATE_FILE"
echo "現在の状態を保存しました"
echo "$(date): スクリプト実行完了"

