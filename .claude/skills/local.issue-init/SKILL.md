---
name: local.issue-init
description: 課題ワークフローをこのプロジェクトで使うための初期化。プロジェクトごとに1回。
argument-hint: "（引数なし）"
---

# local.issue-init（プロジェクト初期化）

`local.issue` ワークフローをこのリポジトリで使えるようにする。プロジェクトごとに1回だけ実行する。

最初に `~/.claude/skills/local.issue/REFERENCE.md` を読む。

## 手順

1. **前提チェック**（並列で実行）:
   - `git issue --version`（未インストールなら `brew install git-native-issue` を案内し中断）
   - `git config user.name` / `git config user.email`（未設定なら設定を促す。人間 identity 用）
2. `git rev-parse --show-toplevel` でリポジトリルートを解決。
3. `~/.claude/skills/local.issue-init/issue-config.template.md` を `<project_root>/.claude/issue-config.md` にコピーする（既存なら上書きせず差分を提案）。
4. `.gitignore` に `/.claude/worktrees/` と `/tmp/` が無ければ追記を提案。
5. allowlist を案内（自動で書かず提案に留める。書き込み系の許可は自律 `/loop` 運用時のみ推奨）。`<project_root>/.claude/settings.local.json` の permissions に以下を追加すると権限プロンプトが減る:

   ```jsonc
   // 読み取り（安全）
   "Bash(git issue ls:*)", "Bash(git issue show:*)", "Bash(git issue search:*)",
   "Bash(python3 ~/.claude/skills/local.issue/collect_known_issues.py)",
   // 書き込み（issue / 下書き / worktree。自律 /loop 運用時のみ）
   "Bash(~/.claude/skills/local.issue/issue-cli.sh:*)",
   "Bash(~/.claude/skills/local.issue/set-pr-draft.sh:*)",
   "Bash(git -C <project_root>/.claude/worktrees/:*)",
   "Write(tmp/**)"
   ```
6. 完了後、`issue-config.md` の各プレースホルダ（情報源・triage 方針・lint・自己レビュー手段）を埋めるようユーザーに促す。
