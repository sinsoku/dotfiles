---
name: local.issue-review
description: ready な課題を1件、人間がレビューして承認(closed)か差し戻し(open)する人間ゲート。
argument-hint: "[Issue ID | 省略時は ready 一覧から選択]"
---

# local.issue-review（人間ゲート・判定）

`ready` の Issue を1件、人間が**短時間で理解・承認できる**形に整えて提示し、判断を記録する。記録は人間の identity で行うため、書き込みは素の `git issue`（`issue-cli.sh` ではない）を使う。**push / PR 作成はここでは行わない**（承認後、人間が通常フローで作成する。下書きはブランチ description に入っている）。

最初に `~/.claude/skills/local.issue/REFERENCE.md` を読む。

## STEP 0: 対象決定

1. `$ARGUMENTS` に ID があればそれ。無ければ ready を**重要度順**で提示して選択を促す（high が埋もれないよう先に出す）:

```bash
git issue ls --state ready --label high --format oneline   # high を先頭に
git issue ls --state ready --format oneline                # 残り
```
2. `git issue show <ID>` で本文＋全コメント（solve の実装サマリ・過去フィードバック）を読む。コメントから solve の出口種別を判別する: **修正PR / wontfix推奨 / 人間判断（AI が修正を断念した場合を含む）**。

## STEP 1: 提示（種別ごと）

### 修正PR の場合

設定を読む: `git rev-parse --show-toplevel` でルート解決 → `<project_root>/.claude/issue-config.md` を読み、lint コマンドと `base` を取得（無ければ「`/local.issue-init` を実行」と案内して終了）。`<base>` は REFERENCE.md「ベースブランチ」の解決ルールに従う。

PR 下書きはブランチ description に入っているので読む:

```bash
git config get branch.<ID>-<slug>.description
```

差分を確認する:

```bash
git diff <base>...<ID>-<slug> --stat
git diff <base>...<ID>-<slug>
```

以下を**簡潔に**提示する:
1. **PR 下書き**（ブランチ description の内容）
2. **差分サマリ**（--stat）
3. **客観チェック（fact のみ）** — 該当があるものだけ強調表示する（指摘の無い観点は出さない）:
   - lint（config の lint コマンドを変更ファイルに実行）の結果
   - 「確認したこと」に post-merge 項目（"デプロイ後""本番"等）が混入していないか
   - 曖昧表現（"あれば""など""可能なら"）・自己評価語（"最小""網羅的"）の混入
   - PR 下書きの内容と実 diff の食い違い
   - **プロジェクト固有の観点**: `<project_root>/.claude/REVIEW.md`（あれば）を参照（特定のレビュースキルには依存しない）

> ユーザー設定: **指摘がある観点のみ表示**する。問題のない観点は「OK」と並べない。

### wontfix推奨 / 人間判断（修正断念含む）の場合

solve のコメント（理由・論点・断念したアプローチ）を要約して提示し、人間の判断を仰ぐ（config 読み込みは不要）。判定は通常どおり: 妥当なら wontfix で close、対応すべきなら feedback を付けて `--open`（solve が再挑戦／人間が手動対応）。

## STEP 2: 判定

ユーザーに判断を仰ぎ、結果を記録する。

### 承認

```bash
git issue state <ID> --close --reason completed
```

PR は作成しない。代わりに、**承認後に人間がそのまま実行できる PR 作成コマンドを提示**する（skill 自身は実行しない。`git config get` は1回だけ・タイトルは下書き1行目・本文は3行目以降を渡すのでタイトルが重複しない）:

```bash
b=<ID>-<slug>
desc=$(git config get branch.$b.description)
git -C <project_root>/.claude/worktrees/$b push -u origin $b
gh pr create --head $b --title "$(head -1 <<<"$desc")" --body "$(sed '1,2d' <<<"$desc")"
```

### 却下（差し戻し）

フィードバックを `tmp/issue-<ID>-review-feedback.txt` に Write し、open に戻す（solve が再処理する）。素の `git issue` は `-F` 非対応なので、コマンド文字列に `#` を含めないよう `$(cat ...)` でファイルから渡す（人間 identity で記録するためラッパー issue-cli.sh は使わない）:

```bash
git issue comment <ID> -m "$(cat tmp/issue-<ID>-review-feedback.txt)"
git issue state <ID> --open
```

本文はトレーラー名（`State` 等）で始まる行を作らない（`## 見出し` 形式は可）。

### wontfix 同意

```bash
git issue state <ID> --close --reason wontfix
```

## STEP 3: close 漏れの補助チェック（任意）

ブランチが既に `<base>` に取り込まれていれば、対応済みなのに ready のまま残っている候補:

```bash
git merge-base --is-ancestor <ID>-<slug> origin/<base>
```

該当すれば close（completed）を提案する。

## 禁止事項

- AI の identity（issue-cli.sh）で close する（review は人間の判断記録。素の `git issue` を使う）
- 指摘の無い観点まで「OK」と羅列する（指摘がある観点のみ表示）
- push / PR 作成 / rebase を行う（このワークフローの責務外。承認後に人間が通常フローで実施）
