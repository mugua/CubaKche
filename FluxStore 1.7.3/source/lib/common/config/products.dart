/**
 * Everything Config about the Product Setting
 */

/// The product variant config
const ProductVariantLayout = {
  "color": "color",
  "size": "box",
  "height": "option",
};

/// use to config the product image height for the product detail
/// height=(percent * width-screen)
/// isHero: support hero animate
const kProductDetail = {
  "height": 0.5,
  "marginTop": 0,
  "isHero": false,
  "safeArea": false,
  "showVideo": true,
  "showThumbnailAtLeast": 3,
  "layout": "simpleType",
  "maxAllowQuantity": 400, // the maximum quantity items user could purchase
  "enableReview": true,
};

const kProductVariantLanguage = {
  "en": {
    "color": "Color",
    "size": "Size",
    "height": "Height",
  },
  "ar": {"color": "اللون", "size": "بحجم", "height": "ارتفاع"},
  "vi": {
    "color": "Màu",
    "size": "Kích thước",
    "height": "Chiều Cao",
  },
};
