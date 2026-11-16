# Agent instructions for levees.org

This repository is **levees.org**, the website of Levees.Org, a nonprofit founded in
2005 by Sandy Rosenthal to educate the public on why the levees broke in New Orleans.
Until November 2026 it ran on WordPress. It is now a static Jekyll site that GitHub
Actions builds and publishes to GitHub Pages on every push to `main`.

## Who you are helping

The site is run by Sandy Rosenthal (founder) and her son Stanford ("Stan"). Sandy is
not a programmer. When working with her:

- Use plain language. Don't mention Jekyll, YAML, front matter, Liquid, git, branches
  or pull requests unless she asks. Say "the page", "the post", "publish".
- Do the technical work yourself: create the file, preview it, commit, open the pull
  request. Tell her what changed and give her a link to look at.
- Before anything goes live, show her the result (a preview link or a screenshot) and
  get a clear yes.
- Never invent a fact, quote, date or statistic. Accuracy is the point of this site.
  If something needs checking, say so and ask.

## The rule for now: keep it looking exactly like it did

The first goal was a pixel-for-pixel copy of the WordPress site. Change the design
only when asked, and change it gradually (for example, making pages work on phones).
Visitors shouldn't notice the move.

## Repository map

| Path | What it is |
| --- | --- |
| `_posts/` | Blog posts ("News"), one file per post: `YYYY-MM-DD-slug.html` (copied from WordPress) or `.md` (new). |
| `pages/` | Pages. The folder path mirrors the URL; each file sets `permalink:`. |
| `_facts/` | The six short "Levees facts" pages (`/levees_facts/...`). |
| `index.html` | The home page (its own Tailwind design, from the theme's `homepage.php`). The "News & Articles" list shows the three newest posts automatically. |
| `_layouts/` | Page templates. `classic.html` is the shared shell (header, menu, sidebar, footer); `post.html`, `page.html`, `archive.html`, `fact.html` fill it in. |
| `_includes/` | Pieces of the shell: `header.html`, `sidebar.html` (signup form, menus, archive list, search), `footer.html`, `comments.html`, `menu-items.html`. |
| `_data/menus.yml` | The top menu and the sidebar "Press" and "Quick Links" menus. |
| `_data/categories.yml`, `_data/tags.yml` | Category and tag names, keyed by slug. |
| `_data/comments/<wp_id>.yml` | Comments left on WordPress, per post. Comments are closed; these are shown read-only. |
| `_plugins/wordpress.rb` | Generates archive pages with WordPress's URLs (`/blog/`, `/category/x/`, `/tag/x/`, `/2026/`, `/2026/07/`, `/2026/07/21/`, three posts per page, `/page/N/`) and the WordPress date formats. |
| `search/index.html` | Site search (Pagefind index built after Jekyll; results styled like WordPress's). |
| `feed.xml` | RSS feed at `/feed/`. Old items keep their WordPress guids. |
| `shortlinks.json` | `?p=123` / `?page_id=123` → URL, used by the home page to forward old shortlinks. |
| `wp-content/`, `2/wp-content/` | Theme files and uploads at their original WordPress URLs. Old uploads live under `/wp-content/uploads/`, newer ones under `/2/wp-content/uploads/`. Both are real paths; keep them. |
| `reference/` | **Not published.** Unreviewed draft material from the retired learn.levees.org experiment. See `reference/README.md`. |
| `scripts/import_wordpress.py` | The one-time WordPress import, kept as a record. Don't re-run it over edited content. |
| `.github/workflows/deploy.yml` | Build and deploy. |

## Common tasks

### Write a new post

Create `_posts/YYYY-MM-DD-short-title.md`:

```markdown
---
title: "Headline as it should appear"
date: 2026-12-01 10:00:00 -0600
author: "S. Rosenthal"
categories: [uncategorized]
tags: [army-corps-of-engineers, hurricane-katrina]
description: "One or two sentences for search engines and link previews."
---

Body text in Markdown. Images: put the file in `2/wp-content/uploads/YYYY/MM/`
and link it as `/2/wp-content/uploads/YYYY/MM/name.jpg`.
```

- The URL becomes `/YYYY/MM/DD/short-title/` automatically.
- Use existing category and tag slugs from `_data/categories.yml` and `_data/tags.yml`.
  To add a tag, add it to `_data/tags.yml` (give it a new unique `id`).
- Use curly quotes and apostrophes (’ “ ”) in titles, as WordPress did.
- The excerpt in lists is the first 55 words unless you set `excerpt:` (HTML).
- For an image with a caption, copy the `wp-caption` markup from an existing post.

### Edit a page or post

Edit the file in `pages/` or `_posts/`. Content copied from WordPress is HTML; keep it
HTML. Liquid is turned off in these files (`render_with_liquid: false`), so `{{` in text
is safe.

### Change a menu

Edit `_data/menus.yml`. Items with `page_id` are links to pages and get highlighted
when you're on that page.

### Add a file (PDF, image)

Put it under `2/wp-content/uploads/YYYY/MM/` and link to `/2/wp-content/uploads/...`.
GitHub refuses files over 100MB; compress big PDFs first
(`gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook ...`).

## Build and check

```sh
bundle install
LANG=C.UTF-8 bundle exec jekyll serve      # http://localhost:4000 (search needs the next line)
npx pagefind@1.3.0 --site _site            # build the search index into _site/pagefind
```

`LANG=C.UTF-8` matters: some URLs contain curly apostrophes.

Before committing: the build finishes with no errors, and the pages you touched look
right next to the live site. Don't change URLs. Old links from around the web must
keep working.

## Things that are deliberately different from WordPress

- Comments are closed. Existing comments are shown; there's no comment form, and posts
  with no comments show no "Leave a comment" link.
- Search runs in the browser (Pagefind) at `/search/?s=...`; `/?s=...` forwards there.
- The Mailchimp signup form posts directly to Mailchimp (see `mailchimp:` in
  `_config.yml`). The "events in New Orleans" checkbox does nothing yet (issue #3).
- The Flickr photos in the footer are a fixed snapshot of the four latest photos.
- The footer still says "Powered by Wordpress" because it did before; change it when
  you're ready to change the design.
