---
name: local.issue-work
description: scan → solve を順に実行する AI 作業ループ。/loop で自律運用。人間判定(review)は含まない。
argument-hint: "（引数なし）"
---

# local.issue-work（scan → solve 逐次実行）

AI 作業（scan → solve）を1ループ回す薄いスキル。`/loop /local.issue-work` で自律運用する。人間判定（review）は含まない。

最初に `~/.claude/skills/local.issue/REFERENCE.md` を読む。`<project_root>/.claude/issue-config.md` が無ければ「`/local.issue-init` を実行」と案内して終了。

**無人運用の前提**: `/loop` がプロンプトで止まらないよう、init が案内する allowlist（`issue-cli.sh` / `set-pr-draft.sh` / worktree の `git -C` / `Write(tmp/**)`）を `settings.local.json` に設定しておくこと。未設定だと毎回権限確認で停止する。

## 手順

scan を完了させてから solve に進む（逐次）。こうすることで**今ループで検出した課題を同ループの solve が拾える**（遅延なし）。

### Phase 1: scan

Skill ツールで `/local.issue-scan` を実行（情報源巡回 → 重複排除 → open 起票）。完了後、新規起票数を記録。

### Phase 2: solve

`open` を一覧取得し、各 Issue を順に処理する:

```bash
git issue ls --state open --format oneline
```

各 ID について Skill ツールで `/local.issue-solve <ID>` を実行（無人実行のため ID を明示的に渡す）。1件ずつ逐次。件数が多いとループ1回が長くなるので、`/loop` の間隔は実態に合わせる。`open` が空なら solve は実行せず「対象なし」とする。

## 完了報告

```
## /local.issue-work 完了
- scan: 新規 N 件起票（open 計 X 件）
- solve: ready へ M 件遷移（修正 a / wontfix推奨 b / 人間判断 c）。open 0件なら「対象なし」
- エラー: <あれば箇条書き、なければ「なし」>
```

## エラーハンドリング

- scan が失敗しても Phase 2（solve）は実行する（前ループの open が残っている可能性）。
- solve の個別失敗は当該 Issue を `open` のまま残し、次ループに委ねる。
- ループ1回の途中失敗が長期滞留しないよう、失敗しても可能な範囲を進める。

## 運用

```bash
/loop 1h /local.issue-work    # AI 作業を1時間ごとに自走
/local.issue-review           # 人間が手の空いたときに ready を消化
```

## 禁止事項

- review / triage の最終確定（人間判定）をここで行う
- Phase 1（scan）の完了を待たずに Phase 2（solve）を始める（同ループで検出を拾えなくなる）
