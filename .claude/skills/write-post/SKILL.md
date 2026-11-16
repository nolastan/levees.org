---
name: write-post
description: Use when Sandy wants to write or publish a new news post (blog post, article, announcement) on levees.org. Turns her text, links, photos and videos into a post in the site's format, previews it and publishes on her yes.
---

# Write a new news post

Read `docs/working-with-sandy.md` first if you haven't this session.

## 1. Gather what you need (without a questionnaire)

From her message, take: the text, a headline (if she gave one), any links, photos or
videos. Don't ask for anything you can sensibly fill in:

| Needed | If she didn't say |
| --- | --- |
| Headline | Write a short, factual one from her first paragraph, in the style of recent posts (see `ls _posts | tail -20`), and tell her what you chose. |
| Date | Now, New Orleans time. Never a future time: future posts don't appear. |
| Author | `S. Rosenthal` (every recent post uses it). |
| Topics | Pick yourself (below). Don't ask her. |
| Photo position | On the right, medium size, like her other posts. |

Ask only if the text itself is missing or unclear. Never add facts, quotes or links
she didn't give you.

## 2. Create the file

Start from a fresh copy of the live site (`preview-and-publish` step 1). Then:

```sh
TZ=America/Chicago date '+%Y-%m-%d %H:%M:%S %z'     # e.g. 2026-12-01 10:05:00 -0600
```

File: `_posts/YYYY-MM-DD-short-title.md`, using today's date (Central) and a short,
lower-case, hyphenated version of the headline (no apostrophes or punctuation; at most
about eight words). The web address will be `/YYYY/MM/DD/short-title/`; check that no
post already has it.

```markdown
---
title: "Levee board meets on flood wall repairs"
date: 2026-12-01 10:05:00 -0600
author: "S. Rosenthal"
categories: [uncategorized]
tags: [army-corps-of-engineers, levee-board]
description: "One or two plain sentences from the opening, for search engines and link previews."
---

First paragraph.

Second paragraph.
```

- **Headline**: curly quotes and apostrophes (’ “ ”), sentence case like recent posts.
- **Category**: almost always `[uncategorized]` (as on WordPress). Use others from
  `_data/categories.yml` only if she asks.
- **Tags** ("topics"): two to five existing slugs from `_data/tags.yml` that clearly
  fit. Common ones: `army-corps-of-engineers`, `hurricane-katrina`, `levees`,
  `levee-board`, `flooding`, `new-orleans`, `slfpa-east`. Search the file for names in
  her post (`grep -n -i "landry" _data/tags.yml`). To add a new tag for a person or
  organization she mentions, add it to `_data/tags.yml` in alphabetical order with the
  next unused `id` (`grep -o 'id: [0-9]*' _data/tags.yml | sort -t' ' -k2 -n | tail -1`)
  and a `name`.
- **description**: plain text, no HTML, under about 300 characters, taken from her
  opening. Don't add claims.
- **Body**: plain paragraphs separated by blank lines. Keep her words. Bold is
  `**word**`, links are `[text](https://…)`; HTML is allowed too, so for links that
  should open in a new tab (her usual), write
  `<a href="https://…" target="_blank" rel="noopener">text</a>`.
- **Read more**: lists show the whole post unless it has a break. For long posts, put
  `<!--more-->` at the end of the first paragraph (as recent posts do), right after the
  last word, no space.
- **Video (YouTube)**: put the plain link on its own line as a link, as recent posts do:
  `<p><a href="https://www.youtube.com/watch?v=…" target="_blank" rel="noopener">https://www.youtube.com/watch?v=…</a></p>`
- **Photo**: see `add-image-or-pdf`. Put the caption block before the paragraph it
  should sit beside (usually first).

## 3. Check and preview

Go to `preview-and-publish` step 3. When you show her the preview, also tell her the
headline you used and that it will appear at the top of the News list and on the
home page.

## Editing a post she just published

Same file; use `find-and-edit`. Don't change its date or file name, or the address
changes.
