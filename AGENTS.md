# Agent instructions

## Git workflow

`main` is protected. Changes reach `main` only through a pull request
approved by a maintainer.

- Before making changes, create a branch: `git checkout -b <short-description>`.
- Commit to that branch and push it: `git push -u origin <branch>`.
- Open a pull request with `gh pr create`. In the description, write
  `Fixes #<issue>` if the work is for an issue.
- If a push to `main` is rejected (`GH013: Repository rule violations`),
  move the commits to a new branch and open a pull request:
  `git checkout -b <branch> && git push -u origin <branch> && gh pr create --fill`
- Never force-push, and never try to work around the protection.
