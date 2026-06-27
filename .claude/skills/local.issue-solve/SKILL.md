---
name: local.issue-solve
description: open な課題を1件、調査・修正・PR下書きまで自走して ready にする。「この課題を直して」等で起動。
argument-hint: "[Issue ID | 省略時は open 一覧から選択]"
---

# local.issue-solve（調査・修正・PR下書き）

`open` の Issue を1件、PR 下書きが揃った `ready` 状態まで持っていく。AI 開発者のコア。

最初に `~/.claude/skills/local.issue/REFERENCE.md` を読み、状態機械・solve の3分岐・CLI・規約を把握する。

## STEP 0: 対象決定と設定読み込み

1. `git rev-parse --show-toplevel` でルート解決。
2. `<project_root>/.claude/issue-config.md` を読む（無ければ「`/local.issue-init` を実行」と案内し終了）。triage 方針・lint/test コマンド・`base`（REFERENCE.md「ベースブランチ」の解決ルール）を取得。
3. 対象 Issue:
   - `$ARGUMENTS` に ID 指定があればそれ。
   - 無ければ `git issue ls --state open --format oneline` を表示しユーザーに選択を促す（work からの無人実行では呼び出し側が ID を渡す）。
4. `git issue show <ID>` で本文＋全コメント（過去の人間フィードバック含む）を読む。**差し戻し（feedback 付きで open に戻された）Issue の場合、review の feedback を最優先で反映する**。

## STEP 1: 判定（triage を畳み込む）

`issue-config.md` の triage 方針を踏まえ、**懐疑的に**「これは本物で、今直す価値があるか」を判定する。提案を自分で追認しないよう、反証（直さない理由）も一度考える。3分岐し、**どれでも出口は `ready`**。AI は close しない。

- **(A) 修正する** → STEP 2 へ
- **(B) wontfix 推奨**（既知の想定エラー allowlist 該当・解消済み・直す価値が薄い）→ コードに触れず、理由を `tmp/issue-<ID>-solve.txt` に Write してコメント追記 → STEP 7（ready 遷移）へ
- **(C) 人間判断が必要**（仕様変更を伴う・優先度が人間にしか判断できない）→ 論点をコメント追記 → STEP 7 へ

## STEP 2: 最新状況と原因調査（修正する場合）

1. **最新状況の確認**: 本文の `fingerprint`（`<source>:<id>`。コロン前のプレフィックスが情報源）を基に、その情報源で直近の発生状況（継続中 / 改善傾向 / 解消済み）を確認する。解消済みなら (B) に倒すことを検討（`manual:` は外部情報源が無いので状況確認はスキップ。情報源に到達できない＝MCP 未接続等の場合も状況確認はスキップしてコード調査に進む）。
2. **原因調査**: `Explore` または `general-purpose` の Agent を起動し、エラーの根本原因や N+1 箇所をコード上で特定する。Agent には Issue 本文・fingerprint・対象範囲を渡す。**推測で断定せず、コード上で裏取りしてから結論づける**（特に N+1 等は呼び出し経路・既存の preload / eager loading の有無を確認し、誤検知を避ける）。

## STEP 3: worktree 準備

メインのワーキングツリーは変更せず、worktree で作業する。ブランチ名は `<ID>-<slug>`（`<ID>` は Issue の短縮ID、`<slug>` はタイトルから作る短いケバブ。`/` 不可・`-` 区切り）。ID を含めるので一意・再現可能（再利用・clean が安定）。

- 既存の `<project_root>/.claude/worktrees/<ID>-<slug>` があれば再利用。
- 無ければ作成（`<base>` は REFERENCE.md「ベースブランチ」の解決ルールに従う。通常 `origin/main`）:

```bash
git worktree add <project_root>/.claude/worktrees/<ID>-<slug> -b <ID>-<slug> origin/<base>
```

差し戻し `open` の再処理時は同じ worktree を再利用し、**前回の修正を引き継いで** review の feedback に従い追加修正する（やり直さない）。`<base>` が進んでいれば `git -C <project_root>/.claude/worktrees/<ID>-<slug> rebase origin/<base>`、衝突したら解消するか (C) 人間判断に上げる。worktree が消えてブランチだけ残る場合は `git worktree add <project_root>/.claude/worktrees/<ID>-<slug> <ID>-<slug>`（`-b` なし）で再接続する。

