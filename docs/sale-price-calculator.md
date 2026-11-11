# Practice project: a Sale Price Calculator, built test first

This is our first practice run of test-driven development (TDD) with a coding
agent. You don't write any code. You say what "correct" means, the agent
proves it, and you check the result yourself. The steps the agent follows are
in [AGENTS.md](../AGENTS.md).

## What we're building

A one-page website that works out sale prices. You type in a price and a
discount, and the page shows the sale price and how much you save.

Everyone builds the same calculator in their own folder, named after them:
`diana/`, `calvin/` and so on. Your page will be `<your-folder>/index.html`.
Only change files in your own folder.

The page has two parts, and the agent writes both:

- **The screen:** the boxes you type into and the price you see. You check
  this part yourself by using it.
- **The calculation:** the rules that turn a price and a discount into a sale
  price. This is the part the automated tests check, because a wrong price is
  the mistake that matters.

## The rules it has to follow

Each rule is an example with a real answer you can check on a phone
calculator. Each one becomes a test.

| # | Example | Correct answer | Why it's here |
| :- | :- | :- | :- |
| 1 | $50 with 20% off | $40.00 | The basic case |
| 2 | $19.99 with 15% off | $16.99 | The raw math gives $16.9915. Prices need whole cents. |
| 3 | A discount of 120% | The message "A discount can't be more than 100%" | A store can't pay you to take an item |

## What's a test?

Think of an answer key, written before anyone does the homework. You grade a
blank sheet first: it should be marked wrong, which proves the key can catch a
mistake. Then the real work is graded against the same key.

A test is that answer key, and the computer grades against it automatically.
**Red** means "wrong answer". **Green** means "matches the key". The rule:
**every rule shows red before it shows green.**

## How to try it

1. Pick up your issue for this project (for example "Diana - Build the
   Sale Price Calculator test first") and say to your agent:

   > Let's work on my Sale Price Calculator issue, following AGENTS.md and
   > docs/sale-price-calculator.md. Build it in my folder, diana/.

2. The agent shows you the issue, makes a branch, and writes a plan. It should
   ask you questions first, for example "Should $16.9915 round to the nearest
   cent, or always round down?" Answer them: these are questions about how the
   store works, not about code. Approve the plan when it says what you mean.
3. For each rule, in order, the agent:
   - writes the test and shows it **failing** (red), for example
     "Rule 1 failed: expected 40, got 0"
   - writes just enough of the calculation to make it **pass** (green), and
     re-runs all the tests
4. When all three rules are green, the agent builds the screen.
5. Open `index.html` from your folder in your browser and try it:
   - $50 and 20% → **$40.00**
   - $19.99 and 15% → **$16.99**
   - a discount of 120 → the error message
   - a price from a real receipt of your own
6. The agent opens a pull request with the test results and your notes on how
   you checked it.

## What to watch for

| | |
| :- | :- |
| ✅ Good | Every rule shows red before it shows green. |
| ✅ Good | Failure messages mention your numbers, like "expected 40, got 0". |
| ✅ Good | Every run re-checks all the earlier rules, not just the newest. |
| 🛑 Stop | The agent built something before showing you a failing test. |
| 🛑 Stop | The agent changed a rule or an expected answer to make it pass, without asking you. |
| 🛑 Stop | The agent says "all tests pass" but didn't show you the results. |

If you see a stop sign, say: "Stop. Go back and follow the test-first steps
in AGENTS.md."
