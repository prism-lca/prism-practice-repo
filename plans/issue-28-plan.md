# Plan for issue #28: Kezia - Add your name to the README.md in this repo
Branch: issue-28-branch · Owner: Kezia

## Goal
Add Kezia's name to the list of team members in `README.md`, as the issue asks.

## Acceptance criteria
- [x] "Kezia Suteja" appears in the list of names in `README.md`.
- [x] Nothing else in the README has changed.

## What will change
We add one line, `- Kezia Suteja`, to the end of the list of names near the
top of `README.md`. We also tell Git to ignore `.DS_Store`, a hidden settings
file that macOS creates in folders, so it can't end up in the repo by accident.
This adds one line to `.gitignore`.

## Testing steps
1. On GitHub, open the pull request and go to "Files changed".
2. Check that `README.md` has one new line, `- Kezia Suteja`, in the list of
   names, and no other changes.
3. Open `README.md` on the branch `issue-28-branch` and check that your name
   shows up in the list.
