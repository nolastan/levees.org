# Agent instructions for learn.levees.org

This repository is the source for **learn.levees.org**, an evergreen, lesson-based companion to [levees.org](https://levees.org). It is a static Jekyll site built and hosted by GitHub Pages.

**Before writing or editing any text, read [`docs/WRITING_GUIDE.md`](docs/WRITING_GUIDE.md).** It defines the voice, the words we never use ("Katrina shorthand"), the standard facts and numbers, and the lesson structure. Content accuracy is the entire point of this site: never invent a fact, quote, date or statistic.

## Repository map

| Path | What it is |
| --- | --- |
| `_config.yml` | Site settings. The `lessons` collection outputs to `/lessons/<file-name>/`. |
| `_lessons/*.md` | One file per lesson. Order comes from the `order:` front matter; grouping from `part:`. |
| `_data/parts.yml` | The four parts that group lessons. |
| `_data/myths.yml` | Myth/truth pairs rendered on `/myths/`. |
| `_data/timeline.yml` | Timeline entries rendered on `/timeline/`. |
| `_data/glossary.yml` | Glossary terms rendered on `/glossary/` (sorted automatically). |
| `_data/studies.yml` | Major investigations rendered on `/library/`. |
| `_data/quiz.yml` | Quiz questions rendered on `/quiz/`. `answer` is a zero-based index. |
| `_data/navigation.yml` | Top navigation. `secondary: true` items collapse into the "More…" drawer on small screens. |
| `_layouts/default.html` | Page shell: head, header, nav, footer. |
| `_layouts/lesson.html` | Lesson template: hero, "The short version," body, "Go deeper," sources, prev/next. |
| `_includes/figure.html` | Captioned, credited image. Use it for every photo. |
| `_includes/lesson-card.html` | Lesson card used on the home page and `/lessons/`. |
| `assets/css/site.css` | All styles. Design tokens are CSS variables at the top. |
| `assets/images/` | Images copied from levees.org, resized to ≤1400px wide. |
| `index.html`, `lessons.html`, `myths.html`, `timeline.html`, `glossary.html`, `library.html`, `quiz.html`, `visit.html`, `about.md`, `404.html` | Top-level pages. |
| `CNAME` | Custom domain: `learn.levees.org`. Do not remove. |
| `docs/` | Documentation for contributors. Excluded from the build. |

## Common tasks

### Add or edit a lesson

1. Copy an existing file in `_lessons/` and give it a short kebab-case name; the file name becomes the URL.
2. Fill in every front matter field (see the writing guide, section 5). Set `order:` and renumber later lessons if you insert one in the middle.
3. Draw the text from Levees.org posts. Find them with the WordPress API: `https://levees.org/wp-json/wp/v2/posts?search=<term>&per_page=20`. Link every post you used in `further:`.
4. Link between lessons with `{{ '/lessons/<slug>/' | relative_url }}`.

### Add an image

Download the original (strip WordPress size suffixes like `-300x200` to get the full size), resize to at most 1400px wide, save as JPEG in `assets/images/` with a descriptive kebab-case name, and use `_includes/figure.html` with the photographer credit from the original caption (e.g. `credit="Photo/Andy Levin"`).

### Add a myth, timeline entry, glossary term, study or quiz question

Edit the matching file in `_data/`. Each file has a comment at the top describing its fields. Keep wording consistent with the standard facts table in the writing guide.

## Build and check

GitHub Pages builds the site automatically from the default branch. To preview locally:

```sh
bundle install          # first time only (uses the github-pages gem)
bundle exec jekyll serve
```

Or, with plain Jekyll 3.10 plus `jekyll-sitemap` and `kramdown-parser-gfm` installed: `jekyll build`.

Before committing, make sure:

- The build finishes with no warnings or Liquid errors.
- Every internal link and image resolves (`_site/` contains the target).
- No page contains Katrina shorthand. Quick check: `grep -rniE "katrina (flooded|destroyed|devastated)|natural disaster|wiped out by" _lessons/ *.html *.md` — any hit must be inside a quotation that is being corrected, or a myth that is labeled as a myth.

## Design rules

- Visual language comes from the levees.org "levees2023" theme: PT Serif Caption headings with a Playfair Display *italic* accent phrase, PT Sans Caption UI text, a light-green gradient nav bar, green pills and rounded cards. Long-form lesson text is set in PT Serif for readability.
- Keep pages fast: no frameworks, no build step beyond Jekyll, one small JS file. Inline scripts only where a page needs interactivity (the quiz).
- Every image needs meaningful `alt` text and a credit.
- Must work at phone widths (16px side gutter, no horizontal scroll).
