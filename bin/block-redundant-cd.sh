#!/usr/bin/env bash
# PreToolUse(Bash) フック: CWD（プロジェクトルート）と同じ場所への `cd` / `git -C` を弾く。
#
# 背景: 既に CWD がリポジトリルートのため、ルートへの cd / git -C は一律に不要
#       （git かどうかに関係なく不要）。冗長なうえ毎回権限確認プロンプトの原因になる。
#       メモリ(助言)では止まらない無意図の生成デフォルトのため、ハーネス側で機械的に弾く。
# 許可: サブディレクトリへの cd（例: cd app）は正当なので通す。
set -euo pipefail

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // ""')
root="${CLAUDE_PROJECT_DIR:-$PWD}"

# root を grep -E 用にエスケープ（英数字・/ 以外を一律バックスラッシュ化して . 等のメタ文字を無効化）
esc=$(printf '%s' "$root" | sed 's/[^[:alnum:]/]/\\&/g')

# 末尾が / でない = サブディレクトリ指定ではない → ルートそのものへの移動とみなす。
#   cd <root>            … ブロック
#   cd <root>/           … ブロック（末尾スラッシュのみ）
#   cd <root>/app        … 許可（サブディレクトリ）
boundary='("|[[:space:]]|;|&|\||$)'
cd_re="(^|[;&|[:space:]])cd[[:space:]]+\"?${esc}/?${boundary}"
gitc_re="(^|[;&|[:space:]])git[[:space:]]+-C[[:space:]]+\"?${esc}/?${boundary}"

if printf '%s' "$cmd" | grep -Eq "$cd_re" || printf '%s' "$cmd" | grep -Eq "$gitc_re"; then
  reason="CWD はすでにプロジェクトルート（${root}）です。ルートへの cd / git -C は git 操作も含め一律に不要なので、それを外してコマンドを実行してください（サブディレクトリへの cd は可）。"
  jq -n --arg r "$reason" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
fi
exit 0
