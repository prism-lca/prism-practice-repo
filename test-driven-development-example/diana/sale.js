// Works out a sale price from a price and a percent discount.
function salePrice(price, discount) {
  if (discount > 100) {
    return { error: "A discount can't be more than 100%" };
  }
  if (discount === 100) {
    return { error: "A discount must be less than 100%" };
  }
  // Work in cents and round to the nearest whole cent.
  const cents = Math.round(price * (100 - discount));
  return { salePrice: cents / 100 };
}

if (typeof module !== "undefined") module.exports = { salePrice };
