# 情報源レシピ: sentry

scan が `sentry` 情報源を巡回する共通手順。プロジェクト固有値（org / project / regionUrl / 期間 / 閾値）は `issue-config.md`「情報源」の `sentry:` 行から取る。ここには固有値を書かない。

## 巡回

session で利用可能な Sentry MCP（`mcp__sentry__*` 系。例: issue 検索）を使い、config のパラメータで未解決 issue を取得する。

- organization / project / regionUrl: config の値
- 期間: config の `期間`（例 `lastSeen:-24h`）。無ければ直近24時間
- 閾値: config の `閾値`（例 イベント数 N 以上）。満たすものだけ起票候補にする

## fingerprint

- **`sentry:<issue short id>`**（例 `sentry:KUTIKOMI-COM-62B`）
- グルーピングされた1 Issue が複数の Sentry issue を束ねる場合はカンマ区切りで列挙する

## severity（重要度ラベル）

config の「重要度ラベル基準」に従う。目安: ユーザー影響大 or 高頻度 → `high` / 低頻度 → `low` / 中 → ラベルなし。

## 起票本文に入れる項目

- fingerprint: 上記（コロン前の `sentry` が情報源を兼ねる）
- environment / 参考リンク（Sentry issue の URL）
