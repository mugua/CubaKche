import './magento.dart';
import './opencart.dart';
import './woo_commerce.dart';
import '../common/constants.dart';
import '../models/address.dart';
import '../models/aftership.dart';
import '../models/blogs/blog_news.dart';
import '../models/cart/cart_model.dart';
import '../models/category/category.dart';
import '../models/coupon.dart';
import '../models/filter_attribute.dart';
import '../models/filter_tags.dart';
import '../models/order/order_model.dart';
import '../models/order/order_note.dart';
import '../models/payment_method.dart';
import '../models/product/product.dart';
import '../models/product/product_variation.dart';
import '../models/review.dart';
import '../models/shipping_method.dart';
import '../models/user/user_model.dart';
import '../widgets/frameworks/index.dart';
import '__mocks__/woo_commerce.dart';
import 'config.dart';
import 'helper/blognews_api.dart';

abstract class BaseServices {
  BlogNewsApi blogApi;

  Future<List<Category>> getCategories({lang});

  Future<List<Product>> getProducts();

  Future<List<Product>> fetchProductsLayout({config, lang});

  Future<List<Product>> fetchProductsByCategory(
      {categoryId,
      tagId,
      page,
      minPrice,
      maxPrice,
      orderBy,
      lang,
      order,
      featured,
      onSale,
      attribute,
      attributeTerm});

  Future<User> loginFacebook({String token});

  Future<User> loginSMS({String token});

  Future<User> loginApple({String email, String fullName});

  Future<User> loginGoogle({String token});

  Future<List<Review>> getReviews(productId);

  Future<List<ProductVariation>> getProductVariations(Product product);

  Future<List<ShippingMethod>> getShippingMethods(
      {Address address, String token, String checkoutId});

  Future<List<PaymentMethod>> getPaymentMethods(
      {Address address, ShippingMethod shippingMethod, String token});

  Future<Order> createOrder({CartModel cartModel, UserModel user, bool paid});

  Future<List<Order>> getMyOrders({UserModel userModel, int page});

  Future updateOrder(orderId, {status, token});

  Future<List<Product>> searchProducts(
      {name, categoryId, tag, attribute, attributeId, page, lang});

  Future<User> getUserInfo(cookie);

  Future<User> createUser({
    firstName,
    lastName,
    username,
    password,
  });

  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String token);

  Future<User> login({username, password});

  Future<Product> getProduct(id);

  Future<Coupons> getCoupons();

  Future<AfterShip> getAllTracking();

  Future<List<OrderNote>> getOrderNote({UserModel userModel, String orderId});

  Future<Null> createReview({String productId, Map<String, dynamic> data});

  Future<Map<String, dynamic>> getHomeCache();

  Future<List<BlogNews>> fetchBlogLayout({config, lang});

  Future<BlogNews> getPageById(int pageId);

  Future getCategoryWithCache();

  Future<List<FilterAttribute>> getFilterAttributes();

  Future<List<SubAttribute>> getSubAttributes({int id});

  Future<List<FilterTag>> getFilterTags();

  Future<String> getCheckoutUrl(Map<String, dynamic> params);

  Future<String> submitForgotPassword(
      {String forgotPwLink, Map<String, dynamic> data});


  Future logout();
}

class Services implements BaseServices {
  BaseServices serviceApi;
  BaseFrameworks widget;
  @override
  BlogNewsApi blogApi;

  static final Services _instance = Services._internal();

  factory Services() => _instance;

  Services._internal();

  void setAppConfig(appConfig) {
    printLog("[Services] setAppConfig: --> ${appConfig["type"]} <--");
    Config().setConfig(appConfig);
    CartInject().init(appConfig);

    switch (appConfig["type"]) {
      case "opencart":
        OpencartApi().setAppConfig(appConfig);
        serviceApi = OpencartApi();
        widget = OpencartWidget();
        break;
      case "magento":
        MagentoApi().setAppConfig(appConfig);
        serviceApi = MagentoApi();
        widget = MagentoWidget();
        break;
      case "woo-mock":
        serviceApi = WooCommerceMock()..appConfig(appConfig);
        widget = WooWidget();
        break;
      default:
        widget = WooWidget();
        serviceApi = WooCommerce()..appConfig(appConfig);
    }
  }

