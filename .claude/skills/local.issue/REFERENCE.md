# local.issue ワークフロー リファレンス（唯一の真実源）

`/local.issue*` 系スキルが共有する前提知識。ワークフロー全体・状態機械・CLI・規約をここに集約する。各スキルはこのファイルを参照し、内容を再記述しない。

## 前提

AI が課題を検知→修正→PR下書きまで自走し、人間が review する。成果物は **PR 下書きとコード変更**。下書きは**作業ブランチ `<ID>-<slug>` の description**（`git config branch.<ID>-<slug>.description`、1行目=タイトル＋空行＋本文）に置く。**PR 作成・push は責務外**（人間が承認後に行う）。

記録は **git-native-issue**（`git issue`）。Issue は各リポジトリの `.git/refs/issues/` にローカル格納（push しない）、コメントは git commit として著者・時刻つきで残る。

## 状態機械（3 state）

```
open ──(AI: solve)──> ready ──(人間: review)──> closed
  ^                      │
  └── 人間 reject（feedback コメント + --open で差し戻し）┘
```

| state | git-issue 表現 | 意味 | 動かすスキル |
|---|---|---|---|
| `open` | 作成時デフォルト | 検出済みバックログ / 差し戻し | scan が作る・solve が拾う |
| `ready` | `--state ready` | AI が出来ることを完了・人間レビュー待ち | solve |
| `closed` | `--close --reason completed\|wontfix\|duplicate` | 完了 | review |

- 中間 state は設けない。triage は独立した state にせず solve 内の判断に畳み込む。
- **AI は close しない**（close は人間の review のみ）。本物の課題を握り潰す不可逆失敗を防ぐため。
- solve は open を3分岐（修正 / wontfix推奨 / 人間判断）で判定し、出口は全て `ready`（詳細は local.issue-solve）。人間は review で承認 / 却下 / wontfix 同意を下す。

## CLI チートシート

各コマンドの実体は消費するスキルがインラインで示す。ここは規約と共通の読み取りのみ。

- **書き込み（AI）**: `~/.claude/skills/local.issue/issue-cli.sh <create|comment|state|edit> ...`。`GIT_AUTHOR=Claude` を設定し `-F <file>` を `-m "$(cat)"` に変換するラッパー。本文は tmp に Write して `-F` で渡す。
- **PR 下書き**: `~/.claude/skills/local.issue/set-pr-draft.sh <project_root> <ID>-<slug> <file>`。読み取りは `git config get branch.<ID>-<slug>.description`。
- **書き込み（人間＝review）**: 素の `git issue`（人間 identity で記録）。具体コマンドは local.issue-review。
- **読み取り（共通）**: `git issue ls --state <open|ready|all> --format oneline`（`<7文字ID> <state> <title>`）／`git issue show <ID>`（本文＋全コメント）／`git issue search "kw"`。ID は先頭7文字短縮（最低4文字で解決）。

## 規約（権限プロンプト・破損の回避）

- **コメント/本文は tmp ファイル経由**: `-m` にインラインで `#` を含む本文を渡すと Claude Code の権限チェックに引っかかる。本文は Write で `tmp/issue-*.txt` に書き出し、`issue-cli.sh ... -F`（コメント）や `set-pr-draft.sh ... <file>`（PR 下書き）でファイルから渡す。本文をコマンド行に直書きしない。
- **tmp ファイル命名**: `tmp/issue-body.txt`（起票）、`tmp/issue-<ID>-<phase>.txt`（phase = solve / review-feedback / review-fix など）。`tmp/` は gitignore 対象。
- **コメント本文のトレーラー制約**: 次の名前で始まる行があると `git issue comment` に拒否される — `State`, `Labels`, `Assignee`, `Priority`, `Milestone`, `Title`, `Provider-ID`, `Format-Version`, `Fixed-By`, `Release`, `Reason`, `Conflict`。`## 見出し` 形式は問題ない。
- **worktree 操作のみ絶対パス**: worktree 内の git 操作は `git -C <project>/.claude/worktrees/<ID>-<slug>` のように絶対パスで。`cd && git ...` の複合コマンドは使わない。
- **ベースブランチ (`<base>`)**: 次の順で解決する（skill に `main` を直書きしない）。
  1. `issue-config.md` の `base` 設定
  2. `git symbolic-ref --short refs/remotes/origin/HEAD`（origin/HEAD があれば。通常 `origin/main`）
  3. ローカルに `main` があれば `main`、無く `master` があれば `master`
  4. いずれも無ければ現在のブランチ
  リモート追跡があれば `origin/<base>`、無ければローカル `<base>` を使う。以降このリファレンスでは解決結果を `<base>` と表記する。
- **複合 Bash を避ける**: `cd &&`、`VAR=$(...)`、過度なパイプ連結は静的解析が allowlist にマッチせず毎回権限確認が出る。単純コマンドに分ける。
- **事前確認コマンドを避ける**: `touch` / `mkdir` / `ls` などの権限プロンプトを誘発するコマンドは極力使わない。

## プロジェクト固有設定

各リポジトリの `<project_root>/.claude/issue-config.md` に集約（`/local.issue-init` が雛形生成）。skill 本体は固有値を持たない。

- **情報源**: 有効化する情報源とパラメータ（共通の Sentry / Datadog は `local.issue-scan/sources/` のレシピを内包。独自源はインラインでレシピ＝ツール・クエリ・閾値・fingerprint 規則を定義）、重要度ラベル基準。重複検出は全情報源とも `fingerprint`（`<source>:<id>`）の完全一致で統一
- **triage 方針**: 既知の想定エラー（常に wontfix の allowlist）、auto-fix してよいカテゴリ、重要度閾値
- **lint/test**: solve / review が変更ファイルに走らせる任意コマンド（例 `bundle exec rubocop`）。未設定ならスキップ
- **自己レビュー手段**: solve が修正後に使う自己レビューの手段（任意。例 `/local.review`）。**issue-* は特定のレビュースキルに依存しない**ため、ここで注入する。未設定なら下記 REVIEW.md を観点に基本的な自己レビューを行う

レビュー観点は `issue-config.md` に持たず、`<project_root>/.claude/REVIEW.md`（あれば）に置く（solve の自己レビュー手段・人間の review が参照する）。

`issue-config.md` が無い場合、scan / solve は「`/local.issue-init` を実行してください」と案内して安全に終了する（グレースフルデグレード）。初期化の手順は `/local.issue-init` が持つ。

（運用の流れ・スキル一覧は入口の `/local.issue` を参照）
