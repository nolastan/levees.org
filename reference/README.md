# Reference notes (unreviewed)

This folder is **not published**. It holds draft material from an earlier
experiment, `learn.levees.org`: a lesson-based retelling of why the levees broke
in New Orleans in 2005, written from Levees.org posts.

**Nobody at Levees.org has reviewed this text.** Treat it as research notes, not
as approved copy. Never publish it to the site as-is.

## How to use it

When improving a page on levees.org, an agent may look here for:

- a summary of a topic and the Levees.org posts it came from (`further:` and
  `sources:` in each lesson's front matter);
- standard facts and numbers, and words to avoid (`WRITING_GUIDE.md`);
- structured lists that could become pages later (`data/`).

Before using any fact from here, check it against the live post or source it
cites, and get the change approved like any other edit.

## What's here

| Path | Contents |
| --- | --- |
| `WRITING_GUIDE.md` | Voice, banned "Katrina shorthand", standard facts table, citation rules. |
| `lessons/*.md` | Fifteen lessons. Front matter: `title`, `order`, `part`, `summary`, `takeaways`, `further` (Levees.org posts used), `sources`. Body is plain Markdown. |
| `data/parts.yml` | The four parts that grouped the lessons. |
| `data/myths.yml` | Myth/truth pairs. |
| `data/timeline.yml` | Dated events, 1718 to the present. |
| `data/glossary.yml` | Glossary terms. |
| `data/studies.yml` | The major investigations and their findings. |
| `data/quiz.yml` | Quiz questions (`answer` is a zero-based index). |
| `pages/` | The learn site's home, about, library and visit pages (HTML/Markdown, Liquid removed where possible). |
| `images/` | Photos copied from levees.org, resized to 1400px wide. Credits are in the captions that use them. |

Links of the form `https://learn.levees.org/...` point to pages of the retired
learn site; the same content is in `data/`.
