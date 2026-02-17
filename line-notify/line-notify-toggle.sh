#!/bin/bash
# LINE通知 ON/OFF 切替スクリプト
# LINE通知の有効・無効をワンコマンドで切り替える
#
# 使い方:
#   line-notify-toggle.sh         # トグル（ON↔OFF）
#   line-notify-toggle.sh on      # ON に設定
#   line-notify-toggle.sh off     # OFF に設定
#   line-notify-toggle.sh status  # 現在の状態を表示
#
# 環境変数ファイル ($HOME/.config/ai-agents/profiles/default.env) の
# LINE_NOTIFY_ENABLED を書き換えて切り替えを行う

ENV_FILE="$HOME/.config/ai-agents/profiles/default.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "エラー: $ENV_FILE が見つかりません"
  echo "セットアップ手順は README.md を参照してください"
  exit 1
fi

# 現在の状態を取得
CURRENT=$(grep '^LINE_NOTIFY_ENABLED=' "$ENV_FILE" | cut -d'=' -f2)
TOKEN=$(grep '^LINE_CHANNEL_ACCESS_TOKEN=' "$ENV_FILE" | cut -d'=' -f2)
USER_ID=$(grep '^LINE_USER_ID=' "$ENV_FILE" | cut -d'=' -f2)

# 認証情報チェック
warn_credentials() {
  if [ -z "$TOKEN" ] || [ -z "$USER_ID" ]; then
    echo "⚠️  警告: LINE認証情報が未設定です"
    echo "   $ENV_FILE に以下を設定してください:"
    [ -z "$TOKEN" ] && echo "   - LINE_CHANNEL_ACCESS_TOKEN"
    [ -z "$USER_ID" ] && echo "   - LINE_USER_ID"
    echo "   設定方法: https://developers.line.biz/console/"
  fi
}

# 値を書き換え
set_enabled() {
  local NEW_VALUE=$1
  if grep -q '^LINE_NOTIFY_ENABLED=' "$ENV_FILE"; then
    sed -i '' "s/^LINE_NOTIFY_ENABLED=.*/LINE_NOTIFY_ENABLED=${NEW_VALUE}/" "$ENV_FILE"
  else
    echo "LINE_NOTIFY_ENABLED=${NEW_VALUE}" >> "$ENV_FILE"
  fi
}

# 状態表示
show_status() {
  local VAL=$(grep '^LINE_NOTIFY_ENABLED=' "$ENV_FILE" | cut -d'=' -f2)
  if [ "$VAL" = "true" ]; then
    echo "LINE通知: ON ✅"
  else
    echo "LINE通知: OFF ❌"
  fi
}

case "${1:-toggle}" in
  on)
    set_enabled "true"
    show_status
    warn_credentials
    ;;
  off)
    set_enabled "false"
    show_status
    ;;
  status)
    show_status
    warn_credentials
    ;;
  toggle|"")
    if [ "$CURRENT" = "true" ]; then
      set_enabled "false"
    else
      set_enabled "true"
    fi
    show_status
    warn_credentials
    ;;
  *)
    echo "使い方: $0 [on|off|status]"
    exit 1
    ;;
esac
