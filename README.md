# levees.org

The website of [Levees.Org](https://levees.org), an investigative public education
nonprofit founded in 2005 by Sandy Rosenthal and her then-15-year-old son Stanford.

Until November 2026 the site ran on WordPress. This repository is a static copy of it,
built with [Jekyll](https://jekyllrb.com) by GitHub Actions and published on GitHub
Pages. Every URL from the WordPress site works the same way here: posts, pages,
categories, tags, date archives, the RSS feed and uploaded files.

See [`AGENTS.md`](AGENTS.md) for how the repository is organized and how to write
posts, edit pages and preview the site.

## Preview locally

```sh
bundle install
LANG=C.UTF-8 bundle exec jekyll serve
# open http://localhost:4000
```

## Publishing

Pushing to `main` runs `.github/workflows/deploy.yml`, which builds the site, adds the
search index and deploys it. In **Settings → Pages**, the source must be
**GitHub Actions** and the custom domain set to the site's domain.

## Credits

Text © Levees.Org. Theme "levees2023" by Stanford Rosenthal.
