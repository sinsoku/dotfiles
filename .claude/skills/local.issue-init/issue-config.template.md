# issue-config.md（このリポジトリの課題ワークフロー設定）

## ブランチ
- base: <省略時は origin の既定ブランチを自動検出。master 等なら明示する>

## 情報源
scan が巡回する情報源を有効化する。共通の Sentry / Datadog は
`~/.claude/skills/local.issue-scan/sources/<名前>.md` のレシピを内包しているので、
ここでは有効化＋パラメータだけ書けばよい。使わない例は削除してよい。
- sentry: organization=<org>, project=<slug>, regionUrl=<https://...>, 期間=lastSeen:-24h
- datadog: クエリ=status:error env:production, 閾値=<件/日>
独自の情報源は、レシピをこの行にインラインで書く（重複検出のため fingerprint 規則を必ず含める）:
- <名前>: tool=<MCP/CLI>, クエリ=<...>, 閾値=<...>, fingerprint=<名前>:<安定idの作り方>
  例) notion: tool=mcp__notion__query, database=<id>, filter=status=未対応, fingerprint=notion:<page_id>

重要度ラベル基準: high=<ユーザー影響大 or 高頻度>, low=<低頻度 or 冗長ログ>, なし=中（重複検出は全情報源 fingerprint で統一）

## triage 方針
solve が「直す価値があるか」を判定する際の基準。
- 常に wontfix にする既知の想定エラー（allowlist）:
  - <例: 無効アカウントへの OAuth エラーは仕様>
- auto-fix してよいカテゴリ: <例: N+1, 明確な例外ハンドリング漏れ>
- 必ず人間判断に回すカテゴリ: <例: 仕様変更を伴うもの, データ移行>

## lint/test
solve / review が変更ファイルに走らせるコマンド（任意・無ければ空）。
- lint: <例: bundle exec rubocop>
- test: <例: bundle exec rspec（solve は実行をスキップしてよい）>

## 自己レビュー手段
solve が修正後に使う自己レビューの手段（任意。無ければ REVIEW.md を観点に基本レビュー）。
- review: <例: /local.review>
