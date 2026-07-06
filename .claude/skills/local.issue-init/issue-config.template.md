# issue-config.md（このリポジトリの課題ワークフロー設定）

## ブランチ
- base: <任意。origin の既定ブランチと異なる場合のみ明示>

## priority 基準
critical=<即時対応> / high=<ユーザー影響大 or 高頻度> / low=<低頻度・冗長ログ> / 無指定=中

## triage 方針
solve が「直す価値があるか」を判定する際の基準。
- 常に wontfix にする既知の想定エラー（allowlist）:
  - <例: 無効アカウントへの OAuth エラーは仕様>
- auto-fix してよいカテゴリ: <例: N+1, 明確な例外ハンドリング漏れ>
- 必ず人間判断に回すカテゴリ: <例: 仕様変更を伴うもの, データ移行>

## lint/test
solve / review が変更ファイルに走らせるコマンド（任意・無ければ空）。
- lint: <例: bundle exec rubocop>
- test: <例: bundle exec rspec>

## 自己レビュー手段
solve が修正後に使う変更品質レビューの手段（任意。無ければ REVIEW.md を観点に基本レビュー）。真因解消の検証は solve が独立エージェントで必ず行う（設定不要）。
- review: <例: /local.review>
