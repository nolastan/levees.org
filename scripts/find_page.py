#!/usr/bin/env python3
"""Find the file behind a page or post on levees.org.

Usage:
  python3 scripts/find_page.py https://levees.org/donate/
  python3 scripts/find_page.py /2026/07/21/is-new-orleans-ready-for-hurricane-season-2026/
  python3 scripts/find_page.py board of directors
  python3 scripts/find_page.py "hurricane season" --body     # also search the text

A web address is matched against each file's permalink (or, for new posts, the
address Jekyll gives them). Words are matched against titles, and with --body
against the text as well. Results are ranked: title matches first, newest first.
"""
import re
import sys
import unicodedata
from pathlib import Path
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parent.parent
FOLDERS = ["pages", "_posts", "_facts"]
EXTRA = ["index.html"]


def front_matter(text):
    m = re.match(r"---\n(.*?)\n---\n?(.*)", text, re.S)
    if not m:
        return {}, text
    fm = {}
    for line in m.group(1).splitlines():
        k, sep, v = line.partition(":")
        if sep and not line.startswith(" "):
            fm[k.strip()] = v.strip().strip('"').strip("'")
    return fm, m.group(2)


def fold(s):
    s = unquote(s)
    s = s.replace("&#8217;", "’").replace("&#8216;", "‘").replace("&#8220;", "“").replace("&#8221;", "”")
    s = s.replace("’", "'").replace("‘", "'").replace("“", '"').replace("”", '"')
    s = unicodedata.normalize("NFKD", s).lower()
    return s.replace("'", "")  # "didnt" finds "didn’t"; old links drop the apostrophe


def url_for(path, fm):
    if fm.get("permalink"):
        return fm["permalink"]
    m = re.match(r"(\d{4})-(\d{2})-(\d{2})-(.+)\.(md|html)$", path.name)
    if path.parent.name == "_posts" and m:
        return f"/{m[1]}/{m[2]}/{m[3]}/{m[4]}/"
    if path.parent.name == "_facts":
        return f"/levees_facts/{path.stem}/"
    if path.name == "index.html" and path.parent == ROOT:
        return "/"
    return ""


def files():
    for folder in FOLDERS:
        yield from sorted((ROOT / folder).rglob("*.html"))
        yield from sorted((ROOT / folder).rglob("*.md"))
    for name in EXTRA:
        yield ROOT / name


def main(argv):
    body = "--body" in argv
    words = [a for a in argv if a != "--body"]
    if not words:
        print(__doc__)
        return 2
    query = " ".join(words)
    looks_like_url = query.startswith(("http", "/", "levees.org", "www.")) and " " not in query

    results = []
    if looks_like_url:
        if query.startswith(("levees.org", "www.")):
            query = "//" + query
        path = urlparse(query).path or "/"
        path = "/" + path.strip("/") + "/" if path.strip("/") else "/"
        target = fold(path)
        for f in files():
            fm, _ = front_matter(f.read_text(encoding="utf-8", errors="replace"))
            if fold(url_for(f, fm)) == target:
                results.append((0, f, fm))
        if not results:
            print(f"No page or post has the address {path}")
            print("It may be an archive page (/blog/, /category/..., /tag/..., /2026/07/), which is made")
            print("automatically, or a file under /wp-content/ or /2/wp-content/.")
            return 1
    else:
        terms = [fold(w) for w in words]
        for f in files():
            text = f.read_text(encoding="utf-8", errors="replace")
            fm, content = front_matter(text)
            title = fold(fm.get("title", ""))
            if all(t in title for t in terms):
                results.append((0, f, fm))
            elif body and all(t in fold(content) for t in terms):
                results.append((1, f, fm))
        # Title matches first, then newest first.
        results.sort(key=lambda r: (r[0], [-ord(c) for c in r[2].get("date", "")[:19]]))

    for rank, f, fm in results[:40]:
        where = "title" if rank == 0 else "text"
        print(f"{f.relative_to(ROOT)}\n    title: {fm.get('title', '(home page)')}\n    url:   {url_for(f, fm)}"
              f"\n    date:  {fm.get('date', '')}   (matched {where})")
    if len(results) > 40:
        print(f"... and {len(results) - 40} more. Add words to narrow it down.")
    if not results:
        print("Nothing found." + ("" if body else " Try again with --body to search the text too."))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
