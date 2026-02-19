#!/bin/bash
# Slack タスク完了通知スクリプト
# Claude Code の Stop フックから呼び出され、タスク完了時に Slack に通知を送信する
#
# 環境変数ファイル ($HOME/.config/ai-agents/profiles/default.env) に以下を設定:
#   SLACK_NOTIFY_ENABLED=true
#   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXX/YYY/ZZZ
#
# Claude Code settings.json でのフック設定例:
#   "hooks": {
#     "Stop": [
#       { "type": "command", "command": "/path/to/slack-notify.sh" }
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

# stdin から JSON を読み取り cwd を抽出
CWD=$(python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "")

# フォルダ名のみ抽出
DIR_NAME=$(basename "$CWD" 2>/dev/null)

# タイムスタンプ
TIME=$(date '+%H:%M:%S')

# メッセージ組み立て
if [ -n "$DIR_NAME" ]; then
  TEXT=":white_check_mark: *Claude Code 完了*\n:file_folder: ${DIR_NAME}\n:clock3: ${TIME}"
else
  TEXT=":white_check_mark: *Claude Code 完了*\n:clock3: ${TIME}"
fi

# Slack Incoming Webhook で送信（バックグラウンド）
(curl -s -X POST "$SLACK_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "{\"text\": \"${TEXT}\"}" > /dev/null 2>&1) &

exit 0
