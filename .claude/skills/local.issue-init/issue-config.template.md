# issue-config.md（このリポジトリの課題ワークフロー設定）

## ブランチ
- base: <省略時は origin の既定ブランチを自動検出。master 等なら明示する>

## 調査の起点メモ
<!-- スキルはこの節を読まない。人間と AI がセッションで情報源を調査する際の参考情報（自動巡回=scan は廃止済み）。 -->
- sentry: org=<org>, project=<slug>, regionUrl=<https://...>
- datadog: よく使うクエリ=status:error env:production, 閾値=<件/日>
- 閾値の目安: <例: 24h で 10 件以上なら起票検討>
<!-- fingerprint 安定 ID の作り方メモ（REFERENCE.md の fingerprint 規約を補完する位置づけ）。 -->
<!-- 例: notion:<page_id> / sentry:<issue_id> -->

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
- test: <例: bundle exec rspec（solve が変更に関連するテストを実行し、結果を PR 下書きに記録する）>

## 自己レビュー手段
solve が修正後に使う変更品質レビューの手段（任意。無ければ REVIEW.md を観点に基本レビュー）。真因解消の検証は solve が独立エージェントで必ず行う（設定不要）。
- review: <例: /local.review>
