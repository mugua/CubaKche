export 'config/advertise.dart';
export 'config/general.dart';
export 'config/onboarding.dart';
export 'config/payments.dart';
export 'config/products.dart';
export 'config/smartchat.dart';

/// Server config demo for WooCommerce
/// Get more example for Opencart / Magento / Shopify from the example folder
const serverConfig = {
  "type": "woo",
  "url": "https://cubakche.com",

  /// document: https://docs.inspireui.com/fluxstore/woocommerce-setup/
  "consumerKey": "ck_188bb9edcd8a2aa9c093d23a4f319740f56bcc4d",
  "consumerSecret": "cs_bb178d0e996358482017bea482e9c9024fa920f3",

  /// Your website woocommerce. You can remove this line if it same url
  "blog": "https://cubakche.com",

  /// set blank to use as native screen
  "forgetPassword": "https://cubakche.com/my-account-2/lost-password"
};
