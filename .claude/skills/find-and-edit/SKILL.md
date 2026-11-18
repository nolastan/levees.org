---
name: find-and-edit
description: Use when Sandy (or anyone non-technical) wants something changed on an existing page or post of levees.org, described in plain words ("the board page", "my post about the bike tour", "the phone number at the bottom"). Finds the right file and makes a careful, minimal edit.
---

# Find and edit a page or post

Read `docs/working-with-sandy.md` first if you haven't this session. Talk to her in
plain words only.

## 1. Start from the live version

Follow `preview-and-publish` step 1 (fresh copy of the live site) before editing.

## 2. Find what she means

She'll describe it, not name a file. Work out the page yourself:

- **She gave a link** (levees.org/…, or a preview link): `python3 scripts/find_page.py <link>`.
- **She named a page or post**: `python3 scripts/find_page.py some title words`.
  Titles in files use HTML entities (`&#8217;` for ’); the script handles that.
- **She quoted text from it**: `python3 scripts/find_page.py some words --body`, or
  `grep -rl "exact phrase" pages _posts _facts _includes _data index.html`.
  WordPress text has `&#8217;` / `&#8220;` / `&#8221;` / `&amp;` instead of ’ “ ” &;
  search for a distinctive word without punctuation.
- **"My post about X"**: newest posts first. If several match, pick the likeliest and
  ask: "Do you mean *Title* from July 21, 2026?"
- **Something on every page** (header, menu, sidebar, footer, signup box):
  - top menu, "Press" and "Quick Links" sidebar menus: `_data/menus.yml`
  - header (logo, "Join Levees.Org", "Get the book" button): `_includes/header.html`
  - sidebar (signup form, archives, search): `_includes/sidebar.html`
  - footer: `_includes/footer.html`
  - the home page: `index.html` (its News list updates by itself)
  - "Levees facts" boxes: `_facts/`
- **Archive pages** (/blog/, /category/…, /tag/…, /2026/07/) are made automatically
  from posts. To change what one shows, change the posts.

If you can't find it in a couple of tries, ask her for the link: "Could you send me the
link to that page? Open it and copy the address at the top."

## 3. Make the smallest correct change

- Change only what she asked. Don't reformat, re-indent or "tidy" the HTML around it.
- Files copied from WordPress are HTML: keep them HTML. Use the same entities the file
  already uses (`&#8217;` for ’, `&amp;` for &) or the plain characters; both are fine.
- Keep curly quotes and apostrophes (’ “ ”).
- **Links**: a link to another page on the site is relative (`/donate/`), never
  `https://levees.org/donate/`. External links in posts open in a new tab:
  `<a href="https://…" target="_blank" rel="noopener">`.
- **Never change `permalink:`** or rename a file in `pages/` or `_posts/`: old links
  around the web would break. If she wants a different web address, that's for Stan.
- **Editing a post's opening paragraph**: lists and link previews use `excerpt:` and
  `description:` in the front matter, copied from the old text. Update both to match
  the new opening (`excerpt:` is HTML in a `<p>…</p>`, `description:` is plain text,
  about 1 to 2 sentences, no HTML).
- **Titles**: change `title:` in the front matter, keep curly quotes; the web address
  stays the same.
- **Menus**: edit `_data/menus.yml`. Keep `id`s. A new item needs a unique `id` (use a
  number above the largest one in the file); add `page_id` only if linking to a page
  that has a `wp_id`.
- **Removing a whole page or post**: don't delete the file. Ask Stan (see "When you're
  stuck" in `docs/working-with-sandy.md`); deleting breaks links.
- Leave `last_modified_at:` alone unless you're editing the post text itself; then set
  it to now (`TZ=America/Chicago date '+%Y-%m-%d %H:%M:%S %z'`).

## 4. Check and preview

Go to `preview-and-publish` step 3. When you show her the preview, say exactly what
changed, quoting the old and new words for a text change.
