#!/bin/bash
# Slack通知 ON/OFF 切替スクリプト
#
# 使い方:
#   slack-notify-toggle.sh         # トグル（ON↔OFF）
#   slack-notify-toggle.sh on      # ON に設定
#   slack-notify-toggle.sh off     # OFF に設定
#   slack-notify-toggle.sh status  # 現在の状態を表示

ENV_FILE="$HOME/.config/ai-agents/profiles/default.env"

if [ ! -f "$ENV_FILE" ]; then
  echo "エラー: $ENV_FILE が見つかりません"
  echo "セットアップ手順は README.md を参照してください"
  exit 1
fi

# 現在の状態を取得
CURRENT=$(grep '^SLACK_NOTIFY_ENABLED=' "$ENV_FILE" | cut -d'=' -f2)
WEBHOOK=$(grep '^SLACK_WEBHOOK_URL=' "$ENV_FILE" | cut -d'=' -f2)

# 認証情報チェック
warn_credentials() {
  if [ -z "$WEBHOOK" ]; then
    echo "⚠️  警告: Slack Webhook URL が未設定です"
    echo "   $ENV_FILE に以下を設定してください:"
    echo "   - SLACK_WEBHOOK_URL"
    echo "   設定方法: https://api.slack.com/apps → Incoming Webhooks"
  fi
}

# 値を書き換え
set_enabled() {
  local NEW_VALUE=$1
  if grep -q '^SLACK_NOTIFY_ENABLED=' "$ENV_FILE"; then
    sed -i '' "s/^SLACK_NOTIFY_ENABLED=.*/SLACK_NOTIFY_ENABLED=${NEW_VALUE}/" "$ENV_FILE"
  else
    echo "SLACK_NOTIFY_ENABLED=${NEW_VALUE}" >> "$ENV_FILE"
  fi
}

# 状態表示
show_status() {
  local VAL=$(grep '^SLACK_NOTIFY_ENABLED=' "$ENV_FILE" | cut -d'=' -f2)
  if [ "$VAL" = "true" ]; then
    echo "Slack通知: ON ✅"
  else
    echo "Slack通知: OFF ❌"
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
