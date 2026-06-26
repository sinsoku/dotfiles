---
name: local.review
description: GitHub PR またはローカルブランチのタイトル＋説明・コミット・差分を、動的トリアージで深度を変えてレビューする。PR 作成前のセルフレビューに使う。
argument-hint: "[PR番号 | PR URL | ブランチ名 | 省略時は現在ブランチ] [--base <branch>]"
allowed-tools: Bash(git diff:*), Bash(git log:*), Bash(git fetch:*), Bash(git config get:*), Bash(git rev-parse:*), Bash(gh pr view:*), Bash(gh pr diff:*), Bash(gh repo view:*), Read(**), Grep(*), Glob(*), Task, AskUserQuestion
---

# local.review（動的トリアージ付きローカルレビュー）

このセッションは**配管**（入力取得・ルータ起動・ディスパッチ・集約・表示）に徹する。
**レビュー観点は REVIEW.md が唯一の真実源**で、ここには書かない。

## 核となる原則

- **動的トリアージ**: 差分の複雑さを安いモデルで分類し、レビューの深さ（レンズ数・モデル・検証の厚み）を変える。
- **帰属（attribution）**: 指摘は change set に帰属するものに限る。変更外の既存コードは、変更が直接の原因で壊れる場合を除き OUT OF SCOPE。
- **ゲート・簡潔**: 各指摘は `file:line` ＋ severity ＋ 規約参照1つで自己完結させる。先生役の長文解説は不要。
- **投稿しない**: 結果はターミナルに表示するのみ。`gh pr comment` 等は一切叩かない。

---

## STEP 1: 入力アダプタ（モード判定と対象の取得）

引数 `$ARGUMENTS` からモードを決め、**タイトル・説明・コミット・差分**を取得する。
観点・ディスパッチ・集約は共通で、ここだけがモードで差し替わる。

| 引数 | モード |
|---|---|
| 数字 / GitHub PR URL | **PRモード** |
| ブランチ名 / 省略（現在ブランチ） | **ローカルモード** |
| `--base <branch>` | base 上書き（既定 `main`）。PRモードでは無視 |

### PRモード

次の2コマンドは依存がないため、**1メッセージ内の2 Bash tool call として同時発行**する（逐次実行しない）:

- `gh pr view <N|URL> --json title,body,author,baseRefName,headRefName,commits,files`
  → **title と body を連結して「タイトル＋説明」1つの文章**として扱う。commits からコミットメッセージ群、`files`（path / additions / deletions）から変更ファイル × 追加/削除行数（numstat 相当）を得る。
- `gh pr diff <N|URL>` → 差分本文（変更ファイル × 行範囲）。ファイル一覧は `gh pr diff --name-only`。

> **PRモードの numstat は `files` から取る。`gh pr diff | git apply --numstat` のような即興コマンドは使わない**（`git apply` は書き込み系で許可すべきでない・`&&`/`|` の複合コマンドは静的解析が allowlist にマッチせず毎回権限確認が出る）。

### ローカルモード

base を解決する（`--base` 指定値、無ければ `main`）。**差分計算の前に必ず** `git fetch origin <base>` を実行し、
以降は `origin/<base>` を基準にする（ローカル base が古いと merge-base が遡り、マージ済み変更が混入するため）。

- **タイトル＋説明**: `git config get branch.<現在/指定ブランチ>.description` の**全体を1つの文章として読む**
  （1行目がタイトル相当・残りが本文だが分割せず通しで読む）。
  - **未設定（空）なら、タイトル・説明を `AskUserQuestion` でユーザーに聞く**。
- **コミット**: `git log origin/<base>..HEAD --format='%H%n%s%n%b%n---'`
- **差分**: `git diff origin/<base>...HEAD`（＋ `--stat` / `--name-only` / `--numstat`）

`origin/<base>` が存在しない（origin に無いローカル専用ブランチを `--base` 指定）場合のみローカル `<base>` にフォールバックし、その旨を明示する。

### 差分0件ガード

`--name-only` が空ならレビュー対象が無い。**STEP 2 以降に進まず即終了**し、次アクション（作業ブランチに切替 / `--base` 変更 / PR番号指定）を提示する。存在しない問題をでっち上げない。

### change set の固定

取得した「変更ファイル × 変更/追加行の行番号範囲」を **唯一の change set** として保持し、以降の全 agent と帰属ゲートに同一文面で渡す。

---

## STEP 2: 観点の読み込み（REVIEW.md）

`git rev-parse --show-toplevel` でリポジトリルートを解決し、次を読む:

