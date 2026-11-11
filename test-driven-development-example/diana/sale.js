// Works out a sale price from a price and a percent discount.
function salePrice(price, discount) {
  return { salePrice: price * (100 - discount) / 100 };
}

if (typeof module !== "undefined") module.exports = { salePrice };
