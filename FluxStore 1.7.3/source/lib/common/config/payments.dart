/**
 * Everything Config about the Payment
 */

/// config for payment features
const kPaymentConfig = {
  "DefaultCountryISOCode": "CU",

  /// Enable the Shipping optoion from Checkout, support for the Digital Download
  "EnableShipping": true,

  /// Enable the Google Map picker
  "EnableAddress": true,

  /// Enable the product review option
  "EnableReview": true,

  /// enable the google map picker from Billing Address
  'allowSearchingAddress': true,
  "GuestCheckout": false,

  /// Enable Payment option
  "EnableOnePageCheckout": false,
  "NativeOnePageCheckout": true,

  /// Enable update order status to processing after checkout by COD on woo commerce
  "UpdateOrderStatus": false
};

const Payments = {
  "paypal": "assets/icons/payment/paypal.png",
  "stripe": "assets/icons/payment/stripe.png",
  "razorpay": "assets/icons/payment/razorpay.png",
};

const PaypalConfig = {
  "clientId":
      "ARy4yUofSq9irVLSgn7_4mQvH60k1lTbxtfkoCRCWcg1cHptP1vTsQT4_cQJOq4nBd6s6OKCn2wgaJ96",
  "secret":
      "ENYEGpDplWFLH-npzENnNf472TJv7fse0s43EUyvR_HKUyWDXU74fiN0xHiH8bTNiw5tX24_SMJXVRvK",
  "production": true,
  "paymentMethodId": "paypal",
  "enabled": true,
  "returnUrl": "http://return.example.com",
  "cancelUrl": "http://cancel.example.com",
};

const RazorpayConfig = {
  "keyId": "rzp_test_Iz3ByJRZoHMgxr",
  "paymentMethodId": "razorpay",
  "enabled": true
};

const TapConfig = {
  "SecretKey": "sk_test_XKokBfNWv6FIYuTMg5sLPjhJ",
  "RedirectUrl": "http://your_website.com/redirect_url",
  "paymentMethodId": "",
  "enabled": false
};

/// config for after shipping
const afterShip = {
  "api": "e2e9bae8-ee39-46a9-a084-781d0139274f",
  "tracking_url": "https://fluxstore.aftership.com"
};

/// Limit the country list from Billing Address
/// []: default show all country


const List DefaultCountry = [
  {
    "name": "Cuba",
    "iosCode": "CU",
    "icon": "https://s3.amazonaws.com/cubakche/wp-content/uploads/2020/05/17194812/Flag-Cuba.jpg"
  },
];