1. **共通観点**: このスキルディレクトリの `REVIEW.md`（必須・全プロジェクト共通）。
2. **プロジェクト観点**: `<project_root>/.claude/REVIEW.md`（あれば・チーム共有）。
3. **開発者観点**: `<project_root>/.claude/REVIEW.local.md`（あれば・個人/gitignore）。

加えて、プロジェクト観点の「最初に読むファイル」に従い、`.claude/CLAUDE.md` と変更種別に応じた `.claude/rules/*` も Read。

**優先順位**: 共通がレンズの枠組みを与え、プロジェクトが補完・上書き、開発者が最優先で補完・上書きする。矛盾したら後の層を優先。

---

## STEP 3: 動的トリアージ（ルータ）

差分の複雑さ・リスクを**安いモデルで分類**し、レビューの深度を決める。
**このステップは省略しない。** main が差分を把握済みでも、深度・レンズ選定は必ずルータの JSON 出力で決める（手動判断で代替しない）。

`Task` で **`general-purpose` subagent を `model: haiku` で1回**起動し、次を渡す:

- **STEP 1 で取得済み**の `--name-only` / `--numstat` の結果（ここで `git diff` を再実行しない）
- 差分本文（ルータは分類器なので全文は不要。`--numstat` 合計が 400 行を超える場合はハンク本文を渡さず、name-only ＋ numstat ＋ 各ファイル先頭ハンクのみにする）
- 各層の REVIEW.md の「レンズ登録」と「高リスクシグナル」節（固有のリスクパスを含む）

ルータは次の **JSON だけ**を最終メッセージで返す:

```json
{
  "depth": "trivial | normal | high_risk",
  "lenses": ["correctness", "devils-advocate", "<project-lens>", "..."],
  "contract_change_c": true,
  "changed_fields": ["<field>", "..."],
  "risk_reason": "認可ロジックに触れているため"
}
```

ルータへの指示:

- **迷ったら高い深度へ倒す**（false negative＝バグ見逃しの方が高コスト）。
- 高リスクシグナル: 認可 / migration / 課金 / PII / 外部配信 / **既存フィールドの値・shape・意味の変化**。各層の REVIEW.md の定義に従う。
- `lenses` は**全層のレンズ登録の `name`** から、各 `when` と差分が合致するものを選ぶ。該当差分が無いレンズは挙げない。
- `contract_change_c` が true なら `changed_fields` に変化したフィールド名とデータ経路を入れる（意味波及スイープのため）。

---

## STEP 4: レビュー実行（並列ディスパッチ）

ルータ結果に基づきレビューを並列実行する:

- **選定した全レンズ（communication ＋ 差分レンズ群）の Task call を1メッセージ内で同時発行**してから集約に進む（1本ずつ起動・待機しない。`run_in_background: true`）。
- **communication（4-A）は depth に依らず常時**、差分レンズ群（4-B）は深度連動。
- 差分レンズの起動に気を取られて communication を飛ばさない。

- **`handler` が `pr-review-toolkit:*` のレンズ** → その**公式 Agent をそのまま `subagent_type` に指定**してディスパッチする。独自レビュープロンプトを書かない（観点・出力は公式 Agent が持つ）。
- **`handler` が `custom` のレンズ** → `subagent_type: general-purpose` に、該当 REVIEW.md の「カスタムレンズ観点」本文を注入してディスパッチする。

### 4-A. communication レンズ（タイトル＋説明＋コミット・常時・dispatched）

文章品質専用の custom レンズを**常時1本ディスパッチ**する（`subagent_type: general-purpose`・**model は `sonnet` 固定**。文章レビューは opus 不要。main セッションだと差分レンズに注意が逸れ浅くなるため subagent に分離）。プロンプトに必ず含める:

1. REVIEW.md の「タイトル＋説明」節（**diff 突き合わせ手順を含む**）と「コミットメッセージ」節、各層 REVIEW.md のコミット具体基準（逐語注入）
2. 取得済みの**タイトル＋説明（1文章）・コミットメッセージ群・diff 本文**（diff 突き合わせのため diff も渡す）
3. 出力形式・観点は REVIEW.md の `communication` 節／出力フォーマット節に従う（ここに再記述しない）
4. **Edit/Write は使わない（レビュー専用）**

### 4-B. 差分レンズ群（深度連動）

`lenses` のうち communication を除く各レンズを、レンズ登録の定義に従ってディスパッチする。

**深度 → モデル・検証の対応:**

| depth | レンズ | 検証（STEP 5） |
|---|---|---|
| `trivial` | correctness（公式 code-reviewer）のみ | なし |
| `normal` | 該当レンズ数枚 | 報告対象の critical・major のみ（軽め） |
| `high_risk` | 全該当レンズ（`contract_change_c` が true なら consumer-impact を追加） | 報告対象の critical・major をフル（Read・経路追跡） |

