# learn.levees.org

The evergreen, lesson-based companion to [Levees.org](https://levees.org): the full and vetted story of why the levees broke in New Orleans during Hurricane Katrina, organized into fifteen short lessons, with myth busters, a timeline, a glossary, a library of the major investigations, a quiz, and a guide to visiting the breach sites.

Levees.org is an investigative public education nonprofit founded in 2005 by Sandy Rosenthal and her then-15yo son Stanford.

## How it's built

A static [Jekyll](https://jekyllrb.com) site, built and hosted by GitHub Pages with no custom build step.

- Lessons live in `_lessons/`, structured data (myths, timeline, glossary, studies, quiz) in `_data/`.
- Text and photographs come from Levees.org; see [`docs/WRITING_GUIDE.md`](docs/WRITING_GUIDE.md) for the voice and style rules every contributor (human or AI) must follow.
- See [`AGENTS.md`](AGENTS.md) for a map of the repository and common tasks.

### Preview locally

```sh
bundle install
bundle exec jekyll serve
# open http://localhost:4000
```

## Publishing on GitHub Pages

1. In the repository's **Settings → Pages**, set **Source** to "Deploy from a branch," choose the default branch and the `/ (root)` folder.
2. The `CNAME` file already sets the custom domain to `learn.levees.org`. In the DNS for levees.org, add a `CNAME` record for `learn` pointing to `<github-user-or-org>.github.io`.
3. Once DNS resolves, tick **Enforce HTTPS** in the Pages settings.

## Credits

Text © Levees.org. Photographs are credited on each page to the photographers who shared them with Levees.org. Design adapted from the levees.org theme by Stanford Rosenthal.
