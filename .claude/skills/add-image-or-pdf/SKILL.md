---
name: add-image-or-pdf
description: Use when Sandy sends a photo, screenshot, picture, PDF or other document to put on levees.org (in a post, on a page, or as a download link). Finds the file she attached, prepares it for the web and adds it in the site's WordPress style.
---

# Add a photo or document

Read `docs/working-with-sandy.md` first if you haven't this session.

## 1. Find the file she sent

Attachments arrive in different places depending on the app she's using. Look, newest
first, and identify files by content (names may have no extension):

```sh
ls -lt /mnt/project-files/uploads/hearth/ /mnt/user-data/uploads/ ~/uploads/ 2>/dev/null | head
file <path>                       # JPEG image / PNG image / PDF document / Microsoft Word …
```

If you can see a picture in the conversation but can't find it as a file anywhere, say:
"I can see your photo, but I need it as a file to put it on the website. Could you
attach it again using the paperclip button?" Never recreate or trace an image.

If she sends a link to a photo or document online, ask whether Levees.Org has the right
to use it before downloading it, unless it's clearly hers (her own site, her Flickr).

**A Word document or email with post text** is for its text: read it
(`pandoc file.docx -t plain`, or `python3 -c` with `zipfile` on `word/document.xml`)
and use the words. Only put the file itself on the site if she asks for a download.

## 2. Name it and put it in this month's folder

- Folder: `2/wp-content/uploads/YYYY/MM/` (today, Central time). Create it if needed.
- Name: short, lower case, hyphens, from what it is: `levee-board-meeting-dec-2026.jpg`,
  `corps-report-2026.pdf`. Never overwrite a file that already exists; add `-2`.
- Web address: `/2/wp-content/uploads/YYYY/MM/name.jpg`.

## 3. Prepare it

**Photos and screenshots** (JPEG, PNG, HEIC, WebP):

```sh
D=2/wp-content/uploads/2026/12; N=levee-board-meeting
# Full size: at most 1600 px on the long side, rotated upright, location data removed.
convert "$SRC" -auto-orient -resize '1600x1600>' -strip -quality 85 "$D/$N.jpg"
# Medium size shown in the post, 300 px wide, named like WordPress named them:
convert "$D/$N.jpg" -resize 300x "$D/$N-medium.jpg"
H=$(identify -format %h "$D/$N-medium.jpg"); mv "$D/$N-medium.jpg" "$D/$N-300x$H.jpg"
```

Keep PNG for screenshots with text (`-strip` still; save as `.png`). Convert HEIC and
WebP to `.jpg`. If ImageMagick isn't installed, use Python Pillow
(`ImageOps.exif_transpose`, `thumbnail((1600,1600))`, save without EXIF).

**PDFs**: keep as they are unless over 20 MB; then compress it (routine; no need to
mention it):

```sh
gs -sDEVICE=pdfwrite -dPDFSETTINGS=/ebook -dNOPAUSE -dBATCH -dQUIET -sOutputFile=out.pdf in.pdf
```

If `gs` isn't installed, install it (`apt-get install -y ghostscript`) or, failing that,
ask Stan. Nothing over 100 MB can go on the site; if it's still too big, ask Stan (see "When
you're stuck" in `docs/working-with-sandy.md`).

## 4. Put it on the page

**Photo with a caption** (her usual: medium size, on the right, links to the full size):

```html
<div class="wp-caption alignright" style="width: 310px"><a href="/2/wp-content/uploads/2026/12/levee-board-meeting.jpg"><img loading="lazy" decoding="async" class="size-medium" src="/2/wp-content/uploads/2026/12/levee-board-meeting-300x200.jpg" alt="Levee board members seated at a long table" width="300" height="200" /></a><p class="wp-caption-text">Caption text, in her words</p></div>
```

**Photo without a caption**:

```html
<a href="/2/wp-content/uploads/2026/12/name.jpg"><img loading="lazy" decoding="async" class="alignright size-medium" src="/2/wp-content/uploads/2026/12/name-300x200.jpg" alt="…" width="300" height="200" /></a>
```

- `width`/`height` are the medium file's real size. Use `alignleft`, `aligncenter` or
  `alignnone` if she asks for another position; for "big", use the full-size file with
  `width="600"` and `aligncenter`.
- **Caption**: her words. If she gave none, ask once: "Would you like a caption under the
  photo?" Never name people in a caption or alt text unless she named them.
- **Alt text**: a short plain description of what's in the picture, for blind
  visitors. Don't guess identities.
- In a post, put the photo block on its own line before the paragraph it sits beside.

**PDF or document link**:

```html
<a href="/2/wp-content/uploads/2026/12/corps-report-2026.pdf" target="_blank" rel="noopener">Read the report (PDF)</a>
```

## 5. Check and preview

`scripts/check.sh` confirms every `/2/wp-content/…` link points at a real file. Then
`preview-and-publish` step 3. In the preview message, say where the photo is ("on the
right, next to the first paragraph").
