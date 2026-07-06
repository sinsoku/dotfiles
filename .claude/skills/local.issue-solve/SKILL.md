---
name: local.issue-solve
description: 「この課題を直して」で open な課題を修正〜PR下書きまで自走し ready に。引数なしは priority 順バッチ。
argument-hint: "[Issue ID | 省略時は open を priority 順にバッチ処理]"
---

# local.issue-solve（調査・修正・PR下書き）

`open` の Issue を、PR 下書きが揃った `ready`（ラベル）まで持っていく。

最初に `~/.claude/skills/local.issue/REFERENCE.md` を読む。

## STEP 0: 対象決定と設定読み込み

1. `git rev-parse --show-toplevel` でルート解決。
2. `<project_root>/.claude/issue-config.md` を読む（無ければ「`/local.issue-init` を実行」と案内し終了）。triage 方針・lint/test コマンド・`base`（REFERENCE.md「ベースブランチ」の解決ルール）を取得。
3. 対象 Issue:
   - `$ARGUMENTS` に ID 指定があれば**単発モード**（以下 4 へ進む）。
   - **引数なし → バッチモード**（以下「バッチモード」節を参照）。
4. `git issue show <ID>` で本文＋全コメント（過去の人間フィードバック含む）を読む。**rework ラベルが付いた（review が feedback コメント付きで差し戻した）Issue の場合、review の feedback を最優先で反映する**。
5. **リトライ上限ゲート（単発モード）**: 修正試行回数 = これまでのコメント中の「## 実装内容」を含む件数。rework ラベルが付いており、かつ修正試行が既に **3回**あれば、修正に挑戦せず「AI では feedback を満たせない・手動対応が必要」の論点コメントを書いて **(C) 人間判断として STEP 7 へ直行**する。（(B)/(C) の出口コメントは `## トリアージ判断` 見出しを使うためカウントに混入しない）

### バッチモード（引数なし・旧 local.issue-work の後継）

1. 処理キューを作る（priority 降順）:

```bash
git issue ls --state open --sort priority --format oneline
git issue ls --state open --label ready --format oneline
```

前者から後者の ID を除外した差分が対象。空なら「対象なし」と報告して終了。各 rework 対象は修正試行回数（コメント中の「## 実装内容」を含む件数）を確認し、3回に達しているものは solver に渡さず、メインが直接 (C) コメントを書いて ready 遷移する（リトライ上限）。

2. 各 ID を**1件ずつ逐次、solver サブエージェント**（`general-purpose`）で実行する。solver への指示: 「`~/.claude/skills/local.issue-solve/SKILL.md` と `~/.claude/skills/local.issue/REFERENCE.md` を読み、Issue <ID> を単発モードの手順で **STEP 6b と STEP 7 を除いて** 処理せよ。最終メッセージで (A/B/C) 判定・因果チェーン・変更概要・ブランチ名（(B)/(C) の場合はコメントに書くべき理由・論点）を返せ」。並列にはしない（同一リポジトリの git 操作競合を避ける）。

3. solver の判定が **(A) 修正** → メインが **STEP 6b の真因検証を `model: opus` の verifier サブエージェントで起動**。合格ならメインが STEP 7（コメント Write ＋ `issue-cli.sh edit -l ready`）を実行。**不合格なら反駁内容を渡して solver を1回だけ再修正させ、なお不合格なら (C) に切替えて**（反駁理由をコメントに含め）STEP 7 を実行。

4. solver の判定が **(B)/(C)** → 検証不要。メインが STEP 7 を直接実行。

5. 個別の失敗はその Issue を残して続行する。

6. 完了報告:

```
## /local.issue-solve バッチ完了
- ready へ N 件（修正 a / wontfix推奨 b / 人間判断 c）
- 検証不合格→(C) 切替: e 件
- 失敗・スキップ: d 件（あれば ID と理由）
```

> 無人運用: `/loop 1h /local.issue-solve` で自走できる。その場合 init が案内する allowlist を `settings.local.json` に設定しておかないと権限プロンプトで停止する。

## STEP 1: 判定（triage を畳み込む）

`issue-config.md` の triage 方針を踏まえ、**懐疑的に**「これは本物で、今直す価値があるか」を判定する。提案を自分で追認しないよう、反証（直さない理由）も一度考える。3分岐し、**どれでも出口は `ready`**。AI は close しない。

- **(A) 修正する** → STEP 2 へ
- **(B) wontfix 推奨**（既知の想定エラー allowlist 該当・解消済み・直す価値が薄い）→ コードに触れず、理由を `tmp/issue-<ID>-solve.txt` に Write してコメント追記 → STEP 7（ready 遷移）へ
- **(C) 人間判断が必要**（仕様変更を伴う・優先度が人間にしか判断できない）→ 論点をコメント追記 → STEP 7 へ