**モデルはレンズの性質で決める（深度で一律 opus にしない）:**
- 機械的・パターン検出（公式 `code-reviewer` / `simplification` / `comments` / `test-coverage` / `type-design` / `silent-failure`）→ **常に `sonnet`**
- 推論が重い（`consumer-impact` / `caller-impact` / `devils-advocate`）→ normal は `sonnet`、**`high_risk` のみ `opus`**
- `communication` → 常に `sonnet`

> ディスパッチ時にレンズごとの model を指定する（公式 Agent も同様に上書きする）。

差分レンズの各プロンプト（公式 Agent / custom 共通）に必ず含める:

1. タスク概要と主な変更点
2. **STEP 1 で固定した change set（変更ファイル × 行範囲）をそのまま埋め込む**
3. **スコープ規約（逐語）**:
   > 「指摘は上記 change set に帰属するものに限る。変更行外の既存コードの品質問題は、
   > **この変更が直接の原因で壊れる場合を除き OUT OF SCOPE。スコープ外を見つけても指摘に含めない**。
   > 各指摘には対象 file:line と『なぜ change set に帰属するか』を必ず添えること。」
4. custom レンズには、その「カスタムレンズ観点」本文（重点観点）
5. `contract_change_c` が true のレンズには、変化したフィールド名・データ経路・旧→新の値変化
6. 出力フォーマット: severity（critical/major/minor）別、`file:line`（head 版の実際の行番号）必須、推奨は**現状→修正後の最小コード例つき**
7. **Edit/Write は使わない（レビュー専用）**

---

## STEP 5: 集約（帰属 → dedup → 検証 → severity 確定）

**前提（満たさなければ集約に進まない）**: STEP 3 ルータ・communication レンズ（4-A）・差分レンズ群（4-B）がすべて実行済みであること。1つでも未実行なら戻って実行する。

`Collection → ★Attribution → Dedup → 刈り込み → Verification → Finalization`。詳細ルール（帰属の3分類・severity 物差し・実害の段階・確信度しきい値）は共通 REVIEW.md に従う。

1. **Collection**: communication レンズと差分レンズ群の出力をそのまま集める。
2. **★Attribution**: 各指摘を change set と file:line で `IN_DIFF` / `CHANGE_CAUSED` / `PRE_EXISTING` に分類。`PRE_EXISTING` はドロップし件数のみ記録。**スコープゲートは severity ゲートに優先**（深刻でもスコープ外はドロップ）。
3. **Dedup**: `IN_DIFF` / `CHANGE_CAUSED` のみ統合。報告元レンズ一覧は残す（2+ = 確信度シグナル）。
4. **刈り込み（検証の前に安く絞る）**: 確信度フィルタ（共通 REVIEW.md の基準）と severity で、**検証する前に**報告しない指摘（minor・低確信）を外す。検証は直列 `Read` で重いので、捨てる指摘に Read を使わない。**ただし critical は確信度が低くても即落とさず、検証で確認してから判断する**（検証が確信度を上げる場合があるため）。
5. **Verification（報告対象のみ）**: 残った **critical・major** を main が検証（引用突き合わせ・経路追跡・意味波及の consumer 確認）。**レンズが `file:line` ＋ 引用で根拠を十分示した指摘は再 Read しない**。main が独立に `Read` するのは (a) `CHANGE_CAUSED` の経路追跡、(b) 引用の無い critical、(c) レンズ間で食い違う指摘、に限る。経路をたどれない `CHANGE_CAUSED` は `PRE_EXISTING` に倒す。
6. **Finalization**: 検証結果で severity を確定。

---

## STEP 6: 出力（ターミナル・簡潔・投稿しない）

共通 REVIEW.md「出力フォーマット」節に従ってターミナルに表示する（形式はそちらが真実源・ここに再掲しない）。

---

## Common Mistakes（禁止事項）

- レビュー観点をこのファイルに書く（→ REVIEW.md が唯一の真実源）
- Attribution を飛ばして agent の指摘をそのまま採用する
- `PRE_EXISTING` を「ついでだから」と本文に残す（件数記録のみ）
- STEP 3 ルータを省略し、main の理解だけで深度・レンズを決める（動的トリアージの放棄）
- communication レンズ（タイトル＋説明・コミット）を飛ばして差分レンズだけ実行する（常時実行・集約の前提）
- ローカルモードで `git fetch origin <base>` を省く（古い base で差分が混入）
- ブランチ説明が無いのにユーザーに聞かず、タイトル・説明を推測する
- 結果を PR に投稿する
