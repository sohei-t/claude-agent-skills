#!/bin/bash
# LINE Messaging API Push通知スクリプト
# Claude Code の Stop フックから呼び出され、タスク完了時に LINE に通知を送信する
#
# 前提条件:
#   - LINE Messaging API チャネルの作成
#   - チャネルアクセストークン（長期）の取得
#   - 自分の LINE ユーザーID の取得
#
# 環境変数ファイル ($HOME/.config/ai-agents/profiles/default.env) に以下を設定:
#   LINE_NOTIFY_ENABLED=true
#   LINE_CHANNEL_ACCESS_TOKEN=<your-channel-access-token>
#   LINE_USER_ID=<your-line-user-id>
#
# Claude Code settings.json でのフック設定例:
#   "hooks": {
#     "Stop": [
#       { "type": "command", "command": "/path/to/line-notify.sh" }
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

# stdin から JSON を読み取り cwd を抽出
CWD=$(python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('cwd',''))" 2>/dev/null || echo "")

# タイムスタンプ
TIME=$(date '+%H:%M:%S')

# フォルダ名のみ抽出（プッシュ通知に収まるよう短縮）
DIR_NAME=$(basename "$CWD" 2>/dev/null)

# メッセージ組み立て
if [ -n "$DIR_NAME" ]; then
  MSG="✅ Claude Code 完了\n📂 ${DIR_NAME}\n⏰ ${TIME}"
else
  MSG="✅ Claude Code 完了\n⏰ ${TIME}"
fi

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
