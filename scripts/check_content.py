#!/usr/bin/env python3
"""Catch the mistakes that break a post or page before the site is built.

Usage:
  python3 scripts/check_content.py            # files changed since origin/main
  python3 scripts/check_content.py FILE ...   # just these files

Checks, for each post, page or fact file:
  - it starts with front matter and has a title;
  - posts: the file name is YYYY-MM-DD-slug.md/.html, the date is set, matches the
    file name, has a time zone and is not in the future (Jekyll silently skips
    future posts, so they would never appear);
  - categories and tags are slugs that exist in _data/categories.yml / _data/tags.yml;
  - every link or image pointing at /wp-content/ or /2/wp-content/ is a real file;
  - no file in the change is over 100 MB (GitHub refuses those).

Prints one line per problem and exits 1 if there are any.
"""
import datetime as dt
import re
import subprocess
import sys
from pathlib import Path
from urllib.parse import unquote

ROOT = Path(__file__).resolve().parent.parent
CONTENT = ("_posts/", "pages/", "_facts/")


def slugs(name):
    text = (ROOT / "_data" / name).read_text(encoding="utf-8")
    return set(re.findall(r"^([^\s#][^:]*):\s*$", text, re.M))


def changed_files():
    base = subprocess.run(["git", "merge-base", "HEAD", "origin/main"], cwd=ROOT,
                          capture_output=True, text=True).stdout.strip() or "origin/main"
    out = subprocess.run(["git", "diff", "--name-only", "--diff-filter=AMR", base], cwd=ROOT,
                         capture_output=True, text=True).stdout.splitlines()
    out += subprocess.run(["git", "ls-files", "--others", "--exclude-standard"], cwd=ROOT,
                          capture_output=True, text=True).stdout.splitlines()
    return sorted(set(out))


def parse_list(value):
    value = value.strip()
    if value.startswith("["):
        return [v.strip().strip('"').strip("'") for v in value.strip("[]").split(",") if v.strip()]
    return [value.strip('"').strip("'")] if value else []


def base_text(rel):
    """The file as it is on the live site (origin/main), or None if it is new."""
    r = subprocess.run(["git", "show", f"origin/main:{rel}"], cwd=ROOT, capture_output=True)
    return r.stdout.decode("utf-8", "replace") if r.returncode == 0 else None


def check(path, cats, tags, now):
    """Problems in this file that are not already on the live site."""
    rel = path.relative_to(ROOT).as_posix()
    problems = []
    if path.stat().st_size > 100 * 1024 * 1024:
        problems.append(f"{rel}: over 100 MB; GitHub will refuse it. Compress it first.")
    if not rel.startswith(CONTENT) or path.suffix not in (".md", ".html"):
        return problems
    found = check_text(rel, path.name, path.read_text(encoding="utf-8", errors="replace"), cats, tags, now)
    old = base_text(rel)
    if old is not None:
        # Old WordPress content has some broken links already; only report new problems.
        found = [p for p in found if p not in set(check_text(rel, path.name, old, cats, tags, None))]
    return problems + found


def check_text(rel, name, text, cats, tags, now):
    problems = []
    m = re.match(r"---\n(.*?)\n---\n", text, re.S)
    if not m:
        return problems + [f"{rel}: must start with a front matter block (--- ... ---)."]
    fm = {}
    for line in m.group(1).splitlines():
        k, sep, v = line.partition(":")
        if sep and not line.startswith((" ", "-")):
            fm[k.strip()] = v.strip()
    body = text[m.end():]

    if not fm.get("title", "").strip('"'):
        problems.append(f"{rel}: has no title.")

    if rel.startswith("_posts/"):
        fn = re.match(r"(\d{4}-\d{2}-\d{2})-[a-z0-9][a-z0-9-]*\.(md|html)$", name)
        if not fn and name.endswith(".md"):
            problems.append(f"{rel}: name must be YYYY-MM-DD-short-title.md, lower case, hyphens only.")
        date = fm.get("date", "").strip('"')
        try:
            when = dt.datetime.strptime(date, "%Y-%m-%d %H:%M:%S %z")
        except ValueError:
            problems.append(f"{rel}: date must look like 2026-12-01 10:00:00 -0600 (got {date!r}).")
            when = None
        if when and fn and when.strftime("%Y-%m-%d") != fn.group(1):
            problems.append(f"{rel}: date {date} does not match the file name.")
        if when and now and when > now:
            problems.append(f"{rel}: date {date} is in the future; the post would not appear.")
        for c in parse_list(fm.get("categories", "")):
            if c not in cats:
                problems.append(f"{rel}: unknown category {c!r} (see _data/categories.yml).")
        for t in parse_list(fm.get("tags", "")):
            if t not in tags:
                problems.append(f"{rel}: unknown tag {t!r}; add it to _data/tags.yml or pick an existing one.")

    for link in re.findall(r"""(?:src|href)=["'](/(?:2/)?wp-content/[^"'#?]+)""", body) + \
            re.findall(r"""\]\((/(?:2/)?wp-content/[^)\s#?]+)""", body):
        target = ROOT / unquote(link).lstrip("/")
        if not target.exists():
            problems.append(f"{rel}: links to {link}, but that file is not in the repository.")
    return problems


def main(args):
    now = dt.datetime.now(dt.timezone.utc)
    cats, tags = slugs("categories.yml"), slugs("tags.yml")
    paths = [Path(a).resolve() for a in args] if args else [ROOT / f for f in changed_files()]
    problems = []
    for p in paths:
        if p.is_file():
            problems += check(p, cats, tags, now)
    for line in problems:
        print(line)
    if not problems:
        print(f"OK: {len(paths)} file(s) checked, no problems.")
    return 1 if problems else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
