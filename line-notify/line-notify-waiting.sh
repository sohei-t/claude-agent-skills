#!/bin/bash
# LINE 入力待ち通知スクリプト
# Claude Code の Notification フックから呼び出され、承認待ち・入力待ち時に LINE に通知を送信する
#
# 対応する notification_type:
#   - permission_prompt : ツール実行の承認待ち（yes/no）
#   - idle_prompt       : ユーザー入力待ち
#
# Claude Code settings.json でのフック設定例:
#   "hooks": {
#     "Notification": [
#       {
#         "matcher": "permission_prompt",
#         "hooks": [
#           { "type": "command", "command": "/path/to/line-notify-waiting.sh" }
#         ]
#       }
#     ]
#   }

ENV_FILE="$HOME/.config/ai-agents/profiles/default.env"

# 環境変数読み込み
if [ -f "$ENV_FILE" ]; then
  LINE_NOTIFY_ENABLED=$(grep '^LINE_NOTIFY_ENABLED=' "$ENV_FILE" | cut -d'=' -f2)
  LINE_CHANNEL_ACCESS_TOKEN=$(grep '^LINE_CHANNEL_ACCESS_TOKEN=' "$ENV_FILE" | cut -d'=' -f2)
  LINE_USER_ID=$(grep '^LINE_USER_ID=' "$ENV_FILE" | cut -d'=' -f2)
fi

# 無効なら即終了
[ "$LINE_NOTIFY_ENABLED" = "true" ] || exit 0

# トークン未設定なら即終了
[ -n "$LINE_CHANNEL_ACCESS_TOKEN" ] || exit 0
[ -n "$LINE_USER_ID" ] || exit 0

# stdin から JSON を読み取り
INPUT=$(cat)
CWD=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "")
NOTIFICATION_TYPE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('notification_type',''))" 2>/dev/null || echo "")
MESSAGE=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message',''))" 2>/dev/null || echo "")

# フォルダ名のみ抽出
DIR_NAME=$(basename "$CWD" 2>/dev/null)

# タイムスタンプ
TIME=$(date '+%H:%M:%S')

# メッセージ組み立て
MSG="⏸️ 入力待ち: ${DIR_NAME}\n💬 ${MESSAGE}\n⏰ ${TIME}"

# LINE Messaging API で Push Message 送信（バックグラウンド）
(curl -s -X POST https://api.line.me/v2/bot/message/push \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${LINE_CHANNEL_ACCESS_TOKEN}" \
  -d "{
    \"to\": \"${LINE_USER_ID}\",
    \"messages\": [
      {
        \"type\": \"text\",
        \"text\": \"${MSG}\"
      }
    ]
  }" > /dev/null 2>&1) &

exit 0
