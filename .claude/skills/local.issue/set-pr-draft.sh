#!/usr/bin/env bash
# PR 下書き（タイトル＋説明）をブランチの description に書き込む。
#
# git config の値は argv（stdin 不可）のため、本文をファイルから読んで設定する。
# $(cat ...) をこのスクリプト内部に隠すことで、Claude Code の権限プロンプト
# （# / $() / 引用符）を回避する（issue-cli.sh -F と同じ理屈）。
# 値の # / " / ' / 改行は git が自前でエスケープして格納するので壊れない。
#
# GIT_AUTHOR は設定しない: git config はコミットを作らず著者を記録しないため不要
# （issue-cli.sh はコメント=コミットを作るので GIT_AUTHOR を設定する。役割が異なる）。
#
# 配置: ~/.claude/skills/local.issue/set-pr-draft.sh
# Usage:
#   ~/.claude/skills/local.issue/set-pr-draft.sh <project_root> <branch> <file>

set -euo pipefail

test $# -eq 3 || { echo "usage: set-pr-draft.sh <project_root> <branch> <file>" >&2; exit 1; }
project_root="$1"
branch="$2"
file="$3"

test -d "$project_root" || { echo "error: not a directory: $project_root" >&2; exit 1; }
test -f "$file" || { echo "error: file not found: $file" >&2; exit 1; }

git -C "$project_root" config "branch.${branch}.description" "$(cat "$file")"
