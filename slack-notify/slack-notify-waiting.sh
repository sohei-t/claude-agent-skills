#!/bin/bash
# Slack 入力待ち通知スクリプト
# Claude Code の Notification フックから呼び出され、承認待ち時に Slack に通知を送信する
#
# Claude Code settings.json でのフック設定例:
#   "hooks": {
#     "Notification": [
#       {
#         "matcher": "permission_prompt",
#         "hooks": [
#           { "type": "command", "command": "/path/to/slack-notify-waiting.sh" }
#         ]
#       }
#     ]
#   }

ENV_FILE="$HOME/.config/ai-agents/profiles/default.env"

# 環境変数読み込み
if [ -f "$ENV_FILE" ]; then
  SLACK_NOTIFY_ENABLED=$(grep '^SLACK_NOTIFY_ENABLED=' "$ENV_FILE" | cut -d'=' -f2)
  SLACK_WEBHOOK_URL=$(grep '^SLACK_WEBHOOK_URL=' "$ENV_FILE" | cut -d'=' -f2)
fi

# 無効なら即終了
[ "$SLACK_NOTIFY_ENABLED" = "true" ] || exit 0

# Webhook URL 未設定なら即終了
[ -n "$SLACK_WEBHOOK_URL" ] || exit 0

# stdin から JSON を読み取り
INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "")
MESSAGE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message',''))" 2>/dev/null || echo "")

# フォルダ名のみ抽出
DIR_NAME=$(basename "$CWD" 2>/dev/null)

# タイムスタンプ
TIME=$(date '+%H:%M:%S')

# メッセージ組み立て
TEXT=":double_vertical_bar: *入力待ち: ${DIR_NAME}*\n:speech_balloon: ${MESSAGE}\n:clock3: ${TIME}"

# Slack Incoming Webhook で送信（バックグラウンド）
(curl -s -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{\"text\": \"${TEXT}\"}" > /dev/null 2>&1) &

exit 0
