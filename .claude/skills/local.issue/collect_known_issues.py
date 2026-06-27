"""scan の重複検出ヘルパ: 既知 Issue の fingerprint を収集する.

非 closed の Issue（open / ready）の root コミット本文から `fingerprint:` 行を読み、
`<source>:<id>` トークン（カンマ区切り・複数可）を集めて出力する。
closed は対象外（再発は新規 Issue として起票する）。

情報源に依存しない汎用ロジック: fingerprint の中身（どう安定 ID を作るか）は各情報源の
レシピが決め、ここは文字列を集めて完全一致の重複判定に渡すだけ。
出力: 既知 fingerprint トークンを1行1個で列挙する。
"""
import subprocess


def issue_bodies():
    """非 closed Issue の root コミット本文を順に返す."""
    listed = subprocess.run(
        ["git", "issue", "ls", "--all", "--format", "oneline"],
        capture_output=True,
        text=True,
    )
    for line in listed.stdout.strip().split("\n"):
        parts = line.split()
        if len(parts) < 2 or parts[1] == "closed":
            continue
        short_id = parts[0]

        uuid = subprocess.run(
            ["git", "for-each-ref", "--format=%(refname:lstrip=2)", f"refs/issues/{short_id}*"],
            capture_output=True,
            text=True,
        ).stdout.strip()
        if not uuid:
            continue

        root = subprocess.run(
            ["git", "rev-list", "--max-parents=0", f"refs/issues/{uuid}"],
            capture_output=True,
            text=True,
        ).stdout.strip()
        if not root:
            continue

        yield subprocess.run(
            ["git", "log", "-1", "--format=%B", root],
            capture_output=True,
            text=True,
        ).stdout


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