## STEP 2: 最新状況と原因調査（修正する場合）

1. **最新状況の確認**: 本文の `fingerprint`（`<source>:<id>`。コロン前のプレフィックスが情報源）を基に、その情報源で直近の発生状況（継続中 / 改善傾向 / 解消済み）を確認する。解消済みなら (B) に倒すことを検討（`manual:` は外部情報源が無いので状況確認はスキップ。情報源に到達できない＝MCP 未接続等の場合も状況確認はスキップしてコード調査に進む）。
2. **原因調査**: `general-purpose` の Agent を起動し、エラーの根本原因や N+1 箇所をコード上で特定する。Agent には Issue 本文・fingerprint・対象範囲を渡す。**Agent への指示に「経路の裏取りまで行い、因果チェーンを file:line 付きで返す」を含める**。調査 Agent は既定 `model: sonnet`、並行性・多層の経路・データ破損系など複雑な課題は `model: opus` を使う。調査の成果物は**因果チェーン**（症状（fingerprint の事象）→ 原因箇所（file:line）→ 経路の裏取り）として必須とする。
3. **確信度ルーティング**: 裏取りが取れない・原因を確信できない場合は修正に進まず **(C) 人間判断**に倒し、調査メモ（どこまで調べて何が不明か）をコメントに残す。確信の無い修正 PR より、調査メモ付きの人間判断の方が価値が高い。

## STEP 3: worktree 準備

メインのワーキングツリーは変更せず、worktree で作業する。ブランチ名は `<ID>-<slug>`（`<ID>` は Issue の短縮ID、`<slug>` はタイトルから作る短いケバブ。`/` 不可・`-` 区切り）。ID を含めるので一意・再現可能（再利用・clean が安定）。

- 既存の `<project_root>/.claude/worktrees/<ID>-<slug>` があれば再利用。
- 無ければ作成（`<base>` は REFERENCE.md「ベースブランチ」の解決ルールに従う。通常 `origin/main`）。事前に `git fetch origin <base>` を実行する（リモート追跡が無ければ fetch をスキップし、ローカル `<base>` を使う）:

```bash
git worktree add <project_root>/.claude/worktrees/<ID>-<slug> -b <ID>-<slug> origin/<base>
```

差し戻し（rework ラベルの）Issue の再処理時は同じ worktree を再利用し、**前回の修正を引き継いで** review の feedback に従い追加修正する（やり直さない）。`<base>` が進んでいれば `git -C <project_root>/.claude/worktrees/<ID>-<slug> rebase origin/<base>`、衝突したら解消するか (C) 人間判断に上げる。worktree が消えてブランチだけ残る場合は `git worktree add <project_root>/.claude/worktrees/<ID>-<slug> <ID>-<slug>`（`-b` なし）で再接続する。

## STEP 4: 実装とコミット

1. worktree 内で原因に基づきコードを修正する。
2. lint / test（`issue-config.md` にあれば）:
   - lint を変更ファイルに実行し、オフェンスを解消する。
   - test は**変更に関連するテスト**（変更ファイルに対応するテストファイル。不明なら関連ディレクトリ単位）を実行し、結果（コマンド・pass/fail・未実行ならその理由）を STEP 5 の証拠欄に転記する。
   - テストで再現可能な修正なら回帰テストの追加を推奨する（必須ではない。形だけのテストを量産しない）。
   - lint / test が解消できない場合は修正 PR として ready にせず、未解決内容を明記して **(C) 人間判断**へ（不通のまま review に出さない）。
   - lint / test は worktree 内で実行する。`git -C` の効かない外部コマンドは**この用途に限り** `cd <worktree> && <cmd>` を許容する。
3. コミットする。コミットメッセージは `/local.git-commit` の方針に従う。課題参照（fingerprint の id や Issue ID）があれば本文に含める。worktree 内での操作は `git -C <project_root>/.claude/worktrees/<ID>-<slug>` を使う。

## STEP 5: PR 下書きをブランチ description に保存

下書きを `tmp/issue-<ID>-desc.txt` に Write する。**1行目をタイトル**（70文字以内・命令形）、空行、以降を説明とする。説明本文のフォーマットは次を使い、各見出しを Issue の内容で埋める（**人間が短時間で理解・承認できる**ことを最優先）:

- `<project_root>/.github/PULL_REQUEST_TEMPLATE.md` があればそれ
- 無ければ `~/.claude/skills/local.issue-solve/PULL_REQUEST_TEMPLATE.md`（フォールバック）

テンプレートを使う場合も、**証拠（原因の因果チェーン・テスト結果・lint 結果）は必ず下書きに含める**（該当する節が無ければ確認事項に相当する節へ追記する）。

ブランチ description に書き込む（次の STEP の自己レビューがこの下書きも対象にできるよう、**自己レビューの前に**書く）:

