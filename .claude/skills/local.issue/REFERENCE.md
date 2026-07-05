# local.issue ワークフロー リファレンス（唯一の真実源）

`/local.issue*` 系スキルが共有する前提知識。ワークフロー全体・状態モデル・CLI・規約をここに集約する。各スキルはこのファイルを参照し、内容を再記述しない。

## 前提

人間がセッションで Sentry / Datadog 等の情報源を調査して課題を見つけ、`/local.issue` で起票する。AI は solve で修正〜PR 下書きまで自走し、人間が review する。成果物は **PR 下書きとコード変更**。下書きは**作業ブランチ `<ID>-<slug>` の description**（`git config branch.<ID>-<slug>.description`、1行目=タイトル＋空行＋本文）に置く。**PR 作成・push は責務外**（人間が承認後に行う）。

記録は **git-native-issue**（`git issue`）。Issue は各リポジトリの `.git/refs/issues/` にローカル格納（push しない）、コメントは git commit として著者・時刻つきで残る。

## 状態モデル（state × ラベル × priority）

**state** は open / closed の2値のみ。工程はラベルで表現する。

```
（ラベルなし = バックログ）
     │
     └─(AI: solve 完了)──> [ready ラベル] ──(人間: 承認)──> closed
                                │
                         (人間: 差し戻し)
                                │
                           [rework ラベル]
                                │
                         (AI: 再 solve 完了)
                                │
                           [ready ラベル]
```

| 工程 | state | ラベル | 意味 | 動かす主体 |
|---|---|---|---|---|
| バックログ | open | なし | 未着手 | solve が拾う |
| レビュー待ち | open | `ready` | AI が完了・人間レビュー待ち | solve |
| 差し戻し | open | `rework` | 人間が却下・再修正待ち | solve |
| 完了 | closed | （任意） | 承認・完了・wontfix | review |

- **AI は close しない**（close は人間の review のみ）。本物の課題を握り潰す不可逆失敗を防ぐため。
- solve は open（ready ラベルなし）を3分岐（修正 / wontfix推奨 / 人間判断）で判定し、出口は全て `ready` ラベル付与。**(A) 修正は真因解消検証（独立コンテキスト・solve STEP 6b）の合格が ready の条件**（詳細は local.issue-solve）。人間は review で承認 / 却下 / wontfix 同意を下す。
- 承認 close 時に ready ラベルは剥がさない（無害）。

**ラベル操作（replace-all のみ）**:
- AI → `~/.claude/skills/local.issue/issue-cli.sh edit <ID> -l ready`
- 人間（review で差し戻し） → 素の `git issue edit <ID> -l rework`
- **`--remove-label` は使用禁止**（git-issue v1.3.3 のバグ: 空 Labels トレーラーが状態計算で無視される）。

**priority**: `-p critical|high|low`（無指定＝中。`--sort priority` はデフォルト降順で critical が先頭。`--reverse` 不要・実機検証済み）。

## fingerprint 規約

形式: `<source>:<安定ID>`（カンマ区切り複数可・完全一致で dedup）

| 情報源 | 形式 | 備考 |
|---|---|---|
| Sentry | `sentry:<issue short id>` | 例: `sentry:PROJ-62B` |
| Datadog | `datadog:<正規化シグネチャ>` | エラークラス＋安定した発生箇所。ID・数値・UUID 等の可変部を除く。**迷ったら狭く**（誤って別事象を束ねない） |
| 手動 | `manual:<slug>` | 例: `manual:payment-timeout` |
| その他 | `<source>:<安定ID>` | — |

安定 ID を作れない場合は fingerprint なしで起票する。

## CLI チートシート

各コマンドの実体は消費するスキルがインラインで示す。ここは規約と共通の読み取りのみ。

- **書き込み（AI）**: `~/.claude/skills/local.issue/issue-cli.sh <create|comment|edit> ...`。`GIT_AUTHOR=Claude` を設定し `-F <file>` を `-m "$(cat)"` に変換するラッパー。本文は tmp に Write して `-F` で渡す。
- **PR 下書き**: `~/.claude/skills/local.issue/set-pr-draft.sh <project_root> <ID>-<slug> <file>`。読み取りは `git config get branch.<ID>-<slug>.description`。
- **書き込み（人間＝review）**: 素の `git issue`（人間 identity で記録）。具体コマンドは local.issue-review。
- **読み取り（共通）**: `git issue ls --state open --format oneline`（`<7文字ID> <state> <title>`）／`git issue show <ID>`（本文＋全コメント）／`git issue search "kw"`。ID は先頭7文字短縮（最低4文字で解決）。
- **solve 対象**（open かつ ready ラベルなし）: `git issue ls --state open --sort priority --format oneline` から `git issue ls --state open --label ready --format oneline` の ID を除外した差分（2クエリ）。
- **review 対象**: `git issue ls --state open --label ready --sort priority --format oneline`

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
  **fetch 必須**: worktree 作成・rebase の前に `git fetch origin <base>` を実行。リモート追跡が無ければ fetch をスキップしローカル `<base>` を使う。以降このリファレンスでは解決結果を `<base>` と表記する。
- **複合 Bash を避ける**: `cd &&`、`VAR=$(...)`、過度なパイプ連結は静的解析が allowlist にマッチせず毎回権限確認が出る。単純コマンドに分ける。
- **事前確認コマンドを避ける**: `touch` / `mkdir` / `ls` などの権限プロンプトを誘発するコマンドは極力使わない。

## プロジェクト固有設定

各リポジトリの `<project_root>/.claude/issue-config.md` に集約（`/local.issue-init` が雛形生成）。skill 本体は固有値を持たない。

- **情報源**: 調査の起点メモ（scan は廃止。スキルは読まない。人間と AI がセッションで調査する際の参考情報）。Sentry / Datadog 等のプロジェクト固有のパラメータ（URL・クエリ・閾値等）を記載。fingerprint 規約は REFERENCE.md に統一。
- **priority 基準**: critical / high / low の判断基準（無指定＝中）。
- **triage 方針**: 既知の想定エラー（常に wontfix の allowlist）、auto-fix してよいカテゴリ
- **lint/test**: solve / review が変更ファイルに走らせる任意コマンド（例 `bundle exec rubocop`）。未設定ならスキップ
- **自己レビュー手段**（変更品質レビュー。任意・注入。例 `/local.review`。未設定なら REVIEW.md を観点に基本レビュー）。**真因解消の検証は注入対象外**: solve が独立サブエージェントで必ず実施する（skill 既定の必須工程・設定不要）。

レビュー観点は `issue-config.md` に持たず、`<project_root>/.claude/REVIEW.md`（あれば）に置く（solve の自己レビュー手段・人間の review が参照する）。

`issue-config.md` が無い場合、solve は「`/local.issue-init` を実行してください」と案内して安全に終了する（グレースフルデグレード）。初期化の手順は `/local.issue-init` が持つ。

（運用の流れ・スキル一覧は入口の `/local.issue` を参照）
