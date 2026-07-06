---
name: local.issue
description: 「〜を起票して」で課題を起票（複数可・重複排除つき）。引数なしは状況把握と各工程への誘導。
argument-hint: "[起票したい課題の概要・「見つかった課題を起票して」等 | 省略時は全体把握して誘導]"
---

# local.issue（入口 / ad-hoc / 起票）

最初に `~/.claude/skills/local.issue/REFERENCE.md` を読む。その上で `$ARGUMENTS` に応じて以下のモードに分岐する。

## モード判定

| `$ARGUMENTS` | モード |
|---|---|
| 課題の概要・「見つかった課題を起票して」等（自然文） | **起票モード** |
| 空 / その他の問い合わせ | **把握・誘導モード** |

> 初期化（`issue-config.md` 生成）は別スキル `/local.issue-init`。

---

## 起票モード（課題の概要・起票指示が渡された）

1〜N 件の Issue を作成する。セッションのコンテキスト（直前の調査結果等）も参照する。

### 1. 起票候補の列挙

`$ARGUMENTS` とセッションのコンテキストから起票候補を列挙する。

- 「見つかった課題を起票して」→ 直前の調査結果の全件を候補とする
- 単一の課題概要 → 1件

各候補のタイトル・概要・影響は**コンテキスト中の実データ**（件数・環境・URL 等）から転記する（会話の記憶からの曖昧な要約にしない）。情報不足ならユーザーに確認する。

### 2. fingerprint の導出

REFERENCE.md の fingerprint 規約に従い各候補の fingerprint を導出する。安定 ID を作れない場合は fingerprint なしで起票する。

### 3. 起票前 dedup（必須）

既知 fingerprint を取得し、完全一致する候補はスキップする:

```bash
python3 ~/.claude/skills/local.issue/collect_known_issues.py
```

### 4. priority の判断

`<project_root>/.claude/issue-config.md` の priority 基準（あれば）に従い `-p critical|high|low` を決める。中なら付けない。

### 5. 起票（各候補）

本文を `tmp/issue-body.txt` に Write:

```markdown
## 検出元
- fingerprint: <source>:<id>
- environment: <該当すれば>
- ref: <参考リンク>

## 概要
何が起きているか（件数・エラーメッセージ等の実データを含める）

## 影響
ユーザー / システムへの影響
```

起票コマンド（priority あり）:

```bash
~/.claude/skills/local.issue/issue-cli.sh create "タイトル" -F tmp/issue-body.txt -p high
```

priority 不要（中）なら `-p` を付けない。

### 6. 報告

| ID | priority | タイトル | 検出元 |
|---|---|---|---|
| ... | ... | ... | ... |

重複スキップ件数も合わせて報告する。

---

## 把握・誘導モード（空 / 問い合わせ）

REFERENCE.md を踏まえ、ユーザーの意図に応じて誘導する:

- 初期化（未セットアップ） → `/local.issue-init`
- 調査〜PR 下書き → `/local.issue-solve`
- 人間レビュー → `/local.issue-review`
- 後片付け → `/local.issue-clean`

情報源（Sentry / Datadog 等）の調査はこのセッションで直接行う。課題が見つかったら起票モードへ（`/local.issue 見つかった課題を起票して` 等）。

「high の open を要約して」のような ad-hoc な問い合わせは、REFERENCE.md の CLI（`git issue ls` / `show` / `search`）を使ってこの場で直接実行してよい。書き込みを伴う ad-hoc 操作は AI 操作なら `issue-cli.sh`、人間判断の記録なら素の `git issue` を使い分ける。

## 運用の流れ（誰がいつ）

- **調査（人間＋AI・セッションで随時）**: Sentry / Datadog 等を直接調査し課題を発見する
- **起票**: `/local.issue 見つかった課題を起票して`（複数件一括対応・dedup 済み）
- **修正**: `/local.issue-solve`（ID 指定で1件 / 引数なしで open を priority 順にバッチ。`/loop` で自走可）
- **レビュー**: `/local.issue-review`（人間・随時。ready を priority 順に判定）
- **掃除**: `/local.issue-clean`（PR マージ後。closed の worktree / ブランチを片付け）
- **初回**: `/local.issue-init`（プロジェクトのセットアップ）