  @override
  Future<List<Product>> fetchProductsByCategory(
      {categoryId,
      tagId,
      page = 1,
      minPrice,
      maxPrice,
      orderBy,
      order,
      lang,
      featured,
      onSale,
      attribute,
      attributeTerm}) async {
    return serviceApi.fetchProductsByCategory(
        categoryId: categoryId,
        tagId: tagId,
        page: page,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        lang: lang,
        order: order,
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: attributeTerm);
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang = "en"}) async {
    return serviceApi.fetchProductsLayout(config: config, lang: lang);
  }

  @override
  Future<List<Category>> getCategories({lang = "en"}) async {
    return serviceApi.getCategories(lang: lang);
  }

  @override
  Future<List<Product>> getProducts() async {
    return serviceApi.getProducts();
  }

  @override
  Future<User> loginFacebook({String token}) async {
    return serviceApi.loginFacebook(token: token);
  }

  @override
  Future<User> loginSMS({String token}) async {
    return serviceApi.loginSMS(token: token);
  }

  @override
  Future<User> loginApple({String email, String fullName}) async {
    return serviceApi.loginApple(email: email, fullName: fullName);
  }

  @override
  Future<User> loginGoogle({String token}) async {
    return serviceApi.loginGoogle(token: token);
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    return serviceApi.getReviews(productId);
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product) async {
    return serviceApi.getProductVariations(product);
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {Address address, String token, String checkoutId}) async {
    return serviceApi.getShippingMethods(
        address: address, token: token, checkoutId: checkoutId);
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {Address address, ShippingMethod shippingMethod, String token}) async {
    return serviceApi.getPaymentMethods(
        address: address, shippingMethod: shippingMethod, token: token);
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    return serviceApi.getMyOrders(userModel: userModel, page: page);
  }

  @override
  Future<Order> createOrder(
      {CartModel cartModel, UserModel user, bool paid}) async {
    return serviceApi.createOrder(cartModel: cartModel, user: user, paid: paid);
  }

  @override
  Future updateOrder(orderId, {status, token}) async {
    return serviceApi.updateOrder(orderId, status: status, token: token);
  }

  @override
  Future<List<Product>> searchProducts(
      {name, categoryId, tag, attribute, attributeId, page, lang}) async {
    return serviceApi.searchProducts(
        name: name,
        categoryId: categoryId,
        tag: tag,
        attribute: attribute,
        attributeId: attributeId,
        page: page,
        lang: lang);
  }

  @override
  Future<User> createUser({firstName, lastName, username, password}) async {
    return serviceApi.createUser(
      firstName: firstName,
      lastName: lastName,
      username: username,
      password: password,
    );
  }

  @override
  Future<User> getUserInfo(cookie) async {
    return serviceApi.getUserInfo(cookie);
  }

  @override
  Future<User> login({username, password}) async {
    return serviceApi.login(
      username: username,
      password: password,
    );
  }

  @override
  Future<Product> getProduct(id) async {
    return serviceApi.getProduct(id);
  }

  @override
  Future<Coupons> getCoupons() async {
    return serviceApi.getCoupons();
  }

  @override
  Future<AfterShip> getAllTracking() async {
    return serviceApi.getAllTracking();
  }

  @override
  Future<List<OrderNote>> getOrderNote(
      {UserModel userModel, String orderId}) async {
    return serviceApi.getOrderNote(userModel: userModel, orderId: orderId);
  }

  @override
  Future<Null> createReview(
      {String productId, Map<String, dynamic> data}) async {
    return serviceApi.createReview(productId: productId, data: data);
  }

  @override
  Future<Map<String, dynamic>> getHomeCache() async {
    return serviceApi.getHomeCache();
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String token) async {
    return serviceApi.updateUserInfo(json, token);
  }

  @override
  Future<List<BlogNews>> fetchBlogLayout({config, lang}) {
    return serviceApi.fetchBlogLayout(config: config, lang: lang);
  }

  @override
  Future<BlogNews> getPageById(int pageId){
    return serviceApi.getPageById(pageId);
  }

  @override
  Future getCategoryWithCache() {
    return serviceApi.getCategoryWithCache();
  }

  @override
  Future<List<FilterAttribute>> getFilterAttributes() {
    return serviceApi.getFilterAttributes();
  }

  @override
  Future<List<SubAttribute>> getSubAttributes({int id}) {
    return serviceApi.getSubAttributes(id: id);
  }

  @override
  Future<List<FilterTag>> getFilterTags() {
    return serviceApi.getFilterTags();
  }

  @override
  Future<String> getCheckoutUrl(Map<String, dynamic> params) {
    return serviceApi.getCheckoutUrl(params);
  }

  @override
  Future<String> submitForgotPassword(
      {String forgotPwLink, Map<String, dynamic> data}) {
    return serviceApi.submitForgotPassword(
        forgotPwLink: forgotPwLink, data: data);
  }

  @override
  Future logout() {
    return serviceApi.logout();
  }
}
