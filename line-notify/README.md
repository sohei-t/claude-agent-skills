# LINE 通知スキル for Claude Code

Claude Code のタスク完了時・承認待ち時に LINE へプッシュ通知を送信するフックスキルです。長時間タスクの完了や、途中の承認待ちを手元のスマートフォンで即座に確認できます。

## 機能

- **タスク完了通知**: Stop フックでタスク完了を検知し LINE に通知
- **入力待ち通知**: Notification フックで承認待ち（yes/no）を検知し LINE に通知
- 作業フォルダ名とタイムスタンプを通知メッセージに含む
- **ワンコマンドで ON/OFF 切替**が可能
- バックグラウンド送信のため Claude Code の動作をブロックしない

## 通知イメージ

**タスク完了時:**
```
✅ Claude Code 完了
📂 my-project
⏰ 14:32:05
```

**承認待ち時:**
```
⏸️ 入力待ち: my-project
💬 Bash を実行してよいですか？
⏰ 14:32:05
```

## 前提条件

- [LINE Developers](https://developers.line.biz/console/) でチャネルを作成済み
- チャネルアクセストークン（長期）を取得済み
- 自分の LINE ユーザー ID を取得済み
- `python3`、`curl` がインストール済み

## セットアップ

### 1. スクリプトを配置

```bash
# フックディレクトリにコピー
cp line-notify.sh ~/.claude/hooks/
cp line-notify-waiting.sh ~/.claude/hooks/
cp line-notify-toggle.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/line-notify.sh
chmod +x ~/.claude/hooks/line-notify-waiting.sh
chmod +x ~/.claude/hooks/line-notify-toggle.sh
```

### 2. 環境変数ファイルを作成

```bash
mkdir -p ~/.config/ai-agents/profiles

cat >> ~/.config/ai-agents/profiles/default.env << 'EOF'
LINE_NOTIFY_ENABLED=true
LINE_CHANNEL_ACCESS_TOKEN=<your-channel-access-token>
LINE_USER_ID=<your-line-user-id>
EOF
```

`<your-channel-access-token>` と `<your-line-user-id>` を実際の値に置き換えてください。

### 3. Claude Code のフック設定

`~/.claude/settings.json` に以下を追加:

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "$HOME/.claude/hooks/line-notify.sh"
      }
    ],
    "Notification": [
      {
        "matcher": "permission_prompt",
        "hooks": [
          {
            "type": "command",
            "command": "$HOME/.claude/hooks/line-notify-waiting.sh"
          }
        ]
      }
    ]
  }
}
```

### 4. 動作確認

```bash
# 通知状態を確認
~/.claude/hooks/line-notify-toggle.sh status

# テスト送信（Claude Code で何かタスクを実行して確認）
```

### 5. LINE ユーザー ID の取得方法

LINE Developers コンソール → チャネル → 「あなたのユーザーID」から確認できます。
または、Webhook で友だち追加イベントから取得することも可能です。

## 使い方

### 通知の ON/OFF 切替

```bash
# トグル（ON↔OFF）
~/.claude/hooks/line-notify-toggle.sh

# 明示的に ON
~/.claude/hooks/line-notify-toggle.sh on

# 明示的に OFF
~/.claude/hooks/line-notify-toggle.sh off

# 現在の状態を確認
~/.claude/hooks/line-notify-toggle.sh status
```

## ファイル構成

| ファイル | 説明 |
|---|---|
| `line-notify.sh` | タスク完了通知スクリプト（Stop フックから実行） |
| `line-notify-waiting.sh` | 入力待ち通知スクリプト（Notification フックから実行） |
| `line-notify-toggle.sh` | 通知の ON/OFF 切替スクリプト |

## 技術スタック

- **Shell**: Bash
- **HTTP**: curl
- **JSON パース**: python3
- **API**: [LINE Messaging API](https://developers.line.biz/ja/docs/messaging-api/) (Push Message)

## 仕組み

### タスク完了通知 (`line-notify.sh`)

1. Claude Code がタスクを完了すると Stop フックが発火
2. stdin から JSON（`session_id`, `cwd` 等）を受け取る
3. 環境変数ファイルから認証情報と有効フラグを読み込み
4. LINE Messaging API の Push Message エンドポイントへ通知を送信
5. 送信はバックグラウンドで行われ、Claude Code の次のタスクをブロックしない

### 入力待ち通知 (`line-notify-waiting.sh`)

1. Claude Code がツール実行の承認を求めると Notification フック（`permission_prompt`）が発火
2. stdin から JSON（`cwd`, `notification_type`, `message` 等）を受け取る
3. 承認待ちの内容とフォルダ名を LINE に通知
4. 同じ認証情報・有効フラグを共有するため追加設定不要
