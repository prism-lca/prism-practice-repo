const test = require("node:test");
const assert = require("node:assert");
const { salePrice } = require("./sale.js");

test("Rule 1: 20% off $50 is $40.00", () => {
  assert.strictEqual(salePrice(50, 20).salePrice, 40);
});
