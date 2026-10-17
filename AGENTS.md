# Agent instructions

## Working on an issue: branch, plan, fix

Every issue is fixed on its own branch, and the branch's first commit is a
plan. Elena or Calvin assign issues, review pull requests and merge them.
Don't commit or push to `main`, and don't merge a pull request, unless a code
owner (a member of `@prism-lca/maintainers`, see `.github/CODEOWNERS`) asks
you to commit or push a specific change directly to `main`.

Using issue #23 as the example:

1. **Branch.** Work on `issue-23-branch`. Create it from an up-to-date `main`
   if it doesn't exist.
2. **Plan first, no code.** Read the issue and the relevant code, then draft
   `plans/issue-23-plan.md` from the template below. Don't change any code in
   this step. Show the plan to the person you're working with so they can edit
   it. Commit and push it only once they approve. It is the branch's first
   commit.
3. **Fix.** Implement the plan in small commits, pushing as you go. Start each
   commit message with the issue number, e.g. `#23: close open menu on window
   resize`. When you're done, tell the person to test each acceptance criterion
   by hand: run the app or the calculation and check it themselves.
   - If the plan turns out to be wrong, commit the change to the plan first,
     then the code. The plan must always describe what was actually built.
4. **Record the commits.** When the fix is done, fill in the plan's Commits
   section with the branch's commits (`git log --oneline main..HEAD`), and
   Files changed with the files the fix touched
   (`git diff --name-only main...HEAD`). Commit and push the updated plan.
5. **Pull request.** Open a PR from `issue-23-branch` into `main`. The
   description must include `Fixes #23`, a link to the plan, and a short note
   on how it was tested. Ask the person how they tested it rather than
   guessing.
6. **Review.** Requested changes become more commits on the same branch.
   Update the Commits and Files changed sections again after them. Use the
   branch only for changes to this pull request; new work gets its own branch.
   After the merge, the plan stays in `plans/` as the record of why the change
   was made and which commits made it.
7. **Clean up.** After the merge, GitHub deletes the branch on GitHub. Delete
   the local copy too: switch to `main`, pull, and run
   `git branch -d issue-23-branch`. If git refuses because the pull request was
   squashed or rebased, check on GitHub that it shows as merged before using
   `git branch -D issue-23-branch`. Never delete a branch whose pull request
   is still open.

### Plan template

```markdown
# Plan for issue #23: <issue title>
Branch: issue-23-branch · Owner: …

## Goal
(one or two sentences: what's wrong, or what we want, and why)

## Acceptance criteria
(copied from the issue: things someone can check yes or no)
- [ ] …
- [ ] …

## What will change
(a short, plain-language summary anyone on the team can follow)

## Testing steps
(numbered steps a person follows by hand to check each acceptance criterion)

## Commits
(filled in when the fix is done)

## Files changed
(filled in when the fix is done)
```

Write the plan in plain language: the owner and reviewers may not be
programmers. When the fix is done, tick the acceptance criteria the person
has confirmed.

## Teams

| Team | Covers | Main repo |
| :--- | :--- | :--- |
| Product & UI | Screens, workflows, the AI chat panel, responsive design | `product-graph-editor` |
| Engine & Data | Calculation engine, MCP/REST server, background databases, import/export, deployment | `life-cycle-assessment-mcp` |
| Product Design, Testing & Docs | Case studies, tests and CI, documents and skills | `lca-mock-tests`, `agentic-lca` |
