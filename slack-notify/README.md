# Slack 通知スキル for Claude Code

Claude Code のタスク完了時・承認待ち時に Slack へ通知を送信するフックスキルです。Incoming Webhooks を使用するため、**月間送信上限なし**で利用できます。

## 機能

- **タスク完了通知**: Stop フックでタスク完了を検知し Slack に通知
- **入力待ち通知**: Notification フックで承認待ち（yes/no）を検知し Slack に通知
- 作業フォルダ名とタイムスタンプを通知メッセージに含む
- **ワンコマンドで ON/OFF 切替**が可能
- バックグラウンド送信のため Claude Code の動作をブロックしない

## 通知イメージ

**タスク完了時:**
```
✅ Claude Code 完了
📁 my-project
🕒 14:32:05
```

**承認待ち時:**
```
⏸ 入力待ち: my-project
💬 Bash を実行してよいですか？
🕒 14:32:05
```

## 前提条件

- [Slack ワークスペース](https://slack.com/)のアカウント
- Slack App の作成と Incoming Webhooks の有効化
- `python3`、`curl` がインストール済み

## セットアップ

### 1. Slack App を作成し Webhook URL を取得

1. [Slack API](https://api.slack.com/apps) にアクセス
2. 「Create New App」→「From scratch」を選択
3. App 名（例: `Claude Code Notify`）とワークスペースを選択して作成
4. 左メニュー「Incoming Webhooks」→ ON に切替
5. 「Add New Webhook to Workspace」→ 通知先チャンネルを選択して許可
6. 生成された Webhook URL をコピー

### 2. スクリプトを配置

```bash
cp slack-notify.sh ~/.claude/hooks/
cp slack-notify-waiting.sh ~/.claude/hooks/
cp slack-notify-toggle.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/slack-notify.sh
chmod +x ~/.claude/hooks/slack-notify-waiting.sh
chmod +x ~/.claude/hooks/slack-notify-toggle.sh
```

### 3. 環境変数ファイルに追加

```bash
cat >> ~/.config/ai-agents/profiles/default.env << 'EOF'
SLACK_NOTIFY_ENABLED=true
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/XXX/YYY/ZZZ
EOF
```

`SLACK_WEBHOOK_URL` を手順1で取得した実際の URL に置き換えてください。

### 4. Claude Code のフック設定

`~/.claude/settings.json` に以下を追加:

```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/slack-notify.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/slack-notify-waiting.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### 5. 動作確認

```bash
# 通知状態を確認
~/.claude/hooks/slack-notify-toggle.sh status

# テスト送信（Claude Code で何かタスクを実行して確認）
```

## 使い方

### 通知の ON/OFF 切替

```bash
# トグル（ON↔OFF）
~/.claude/hooks/slack-notify-toggle.sh

# 明示的に ON
~/.claude/hooks/slack-notify-toggle.sh on

# 明示的に OFF
~/.claude/hooks/slack-notify-toggle.sh off

# 現在の状態を確認
~/.claude/hooks/slack-notify-toggle.sh status
```

## ファイル構成

| ファイル | 説明 |
|---|---|
| `slack-notify.sh` | タスク完了通知スクリプト（Stop フックから実行） |
| `slack-notify-waiting.sh` | 入力待ち通知スクリプト（Notification フックから実行） |
| `slack-notify-toggle.sh` | 通知の ON/OFF 切替スクリプト |

## 技術スタック

- **Shell**: Bash
- **HTTP**: curl
- **JSON パース**: python3
- **API**: [Slack Incoming Webhooks](https://api.slack.com/messaging/webhooks)

## LINE 通知スキルとの違い

| | LINE | Slack |
|---|---|---|
| 月間送信上限 | 200通（無料プラン） | **なし** |
| 認証 | チャネルアクセストークン + ユーザーID | Webhook URL のみ |
| セットアップ | やや複雑 | シンプル |