## STEP 4: 実装とコミット

1. worktree 内で原因に基づきコードを修正する。
2. `issue-config.md` に lint コマンドがあれば変更ファイルに実行し、オフェンスを解消する。test は実行をスキップしてよい。**解消できない lint エラーが残る場合は通常の修正PRとして ready にせず**、未解決内容を明記して (C) 人間判断として上げる（lint 不通のまま review に出さない）。
3. コミットする。コミットメッセージは `/local.git-commit` の方針（why 中心・簡潔・既存スタイル準拠）に従う。課題参照（fingerprint の id や Issue ID）があれば本文に含める。worktree 内での操作は `git -C <project_root>/.claude/worktrees/<ID>-<slug>` を使う。

## STEP 5: PR 下書きをブランチ description に保存

下書きを `tmp/issue-<ID>-desc.txt` に Write する。**1行目をタイトル**（70文字以内・命令形）、空行、以降を説明とする。説明本文のフォーマットは次を使い、各見出しを Issue の内容で埋める（**人間が短時間で理解・承認できる**ことを最優先）:

- `<project_root>/.github/PULL_REQUEST_TEMPLATE.md` があればそれ
- 無ければ `~/.claude/skills/local.issue-solve/PULL_REQUEST_TEMPLATE.md`（フォールバック）

ブランチ description に書き込む（次の STEP の自己レビューがこの下書きも対象にできるよう、**自己レビューの前に**書く。ラッパー経由なので `#` / 引用符はそのまま安全に格納される）:

```bash
~/.claude/skills/local.issue/set-pr-draft.sh <project_root> <ID>-<slug> tmp/issue-<ID>-desc.txt
```

## STEP 6: 自己レビュー（手段は注入）

`issue-config.md` の**自己レビュー手段**でコード差分と PR 下書き（branch description）を自己レビューする（例: `/local.review` を `<ID>-<slug>` ブランチ対象で実行）。手段が未設定なら `<project_root>/.claude/REVIEW.md`（あれば）を観点に、無ければ最小観点で確認する: **変更が最小か / diff が読みやすいか / lint 通過 / コミットの why / 明らかなバグ・security**。**issue-* は特定のレビュースキルに依存しない**。レビュー観点は skill に再記述しない。

- critical / major の指摘があれば修正し（コードなら worktree、下書きなら STEP 5 で description を更新）、再度自己レビュー。指摘が無くなるまで自己完結で反復する。

**修正困難・断念時**: 試したアプローチと失敗理由（差し戻しなら「feedback に対応できない理由」）をコメントに残し、**(C) 人間判断として `ready` に上げる**（STEP 7 へ）。`open` に残すと、人間は `ready` しか見ないため放置され、solve が毎ループ拾い直して無限リトライになる。無理に修正PRは作らない。

## STEP 7: issue コメントと ready 遷移

監査証跡として `tmp/issue-<ID>-solve.txt` に Write してコメント追記する（トレーラー名で始まる行を作らない）:

```markdown
## 実装内容
- ブランチ: <ID>-<slug>
- 変更ファイル: <一覧>
- 1行サマリ: 何を・なぜ
- PR 下書き: ブランチ `<ID>-<slug>` の description に記載（`git config get branch.<ID>-<slug>.description`）
```

```bash
~/.claude/skills/local.issue/issue-cli.sh comment <ID> -F tmp/issue-<ID>-solve.txt
~/.claude/skills/local.issue/issue-cli.sh state <ID> --state ready
```

(B) wontfix 推奨・(C) 人間判断 の場合は、コードや下書きは無く（STEP 2〜6 をスキップ）、判断材料のコメントを追記してから ready に遷移する。

## STEP 8: 報告

ID・タイトル・判定（修正 / wontfix推奨 / 人間判断）・ブランチ名・変更ファイルを簡潔に報告する。

## 禁止事項

- Issue を close する（review = 人間の役割。solve は ready まで）
- メインのワーキングツリーを変更する（必ず worktree 内）
- PR を作成・push する（このワークフローの責務外。下書きはブランチ description に書き、PR 作成は人間の通常フロー）
- skill に固有のレビュー観点を書く（`<project>/.claude/REVIEW.md`・自己レビュー手段に委ねる）
