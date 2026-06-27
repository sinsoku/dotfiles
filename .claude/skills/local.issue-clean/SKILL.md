---
name: local.issue-clean
description: closed な課題の worktree とブランチを片付ける。マージ済みのみ削除し、未マージは残す。
argument-hint: "（引数なし。一括）"
---

# local.issue-clean（worktree / ブランチ掃除）

`closed` 済みの Issue に対応する worktree とブランチを削除する破壊的操作。

**実行タイミング**: PR がマージされた後に実行する（review 承認直後はブランチを PR 作成で使うため）。未マージのブランチは下記の merged-only ガードで自動的に残るので、早めに実行しても安全。

最初に `~/.claude/skills/local.issue/REFERENCE.md` を読む。

## 手順

1. worktree を列挙:

```bash
git worktree list
```

`<project_root>/.claude/worktrees/*` のパスとブランチ名（`<ID>-<slug>`）を取得する。

2. closed Issue を取得し、対応関係を確認:

```bash
git issue ls --state closed --format oneline
```

各 worktree のブランチ名は `<ID>-<slug>` なので、**先頭の `-` の前を Issue 短縮ID として取り出し**、その Issue の state を確認する（`git issue show <ID>`）。**closed の Issue に対応する worktree だけ**を削除候補とする（`ready` / `open` は残す）。ブランチ名に ID が埋まっているのでコメントを grep する必要はなく、確実に対応付く。

3. 各候補を削除:

```bash
git worktree remove <project_root>/.claude/worktrees/<ID>-<slug>
git branch -d <ID>-<slug>
```

- `git branch -d`（小文字）はマージ済みのみ削除する。**未マージなら警告して残す**（`-D` で強制削除しない）。
- worktree に未コミットの変更があって remove が拒否された場合も、強制削除せず警告して残す。

4. 削除した worktree / ブランチの一覧と、残した（未マージ等）ものを報告する。

## 禁止事項

- `git branch -D`（強制削除）や `git worktree remove --force` を使う（未マージ作業を失う）
- closed でない Issue に紐づく worktree を削除する
