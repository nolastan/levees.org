# Setting up Claude editing for Sandy

A one-time checklist for Stan. When it's done, Sandy opens the Claude app, types what
she wants changed, looks at a preview link, says yes, and it's live. The instructions
Claude follows are in `AGENTS.md`, `docs/working-with-sandy.md` and `.claude/skills/`.

## 1. GitHub

- [ ] Create a GitHub account for her. GitHub requires two-factor authentication for
      accounts that push code; set it up with an authenticator you control, or a
      passkey on her device, so she's never asked for a code she doesn't have.
- [ ] Invite her to `nolastan/levees.org`: **Settings → Collaborators → Add people**,
      then accept the invite while signed in as her. On a personal repository,
      collaborators can push and merge, which is what Claude needs.
- [ ] If `main` has a branch protection rule or ruleset, make sure it doesn't require
      an approving review (her changes go live on her own yes). Status checks are fine
      to require only if Netlify's check is reliable.

## 2. Claude

- [ ] Create her Claude account on a plan that includes Claude Code (Pro or higher).
- [ ] While signed in as her on claude.ai, connect GitHub as her
      (https://claude.ai/connect-github). The Claude GitHub App is already installed on
      the repository; if Claude can't see it, add the repository to the app's
      installation at https://github.com/apps/claude/installations/select_target.
- [ ] Create a **project** for her (for example "Levees.Org website") with
      `nolastan/levees.org` as its only repository. A project with one repository is
      what makes the repo's `.claude/` settings apply, and photos she attaches arrive
      as files Claude can put on the site.
- [ ] Project instructions (paste this):

      > You are helping Sandy Rosenthal, founder of Levees.Org, update the levees.org
      > website. She isn't technical. Follow AGENTS.md and docs/working-with-sandy.md
      > in the repository: plain language only, do all technical work yourself, show her
      > a preview link, and publish when she says yes.

- [ ] Cloud environment for the project:
  - Setup script: nothing is required (`scripts/check.sh` installs the Ruby gems on
    first use). Optionally `apt-get install -y ghostscript` so Claude can compress big
    PDFs.
  - Network access must reach rubygems.org and the npm registry (to build), github.com,
    and, so Claude can check pages itself before showing her, `*.netlify.app` and the
    live domain (`learn.levees.org` now, `levees.org` after the switch). If the default
    "trusted" list blocks those, add them or use full access.

## 3. Netlify (previews only)

`netlify.toml` in the repository already has the build settings.

- [ ] In Netlify: **Add new site → Import an existing project → GitHub →
      nolastan/levees.org**. Leave the build settings empty; Netlify reads them from
      `netlify.toml`.
- [ ] **Site configuration → Build & deploy → Continuous deployment → Branches and deploy
      contexts**: Deploy
      Previews = *Any pull request*; Branch deploys = *None*.
- [ ] Keep the default GitHub notifications on (commit status and the "Deploy Preview
      ready" comment): Claude reads the preview link from them.
- [ ] Netlify will also publish `main` at `<site>.netlify.app`. That's harmless: every
      Netlify copy sends `noindex`, and links point to levees.org. You can rename the
      site to something recognizable under **Site configuration → Change site name**.
- [ ] Open the first pull request's preview and confirm it looks like the live site
      (search included).

## 4. Optional: fewer permission prompts

Claude in her project runs in auto mode, which allows most steps. If she ever sees a
permission prompt for routine steps, add `.claude/settings.json` to the repository
(I didn't add it myself because pre-approving publishing should be your call):

```json
{
  "permissions": {
    "allow": [
      "Bash(scripts/check.sh)",
      "Bash(python3 scripts/check_content.py *)",
      "Bash(python3 scripts/find_page.py *)",
      "Bash(bundle install)",
      "Bash(bundle exec jekyll *)",
      "Bash(git fetch *)", "Bash(git checkout *)", "Bash(git add *)",
      "Bash(git commit *)", "Bash(git revert *)", "Bash(git push -u origin *)",
      "Bash(convert *)", "Bash(identify *)", "Bash(gs *)",
      "mcp__github__create_pull_request",
      "mcp__github__pull_request_read",
      "mcp__github__merge_pull_request",
      "mcp__github__actions_list",
      "mcp__github__get_job_logs"
    ]
  }
}
```

## 5. Try it before handing over

Sign in as her and, in her project:

- [ ] "Please fix a typo on the contact page: …" (any tiny real fix). Check that Claude
      finds the page, shows a preview link, says nothing technical, publishes on "yes",
      and gives the live link.
- [ ] "Write a short post saying …" with a photo attached. Check the photo, topics and
      date, then say "undo that" and confirm it's gone.
- [ ] Glance at the pull requests it opened: plain titles, squash-merged.

## 6. Hand-off note for Sandy

> To change the website, open the Claude app and pick the **Levees.Org website**
> project. Start a new chat and say what you want, like you'd tell an assistant:
> "On the board page, take off Pat Example" or "Write a post about tonight's meeting"
> (attach photos with the paperclip). Claude shows you a preview link first. Nothing
> changes on the website until you say "yes, publish it". If you change your mind
> later, just say "undo that".

When something needs you, Claude opens a GitHub issue assigned to you and tells her
you'll take it from there.
