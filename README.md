# Claude Agent Skills

Claude Code を拡張するカスタムスキル（フック・ツール）のコレクションです。
日常の開発ワークフローを自動化・効率化するために作成しました。

## スキル一覧

| スキル | 説明 | 技術 |
|---|---|---|
| [slack-notify](./slack-notify/) | タスク完了・承認待ち時に Slack 通知を送信 | Bash, curl, Slack Incoming Webhooks |
| [line-notify](./line-notify/) | タスク完了・承認待ち時に LINE プッシュ通知を送信 | Bash, curl, LINE Messaging API |

## クイックスタート

### 1. リポジトリをクローン

```bash
git clone https://github.com/sohei-t/claude-agent-skills.git
cd claude-agent-skills
```

### 2. 使いたいスキルのディレクトリへ移動

```bash
cd line-notify
```

### 3. 各スキルの README.md に従ってセットアップ

各スキルディレクトリ内の `README.md` にセットアップ手順が記載されています。

## 構成

```
claude-agent-skills/
├── README.md           # このファイル
├── LICENSE             # MIT License
├── slack-notify/       # Slack通知スキル（推奨）
│   ├── README.md
│   ├── slack-notify.sh
│   ├── slack-notify-waiting.sh
│   └── slack-notify-toggle.sh
├── line-notify/        # LINE通知スキル
│   ├── README.md
│   ├── line-notify.sh
│   ├── line-notify-waiting.sh
│   └── line-notify-toggle.sh
└── (今後追加予定)
```

## Claude Code フックについて

Claude Code のフック機能を使うと、エージェントのライフサイクルイベント（Start, Stop 等）に任意のコマンドを実行できます。

設定は `~/.claude/settings.json` で行います:

```json
{
  "hooks": {
    "Stop": [
      { "type": "command", "command": "/path/to/your-script.sh" }
    ]
  }
}
```

詳しくは [Claude Code ドキュメント](https://docs.anthropic.com/en/docs/claude-code) を参照してください。

## コントリビューション

Issue や Pull Request を歓迎します。新しいスキルの提案もお気軽にどうぞ。

## ライセンス

[MIT License](./LICENSE)
