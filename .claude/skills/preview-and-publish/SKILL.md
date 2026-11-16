---
name: preview-and-publish
description: Use for every change Sandy makes to levees.org - starting from the live version, checking the change, showing her a preview link, publishing (merging) when she says yes, confirming it is live, undoing a change, and recovering when a check, preview or publish fails.
---

# Preview and publish

Read `docs/working-with-sandy.md` first if you haven't this session. Everything below
is invisible to her: she sees a preview link, a question, and a "it's live" link.

How publishing works (for you, never for her): each change is a pull request on
`nolastan/levees.org`. Netlify builds a **deploy preview** for every pull request.
Merging into `main` runs `.github/workflows/deploy.yml`, which publishes the site to
GitHub Pages at the domain in the `CNAME` file (that file is the live address; it may
still be `learn.levees.org` before the switch from WordPress). Her changes need no one
else's approval: her clear yes is the approval.

## 1. Start from the live version

At the start of each new request (not each follow-up tweak to the same change):

```sh
git fetch origin main
git status --short                 # should be clean; if not, see below
```

- If your session names a branch to work on, use it; otherwise use
  `sandy/<two-or-three-words>`. Create or reset it from `origin/main`
  (`git checkout -B <branch> origin/main`) **unless** it holds unpublished work for
  this same change.
- If the branch's earlier pull request was already merged, start it again from
  `origin/main`.
- Leftover changes you didn't make in this conversation: don't throw them away. Look
  at them, and if they're an unfinished change of hers, ask: "I found an unfinished
  change to *page*. Would you like to finish it or drop it?"

## 2. Make the change

Use `find-and-edit`, `write-post` and `add-image-or-pdf`.

## 3. Check it

```sh
scripts/check.sh
```

It checks the changed posts and pages (topics exist, date not in the future, pictures
and documents really exist), then builds the whole site like the live one. It must end
with `OK: the site builds.` Fix every problem yourself and run it again. Never tell her
about these messages. Common fixes:

| Message | Fix |
| --- | --- |
| `unknown tag` / `unknown category` | Use a slug from `_data/tags.yml` / `_data/categories.yml`, or add the tag (see `write-post`). |
| `date … is in the future` / `does not match the file name` | Use `TZ=America/Chicago date '+%Y-%m-%d %H:%M:%S %z'` and rename the file to match. |
| `links to /2/wp-content/…, but that file is not in the repository` | Wrong folder or name; fix the link or add the file. |
| `YAML Exception` / `could not find expected ':'` | A title or description has a straight `"` inside double quotes. Use curly quotes “ ” or `\"`. |
| `bundler: command not found` / gems missing | `bundle install`, then run again. |
| Liquid errors | Shouldn't happen in posts and pages (Liquid is off there). If you edited `_includes/` or `_layouts/`, check `{% %}` / `{{ }}` balance. |

Then look at the page yourself before showing her. Build output is in `_site/`; to see
it, serve it and take a screenshot:

```sh
(cd _site && python3 -m http.server 4000 >/dev/null 2>&1 &)
node -e "const {chromium}=require('playwright');(async()=>{const b=await chromium.launch();const p=await b.newPage({viewport:{width:1200,height:1000}});await p.goto('http://localhost:4000/PATH/');await p.screenshot({path:'/tmp/preview.png'});await b.close()})()"
```

Compare with the live page if it's an edit: only the requested part should differ.

## 4. Send it for preview

```sh
git add -A && git commit -m "Board page: remove Pat Example"   # plain-English message
git push -u origin <branch>
```

Open a pull request (GitHub tools, or `gh pr create` if that's what you have) against
`main`, ready for review, not a draft. Title: the plain change ("New post: Levee board
meets on flood wall repairs", "Board page: remove Pat Example"). Body: what changed,
the page link, and "Requested by Sandy in chat." If the session gives PR attribution
lines, include them. One pull request per change; later tweaks to the same change go
on the same branch.

**Get the preview link.** Netlify takes about two minutes. It reports on the pull
request as a commit status / check named like `netlify/<site>/deploy-preview` whose
link is the preview, and posts a comment "Deploy Preview for … ready!". Read the pull
request's status or comments to get it. The address looks like
`https://deploy-preview-<PR number>--<site>.netlify.app`. Add the page's path so she
lands on the exact page, e.g. `…netlify.app/board-of-directors-and-advisors/`.

Before sending it, open the preview link yourself (`curl -fsS <link> | grep "<new
words>"`) to be sure it shows the change.

If the preview fails or doesn't appear within about ten minutes but `scripts/check.sh`
passed, don't make her wait: show her your screenshot from step 3 instead (attach the
image; in a Claude project, save it under `/mnt/project-files/previews/` and attach
it), and note the Netlify problem for Stan in an issue later.

**Message to her**: the link, what changed (quote old → new for text), and "Shall I
publish it?" Nothing else.

## 5. Publish on a clear yes

Only after she clearly says yes to *this* preview (see `docs/working-with-sandy.md`).
If she asks for changes instead, make them, run step 3, push to the same branch, wait
for the new preview and ask again.

1. Make sure the branch is still up to date: if `main` moved and the pull request
   can't merge cleanly, merge `origin/main` into the branch, run `scripts/check.sh`
   again, push.
2. Merge the pull request with **squash**.
3. Wait for the "Build and deploy" run on `main` to finish (GitHub Actions; usually 2 to
   4 minutes). Check the latest run for the merge commit.
4. Check the live page yourself: `curl -fsS "https://$(cat CNAME)/<path>/" | grep "<new
   words>"`. GitHub Pages can take another minute to show it.
5. Tell her: "It's live: <link>". If it's a new post, also mention it's on the News
   page and the home page. Add "If you still see the old version, close the page and
   open it again."

## Undo

If she wants a published change taken back ("undo that", "put it back the way it
was"), that request is her yes to restoring the earlier version:

```sh
git fetch origin main && git checkout -B <branch> origin/main
git revert --no-edit <the merge commit of her change>
scripts/check.sh
```

Push, open a pull request titled "Undo: <original title>", merge it, check it's live
(step 5), and tell her it's back the way it was, with the link. If she only wants part
of it undone, treat it as a normal edit with a preview.

## When publishing fails

The live site only changes when a publish succeeds, so a failure never breaks the
website: the previous version stays up. Tell her calmly, only if it delays her:
"It's taking a little longer than usual; I'm on it."

1. Read the failed run's logs (GitHub Actions: list runs of `deploy.yml`, get the
   failed job's logs).
2. **Content problem** (the same kind of messages as step 3): fix it on a new branch
   from `origin/main`, run `scripts/check.sh`, open a pull request "Fix: …", and merge
   it. Her earlier yes covers fixing her own change so it looks the way she approved;
   ask again only if the fix changes what she'll see.
3. **Temporary problem** (network timeouts, "rate limit", GitHub or Pages outage,
   `deploy-pages` errors): re-run the failed run once after a few minutes.
4. **Anything else, or it fails twice**: follow "When you're stuck" in
   `docs/working-with-sandy.md` (issue for `nolastan` with the log excerpt and links),
   and tell her Stan will finish it and the website is fine meanwhile.

Never force-push to `main`, rewrite history, change the workflow, or turn off checks to
get a change out.
