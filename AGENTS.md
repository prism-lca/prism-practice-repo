# Agent instructions

## Working on an issue: branch, plan, test, fix

Every issue is fixed on its own branch, with an approved plan committed before
the fix, and built test-first (test-driven development, TDD): each acceptance
criterion gets an automated test that is shown failing before the code that
makes it pass. The people you work with may not be programmers. They say what
"working" means in plain English; you write the tests and the code, and prove
each step. Elena or Calvin assign issues, review pull requests and merge them.
Don't commit or push to `main`, and don't merge a pull request, unless a code
owner (a member of `@prism-lca/maintainers`, see `.github/CODEOWNERS`) asks
you to commit or push a specific change directly to `main`.

Using issue #23 as the example:

1. **Branch.** When you pick up an issue, show the person its title and
   description and ask whether to start. Once they say yes, tell them you're
   creating `issue-23-branch` and why (each issue gets its own branch), then
   create it from an up-to-date `main` if it doesn't exist. If the work
   started on an experiment branch, see "Starting from an experiment" below.
2. **Plan before the fix.** Read the issue and the relevant code, then draft
   `plans/issue-23-plan.md` from the template below. Don't change any code in
   this step. Write each acceptance criterion as a Given/When/Then scenario
   that can be checked yes or no; if the issue is vague, ask questions until
   the person agrees with every scenario. Show the plan to the person you're
   working with so they can edit it. Commit and push it only once they approve, before any more code
   changes. On a branch made from `main` it is the first commit; on a branch
   copied from an experiment it comes after the experiment's commits.
3. **Test, then fix, one criterion at a time.** For each acceptance
   criterion, in order:
   - **Red.** Write one automated test for it. Run it, show the person that it
     FAILS, and say in one sentence why. Commit the test, e.g.
     `#23: test that methane counts 25x`. Never write the code for a
     criterion before its test has been seen failing.
   - **Green.** Write the smallest change that makes the test pass. Run all
     the tests, show the result, and commit, e.g. `#23: count methane at 25x`.
   - **Tidy.** Clean up the code if needed, keeping every test passing.

   Push as you go, and start each commit message with the issue number. When
   all criteria pass, tell the person to test each one by hand too: run the
   app or the calculation and check it themselves. Passing tests aren't enough
   on their own; the hand check catches a test that checks the wrong thing.
   - **Tests are the person's agreement.** Never weaken, skip or delete a test
     to make it pass. If a test seems wrong, stop and ask, then change the
     plan first (see below).
   - Name each test after the rule it checks, in plain words (e.g.
     `20% off $50 is $40.00`), and report results the same way: "Rule 1
     failed: expected 40, got 0". For each test, explain in plain English what
     it checks and how it could still pass while the code is broken.
   - See "Running tests" below for where tests go and how to run them.
   - If the plan turns out to be wrong, commit the change to the plan first,
     then the code. The plan must always describe what was actually built.
4. **Pull request.** Open a PR from `issue-23-branch` into `main`. The
   description must include `Fixes #23`, a link to the plan, the output of
   the final `pytest` run, and a short note on how it was tested by hand. Ask the person how they tested it rather than
   guessing.
5. **Review.** Requested changes become more commits on the same branch. Use
   the branch only for changes to this pull request; new work gets its own
   branch. After the merge, the plan stays in `plans/` as the record of why the
   change was made; the pull request shows which commits made it.
6. **Clean up.** After the merge, GitHub deletes the branch on GitHub. Delete
   the local copy too: switch to `main`, pull, and run
   `git branch -d issue-23-branch`. If git refuses because the pull request was
   squashed or rebased, check on GitHub that it shows as merged before using
   `git branch -D issue-23-branch`. Never delete a branch whose pull request
   is still open.

### Starting from an experiment

Anyone can experiment on a branch without an issue, e.g. `dark-mode`. Never
open a pull request from an experiment branch; only a code owner may merge one
into `main`. When the person wants to keep some of the work:

1. **Issue.** They write an issue for it, e.g. #23, as for any other change.
2. **Copy the branch.** Update the experiment branch with the latest `main`,
   then create `issue-23-branch` from it. Leave the experiment branch as it
   is.
3. **Carry on** from step 2 (Plan before the fix) above. The pull request comes
   from `issue-23-branch`, so GitHub deletes that branch after the merge and
   keeps the experiment branch.

They can keep working on the experiment branch after the merge. Each later
piece of work they want to keep gets a new issue and a new issue branch copied
from it the same way.

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

## Tests
(one automated test per acceptance criterion, in the same order, each
named in plain words; each is shown failing before its code is written)
1. …
2. …

## Testing steps
(numbered steps a person follows by hand to check each acceptance criterion)
```

Write the plan in plain language: the owner and reviewers may not be
programmers. When the fix is done, tick the acceptance criteria the person
has confirmed.

### Running tests

Use the tools that are already installed (see `setup_local_tools.sh`). Don't
add a test framework or a `package.json` unless the issue asks for one.

- **Web pages (HTML and JavaScript).** Keep the calculation or logic in its
  own `.js` file next to the page (e.g.
  `test-driven-development-example/diana/sale.js`), so it can be tested
  without a browser; `index.html` loads it with a `<script>`
  tag. End the `.js` file with
  `if (typeof module !== "undefined") module.exports = { salePrice };`
  (listing its own functions) so both the page and the tests can use it.
  Put the tests beside it in a file ending `.test.js`, using Node's
  built-in test runner (`node:test` and `node:assert`), and run them with
  `node --test <folder>/*.test.js` (e.g.
  `node --test test-driven-development-example/diana/*.test.js`). The
  screen itself is checked by hand.
- **Python.** Put tests in `tests/` and run them with `pytest`.

Each project lives in its own folder, named in the issue. For a finished
example of a test-first project, see `test-driven-development-example/diana/`
and its plan, `plans/issue-59-plan.md`.

## Teams

| Team | Covers | Main repo |
| :--- | :--- | :--- |
| Product & UI | Screens, workflows, the AI chat panel, responsive design | `product-graph-editor` |
| Engine & Data | Calculation engine, MCP/REST server, background databases, import/export, deployment | `life-cycle-assessment-mcp` |
| Product Design, Testing & Docs | Case studies, tests and CI, documents and skills | `lca-mock-tests`, `agentic-lca` |
