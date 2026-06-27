---
name: local.issue-scan
description: 情報源(Sentry/Datadog/Notion 等)を巡回して課題を検出し open 起票する。コードは読まない。
argument-hint: "（引数なし。一括巡回）"
---

# local.issue-scan（検出・起票）

情報源を巡回し、問題を検出して Issue を `open` で起票する。**コードは読まない**（原因調査は solve の役割）。

最初に `~/.claude/skills/local.issue/REFERENCE.md` を読み、状態機械・CLI・規約を把握する。

## STEP 1: 設定読み込み

1. `git rev-parse --show-toplevel` でルートを解決。
2. `<project_root>/.claude/issue-config.md` を読む。
   - **無ければ**「`/local.issue-init` を実行してください」と案内して**終了**（グレースフルデグレード）。
3. 「情報源」セクションから有効な情報源とそのパラメータ・重要度ラベル基準を取得する。各情報源の巡回手順と fingerprint 規則は STEP 3 でレシピから解決する（config に重複検出キー規則を書く必要はない。fingerprint で統一）。

## STEP 2: 既知 Issue の収集（重複検出の準備）

```bash
python3 ~/.claude/skills/local.issue/collect_known_issues.py
```

非 closed（open / ready）の Issue から `fingerprint` トークン（`<source>:<id>`）を収集する（既知 fingerprint の一覧を出力）。closed は対象外（再発は新規起票）。

## STEP 3: 巡回（情報源ごとに並列）

config「情報源」で有効な各情報源について、**レシピを解決して**巡回する:

- `~/.claude/skills/local.issue-scan/sources/<情報源名>.md`（共通レシピ。Sentry / Datadog 等を内包）があれば、それ＋config のパラメータで実行する。
- 無ければ config のインライン定義（独自情報源のレシピ: 使うツール・クエリ・閾値・**fingerprint 規則**）で実行する。

レシピは「巡回方法」と「**fingerprint の作り方**（`<source>:<id>` の安定文字列）」を定める。skill は情報源の種類を限定せず、固有値も持たない。

各情報源の巡回は独立しているため、**複数ある場合は1メッセージ内でまとめて発行して並列実行**する（1つ起動して結果を待ってから次、という逐次にしない）。

ある情報源のツール（MCP/CLI）が session で利用できない場合は、その情報源を**スキップ**し、報告に「未接続でスキップ: <名前>」と明示する（scan 全体は止めない）。

## STEP 4: 重複排除

検出した各候補の fingerprint（レシピが生成した `<source>:<id>`。複数可）を、STEP 2 の既知 fingerprint と照合する:

- いずれかの fingerprint が既知と**完全一致** → 重複（スキップ）
- どれも一致しない → 新規（起票）
- fingerprint を安定生成できない候補は新規として起票する（conservative。取りこぼしより重複の方が安全）

## STEP 5: 起票

新規分を `open` で起票する。本文を `tmp/issue-body.txt` に Write（毎回上書き）してから作成:

```markdown
## 検出元
- fingerprint: <source>:<id>[, <source>:<id> ...]   # 重複検出キー兼・情報源（コロン前が source）
- environment: <環境>

## 概要
何が・どれだけ起きているか（数値を含める）

## 影響
ユーザー / システムへの影響

## 参考リンク
<外部ツールの URL / クエリ>
```

```bash
~/.claude/skills/local.issue/issue-cli.sh create "タイトル" -F tmp/issue-body.txt -l "high"
```

重要度ラベル（`high` / `low` / なし=中）は config の基準で判断できる場合のみ付与。

## STEP 6: 報告

起票した Issue を一覧で報告する（`<ID> | 重要度 | タイトル | 検出元`）。重複でスキップした件数も併記する（例「新規 3 件 / 重複スキップ 5 件」）。未接続でスキップした情報源があれば明示。0 件なら「新規なし」と報告。

## 禁止事項

- コードを読んで原因調査する（solve の役割）
- closed Issue を重複チェック対象に含める（再発は新規起票）
- skill に特定サービスの固有値（情報源の種類・org 名・クエリ・閾値）を直書きする（すべて issue-config.md に置く）
