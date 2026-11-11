const test = require("node:test");
const assert = require("node:assert");
const { salePrice } = require("./sale.js");

test("Rule 1: 20% off $50 is $40.00", () => {
  assert.strictEqual(salePrice(50, 20).salePrice, 40);
});

test("Rule 2: 15% off $19.99 is $16.99, rounded to the nearest cent", () => {
  assert.strictEqual(salePrice(19.99, 15).salePrice, 16.99);
});
