#!/usr/bin/env bash
# git issue ラッパー（AI 操作用）
#
# Claude Code の Bash ヒューリスティクス回避:
#   - GIT_AUTHOR_NAME/EMAIL を自動設定（コマンドプレフィックス問題の回避）
#   - -F <file> を -m "$(cat <file>)" に変換（改行+# 問題の回避）
#
# 配置: ~/.claude/skills/local.issue/issue-cli.sh
#
# Usage:
#   ~/.claude/skills/local.issue/issue-cli.sh create "title" -F tmp/issue-body.txt -l "high"
#   ~/.claude/skills/local.issue/issue-cli.sh comment <ID> -F tmp/issue-<ID>-solve.txt
#   ~/.claude/skills/local.issue/issue-cli.sh state <ID> --state ready

set -euo pipefail

export GIT_AUTHOR_NAME=Claude
export GIT_AUTHOR_EMAIL=noreply@anthropic.com

args=()
while [ $# -gt 0 ]; do
  case "$1" in
    -F|--file)
      test $# -ge 2 || { echo "error: -F requires a file path" >&2; exit 1; }
      test -f "$2" || { echo "error: file not found: $2" >&2; exit 1; }
      args+=("-m" "$(cat "$2")")
      shift 2
      ;;
    *)
      args+=("$1")
      shift
      ;;
  esac
done

exec git issue "${args[@]}"