```bash
~/.claude/skills/local.issue/set-pr-draft.sh <project_root> <ID>-<slug> tmp/issue-<ID>-desc.txt
```

## STEP 6a: 変更品質レビュー（手段は注入）

6a はスコープ限定（change set 内の品質）のレビューを行う。

`issue-config.md` の**自己レビュー手段**でコード差分と PR 下書き（branch description）を自己レビューする（例: `/local.review` を `<ID>-<slug>` ブランチ対象で実行）。手段が未設定なら `<project_root>/.claude/REVIEW.md`（あれば）を観点に、無ければ最小観点で確認する: **変更が最小か / diff が読みやすいか / lint 通過 / コミットの why / 明らかなバグ・security**。

- critical / major の指摘があれば修正し（コードなら worktree、下書きなら STEP 5 で description を更新）、再度自己レビュー。指摘が無くなるまで自己完結で反復する。

**修正困難・断念時**: 試したアプローチと失敗理由（差し戻しなら「feedback に対応できない理由」）をコメントに残し、**(C) 人間判断として `ready` に上げる**（STEP 7 へ）。`ready` ラベルを付けずに残すと、人間は ready ラベルしか見ないため放置され、solve が毎ループ拾い直して無限リトライになる。無理に修正PRは作らない。

## STEP 6b: 真因解消検証（独立コンテキスト・必須・(A) 修正のみ）

6b はスコープ非限定（真因が diff の外にある可能性を見る）で、6a のスコープ限定と役割が異なる。**バッチモードでは 6b はメイン（ディスパッチャ）が実行する（バッチモード節を参照）。**

solve の実装コンテキストとは別の **fresh なサブエージェント**（`general-purpose`・**`model: opus` 固定**）を起動し、次を渡す: Issue 本文＋fingerprint、STEP 2 の因果チェーン主張、diff（`git diff <base>...<ID>-<slug>`）、PR 下書き（branch description）。

指示は**反証**: 「この diff は根本原因を解消するか、それとも症状への対症療法か。因果チェーンの主張を鵜呑みにせず、コードを読んで独立に再検証せよ。change set 外のコードも辿ってよい。反駁できるなら反駁し、結論（解消する / 対症療法・原因が別にある / 判定不能）と根拠 file:line を返せ。**迷ったら反駁側に倒せ**」。

- **判定不能は不合格として扱う**（安全側。確信できない修正を ready にしない）。
- 反駁された → 修正して 6a からやり直し（**1回まで**）。なお反駁 → **(C) に切替え**、反駁理由をコメントに含めて STEP 7 へ。

## STEP 7: issue コメントと ready 遷移

**(A) 修正の場合、STEP 6b 合格が ready の条件。**

監査証跡として `tmp/issue-<ID>-solve.txt` に Write してコメント追記する（トレーラー名で始まる行を作らない）:

```markdown
## 実装内容
- ブランチ: <ID>-<slug>
- 変更ファイル: <一覧>
- 1行サマリ: 何を・なぜ
- 証拠: <因果チェーン 1-2 行> / テスト: <結果> / 真因検証: <合格 or (C)切替>
- PR 下書き: ブランチ `<ID>-<slug>` の description に記載（`git config get branch.<ID>-<slug>.description`）
```

```bash
~/.claude/skills/local.issue/issue-cli.sh comment <ID> -F tmp/issue-<ID>-solve.txt
~/.claude/skills/local.issue/issue-cli.sh edit <ID> -l ready
```

（rework ラベルが付いていても `-l ready` の replace-all で上書きされる）

(B) wontfix 推奨・(C) 人間判断 の場合は、`## トリアージ判断` を見出しにしたコメント（判定・理由・論点。実装後に切替えた場合はブランチ名と未解決内容・反駁理由も）を追記してから ready に遷移する。**`## 実装内容` 見出しは使わない**（修正試行回数のカウントを汚さないため）。STEP 1 や STEP 2 から直行した場合はコードや下書きは無い。

## STEP 8: 報告

ID・タイトル・判定（修正 / wontfix推奨 / 人間判断）・ブランチ名・変更ファイルを簡潔に報告する。

## 禁止事項

- Issue を close する（review = 人間の役割。solve は ready まで）
- メインのワーキングツリーを変更する（必ず worktree 内）
- PR を作成・push する（このワークフローの責務外。下書きはブランチ description に書き、PR 作成は人間の通常フロー）
- skill に固有のレビュー観点を書く（`<project>/.claude/REVIEW.md`・自己レビュー手段に委ねる）
- `git issue edit --remove-label` を使う（v1.3.3 のバグで効かない。ラベル変更は `-l` の replace-all のみ）
- 因果の裏取り・STEP 6b の真因検証なしで修正 PR を ready にする
- テスト・lint の失敗を残したまま ready にする（解消できなければ (C) へ）
