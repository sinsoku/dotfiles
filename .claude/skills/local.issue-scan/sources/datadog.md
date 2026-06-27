# 情報源レシピ: datadog

scan が `datadog` 情報源を巡回する共通手順。プロジェクト固有値（クエリ / 環境フィルタ / 期間 / 閾値）は `issue-config.md`「情報源」の `datadog:` 行から取る。ここには固有値を書かない。

## 巡回

session で利用可能な Datadog MCP（`mcp__datadog*__search_logs` / `aggregate_logs` 等）を使い、config のクエリで該当ログを取得・集計する。

- query / 環境フィルタ: config の値（例 `status:error env:production`）
- 期間: config の `期間`（無ければ直近24時間）
- 閾値: config の `閾値`（例 件/日）。満たすものだけ起票候補にする

## fingerprint

Datadog のログは Sentry のような安定 issue id を持たないことが多いため、**レシピ側でエラーを正規化して安定文字列を作る**:

- **`datadog:<正規化シグネチャ>`** の形にする。シグネチャは「エラークラス＋可変部（ID・数値・UUID 等）を除いた要約メッセージ」をハイフン等で連結したもの（例 `datadog:OOMKilled-worker`、`datadog:ActiveRecord-RecordNotFound-users-show`）
- 同じ事象が同じ文字列になるよう、可変部（数値・ID）は除く。これで完全一致の重複判定が効く

## severity（重要度ラベル）

config の「重要度ラベル基準」に従う。目安: ユーザー影響・頻度が高い → `high` / 冗長ログ・低頻度 → `low`。

## 起票本文に入れる項目

- fingerprint: 上記（コロン前の `datadog` が情報源を兼ねる）
- environment / 参考リンク（Datadog のクエリ or ダッシュボード URL）
