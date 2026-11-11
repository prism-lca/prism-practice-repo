# Plan for issue #59: Discount calculator for Diana
Branch: issue-59-branch · Owner: Diana (@dianalee3)

## Goal
Build Diana's copy of the practice project from
[docs/sale-price-calculator.md](../docs/sale-price-calculator.md): a one-page
Sale Price Calculator in `test-driven-development-example/diana/`. You type a
price and a discount, and the page shows the sale price and how much you save.
It is built test first: each rule gets a test that is seen failing before the
code that makes it pass.

## Acceptance criteria
- [ ] **Rule 1, the basic case.** Given a price of $50 and a discount of 20%,
      when the sale price is worked out, then it is $40.00.
- [ ] **Rule 2, whole cents.** Given a price of $19.99 and a discount of 15%,
      when the sale price is worked out, then it is $16.99 (the raw math gives
      $16.9915, which rounds to the nearest cent).
- [ ] **Rule 3, too big a discount.** Given a discount over 100% (for example
      120%), when the sale price is worked out, then there is no price and the
      message is "A discount can't be more than 100%".
- [ ] **Rule 4, nothing for free.** Given a discount of exactly 100%, when the
      sale price is worked out, then there is no price and the message is
      "A discount must be less than 100%". (Diana's decision: a store doesn't
      give items away through this calculator.)
- [ ] Each rule above has an automated test, and each test was seen failing
      before its code was written.
- [ ] Given the page `index.html` is open in a browser, when you type a price
      and a discount, then you see the sale price and how much you save.
- [ ] Given a box is left empty, or the price or discount is negative, when
      you look at the page, then it shows a friendly message (for example
      "Please enter a price" or "A discount can't be negative") instead of a
      price. This is checked by hand on the page.

## What will change
Three new files in `test-driven-development-example/diana/`:
- `sale.js`: the calculation. It takes a price and a discount and gives back
  either the sale price and the saving, or a message explaining what's wrong.
- `sale.test.js`: the automated tests, one per rule, named in plain words.
- `index.html`: the page, with a box for the price, a box for the discount,
  and the result underneath. It uses `sale.js` for the math.

No other folders change.

## Tests
One automated test per rule, in this order. Each is run and seen failing
before the code for it is written.
1. `20% off $50 is $40.00`
2. `15% off $19.99 is $16.99, rounded to the nearest cent`
3. `a discount over 100% says "A discount can't be more than 100%"`
4. `a discount of exactly 100% says "A discount must be less than 100%"`

Run them with `node --test test-driven-development-example/diana/*.test.js`.

## Testing steps
1. Run the tests with the command above and check that all four pass.
2. Open `test-driven-development-example/diana/index.html` in your browser.
3. Type 50 and 20. Check that it shows a sale price of $40.00 and a saving of
   $10.00.
4. Type 19.99 and 15. Check that it shows $16.99.
5. Type a discount of 120. Check that it shows "A discount can't be more than
   100%" and no price.
6. Type a discount of 100. Check that it shows "A discount must be less than
   100%" and no price.
7. Clear the price box, then try a negative price and a negative discount.
   Check that each shows a friendly message and no price.
8. Try a price from a real receipt of your own and check it on a phone
   calculator.
