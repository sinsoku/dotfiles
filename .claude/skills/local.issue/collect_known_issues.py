"""open の全 issue ＋ cooldown 内の closed（completed は N 日、wontfix は無期限）の fingerprint を列挙する.

非 closed の Issue（open / ready / rework）と、cooldown 条件を満たす closed Issue の
root コミット本文から `fingerprint:` 行を読み、
`<source>:<id>` トークン（カンマ区切り・複数可）を集めて出力する。

cooldown ルール:
  - close 理由が wontfix: 無期限に含める
  - close 理由が completed: close 時刻から COOLDOWN_DAYS 日以内（既定 7）なら含める
  - Reason: トレーラーが無い・パース不能なら安全側（含める）

情報源に依存しない汎用ロジック: fingerprint の中身（どう安定 ID を作るか）は各情報源の
レシピが決め、ここは文字列を集めて完全一致の重複判定に渡すだけ。
出力: 既知 fingerprint トークンを1行1個で列挙する。
"""
import os
import subprocess
import sys
from datetime import datetime, timedelta, timezone

COOLDOWN_DAYS = int(os.environ.get("COOLDOWN_DAYS", "7"))


def run_git(*args):
    """git コマンドを実行し、成功なら stdout を返す。失敗は stderr に警告して None を返す."""
    result = subprocess.run(["git"] + list(args), capture_output=True, text=True)
    if result.returncode != 0:
        cmd_hint = " ".join(list(args)[:3])
        sys.stderr.write(f"warning: git {cmd_hint} failed: {result.stderr.strip()}\n")
        return None
    return result.stdout


def resolve_uuid(short_id):
    """short_id に一致する issue の refs/issues/<uuid> を返す。複数・0件はスキップ."""
    out = run_git("for-each-ref", "--format=%(refname:lstrip=2)", f"refs/issues/{short_id}*")
    if out is None:
        return None
    lines = [line for line in out.splitlines() if line.strip()]
    if len(lines) != 1:
        if lines:
            sys.stderr.write(f"warning: {short_id}: {len(lines)} refs matched, skipping\n")
        return None
    return lines[0]


def root_body(uuid):
    """issue の root コミット本文を返す。取得失敗は None."""
    root_out = run_git("rev-list", "--max-parents=0", f"refs/issues/{uuid}")
    if root_out is None:
        return None
    root = root_out.strip()
    if not root:
        return None
    return run_git("log", "-1", "--format=%B", root)


def find_close_commit(uuid):
    """chain を新しい順に走査して close コミットの日時と Reason を返す。未検出は (None, None)."""
    log_out = run_git("log", "--format=%H %cI", f"refs/issues/{uuid}")
    if log_out is None:
        return None, None
    for line in log_out.splitlines():
        parts = line.split(maxsplit=1)
        if len(parts) < 2:
            continue
        commit_hash, commit_iso = parts[0], parts[1].strip()
        body = run_git("log", "-1", "--format=%B", commit_hash)
        if body is None:
            continue
        state = None
        reason = None
        for bl in body.splitlines():
            key, _, val = bl.partition(":")
            key_low = key.strip().lower()
            if key_low == "state" and state is None:
                state = val.strip().lower()
            elif key_low == "reason" and reason is None:
                reason = val.strip().lower()
        if state == "closed":
            try:
                close_dt = datetime.fromisoformat(commit_iso)
            except (ValueError, TypeError):
                close_dt = None
            return close_dt, reason
    return None, None


def in_cooldown(uuid):
    """closed issue が cooldown 期間内かどうか判定する。判定不能は True（安全側）."""
    close_dt, reason = find_close_commit(uuid)
    if reason is None:
        return True  # Reason なし: 安全側
    if reason == "wontfix":
        return True
    if reason == "completed":
        if close_dt is None:
            return True
        now = datetime.now(tz=timezone.utc)
        if close_dt.tzinfo is None:
            close_dt = close_dt.replace(tzinfo=timezone.utc)
        return (now - close_dt) <= timedelta(days=COOLDOWN_DAYS)
    return True  # 未知の Reason: 安全側


def issue_bodies():
    """収集対象 Issue の root コミット本文を順に返す."""
    listed = run_git("issue", "ls", "--all", "--format", "oneline")
    if listed is None:
        return
    for line in listed.strip().split("\n"):
        parts = line.split()
        if len(parts) < 2:
            continue
        short_id, state = parts[0], parts[1]

        uuid = resolve_uuid(short_id)
        if uuid is None:
            continue

        if state == "closed" and not in_cooldown(uuid):
            continue

        body = root_body(uuid)
        if body:
            yield body


def main():
    known = set()
    for body in issue_bodies():
        for line in body.split("\n"):
            stripped = line.lstrip("-* ").strip()
            low = stripped.lower()
            if low.startswith("fingerprint:"):
                value = stripped.split(":", 1)[1]
                for token in value.split(","):
                    token = token.strip()
                    if token:
                        known.add(token)
    for token in sorted(known):
        print(token)


if __name__ == "__main__":
    main()
