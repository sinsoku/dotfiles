---
name: local.issue
description: git-native-issue 課題ワークフローの入口。状況を把握して各工程スキルへ誘導する。「xxxを起票して」等の手動起票もここ。初期化は /local.issue-init。
argument-hint: "[起票したい課題の概要 | 省略時は全体把握して誘導]"
---

# local.issue（入口 / ad-hoc / 手動起票）

最初に **このスキルディレクトリの `REFERENCE.md`**（`~/.claude/skills/local.issue/REFERENCE.md`）を読み、ワークフロー全体・状態機械・CLI・規約を把握する。その上で `$ARGUMENTS` に応じて以下のモードに分岐する。

## モード判定

| `$ARGUMENTS` | モード |
|---|---|
| 課題の概要（自然文。「〜を起票して」等） | **手動起票モード** |
| 空 / その他の問い合わせ | **把握・誘導モード** |

> 初期化（`issue-config.md` 生成）は別スキル `/local.issue-init`。

---

## 手動起票モード（課題の概要が渡された）

`source: manual` の Issue を1件作成する。

1. `$ARGUMENTS` の内容が不十分なら、タイトル・概要・影響をユーザーに確認する。
2. 本文を `tmp/issue-body.txt` に Write（テンプレ）:

```markdown
## 検出元
- fingerprint: manual:<タイトルから作った短い slug>
- environment: <該当すれば>

## 概要
何が起きているか（数値があれば含める）

## 影響
ユーザー / システムへの影響
```

3. 重要度ラベルを `<project_root>/.claude/issue-config.md` の基準（あれば）に従って判断・付与:

```bash
~/.claude/skills/local.issue/issue-cli.sh create "タイトル" -F tmp/issue-body.txt -l "high"
```

ラベル不要（中）なら `-l` を付けない。

4. 作成された Issue の ID とタイトルを報告。

---

## 把握・誘導モード（空 / 問い合わせ）

REFERENCE.md を踏まえ、ユーザーの意図に応じて誘導する:

- 初期化（未セットアップ） → `/local.issue-init`
- 巡回・検出 → `/local.issue-scan`
- 調査〜PR 下書き → `/local.issue-solve`
- 人間レビュー → `/local.issue-review`
- 全部自走（ループ） → `/local.issue-work`
- 後片付け → `/local.issue-clean`

「high の open を要約して」のような ad-hoc な問い合わせは、REFERENCE.md の CLI（`git issue ls` / `show` / `search`）を使ってこの場で直接実行してよい。書き込みを伴う ad-hoc 操作は AI 操作なら `issue-cli.sh`、人間判断の記録なら素の `git issue` を使い分ける。

## 運用の流れ（誰がいつ）

- **AI 自走**: `/loop 1h /local.issue-work`（scan→solve で open を ready まで進める）
- **人間・随時**: `/local.issue-review` で ready を高重要度から判定。承認 → 提示された PR コマンドで作成・マージ／却下 → feedback で差し戻し（solve が再処理）
- **人間・PR マージ後**: `/local.issue-clean` で worktree / ブランチを掃除
- **初回**: `/local.issue-init` でプロジェクトをセットアップ
- **単発**: `/local.issue-scan`（検出のみ）／`/local.issue-solve <ID>`（特定 Issue を直す）
