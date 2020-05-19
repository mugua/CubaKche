import 'dart:async';
import 'dart:convert' as convert;

import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:random_string/random_string.dart';

import './index.dart';
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
import 'helper/blognews_api.dart';
import '../common/constants.dart';

class OpencartApi implements BaseServices {
  static final OpencartApi _instance = OpencartApi._internal();

  factory OpencartApi() => _instance;

  OpencartApi._internal();

  String cookie;
  String domain;
  @override
  BlogNewsApi blogApi;

  void setAppConfig(appConfig) {
    domain = appConfig["url"];
    blogApi = BlogNewsApi(appConfig["blog"] ?? 'http://demo.mstore.io');
    getCookie();
  }

  @override
  Future<List<BlogNews>> fetchBlogLayout({config, lang}) async {
    try {
      final List<BlogNews> list = [];

      var endPoint = "posts?_embed&lang=$lang";
      if (config.containsKey("category")) {
        endPoint += "&categories=${config["category"]}";
      }
      if (config.containsKey("limit")) {
        endPoint += "&per_page=${config["limit"] ?? 20}";
      }

      var response = await blogApi.getAsync(endPoint);

      for (var item in response) {
        if (BlogNews.fromJson(item) != null) {
          list.add(BlogNews.fromJson(item));
        }
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<BlogNews> getPageById(int pageId) async {
    var response = await blogApi.getAsync("pages/$pageId?_embed");
    return BlogNews.fromJson(response);
  }

  Future<void> getCookie() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = storage.getItem("opencart_cookie");
        if (json != null) {
          cookie = json;
        } else {
          cookie = "OCSESSID=" +
              randomNumeric(30) +
              "; PHPSESSID=" +
              randomNumeric(30);
          await storage.setItem("opencart_cookie", cookie);
        }
      }
    } catch (err) {
      print(err);
      cookie =
          "OCSESSID=" + randomNumeric(30) + "; PHPSESSID=" + randomNumeric(30);
    }
  }

  @override
  Future<List<Category>> getCategories({lang}) async {
    try {
      var response = await http.get(
          "$domain/index.php?route=extension/mstore/category&limit=100&lang=$lang");
      List<Category> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Category.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      var response =
          await http.get("$domain/index.php?route=extension/mstore/product");
      List<Product> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Product.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Product>> fetchProductsLayout({config, lang}) async {
    try {
      List<Product> list = [];
      if (config["layout"] == "imageBanner" ||
          config["layout"] == "circleCategory") {
        return list;
      }

      var endPoint = "&limit=$ApiPageSize";
      if (config.containsKey("category")) {
        endPoint += "&category=${config["category"]}";
      }
      if (config.containsKey("tag")) {
        endPoint += "&tag=${config["tag"]}";
      }
      if (lang != null) {
        endPoint += "&lang=$lang";
      }
      var response = await http
          .get("$domain/index.php?route=extension/mstore/product$endPoint");

      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          Product product = Product.fromOpencartJson(item);
          product.categoryId = config["category"].toString();
          list.add(product);
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
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
      attributeTerm}) async {
    try {
      List<Product> list = [];

      var endPoint =
          "/index.php?route=extension/mstore/product&limit=$ApiPageSize&page=$page&lang=$lang";
      if (categoryId != null && categoryId.toString().isNotEmpty) {
        endPoint += "&category=$categoryId";
      }
      if (tagId != null) {
        endPoint += "&tag=$tagId";
      }
      if (maxPrice != null && maxPrice > 0) {
        endPoint += "&max_price=${(maxPrice as double).toInt().toString()}";
      }
      if (orderBy != null) {
        endPoint += "&sort=${orderBy == "date" ? "date_added" : orderBy}";
      }
      if (order != null) {
        endPoint += "&order=${order.toString().toUpperCase()}";
      }

      var response = await http.get("$domain$endPoint");
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Product.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> loginFacebook({String token}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/account/socialLogin",
          body: convert.jsonEncode({"token": token, "type": "facebook"}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body["data"], "");
      } else {
        List error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Login fail");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> loginSMS({String token}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/account/socialLogin",
          body: convert.jsonEncode({"token": token, "type": "firebase_sms"}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body["data"], "");
      } else {
        List error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Login fail");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> loginApple({String email, String fullName}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/account/socialLogin",
          body: convert.jsonEncode(
              {"email": email, "fullName": fullName, "type": "apple"}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body["data"], "");
      } else {
        List error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Login fail");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<List<Review>> getReviews(productId) async {
    try {
      var response = await http
          .get("$domain/index.php?route=extension/mstore/review&id=$productId");
      List<Review> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Review.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ProductVariation>> getProductVariations(Product product) {
    return null;
  }

  @override
  Future<List<ShippingMethod>> getShippingMethods(
      {Address address, String token, String checkoutId}) async {
    try {
      List<ShippingMethod> list = [];
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/shipping_address/save",
          body: convert.jsonEncode(address.toOpencartJson()),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body["success"] == 1) {
        var res = await http.get(
            "$domain/index.php?route=extension/mstore/shipping_method",
            headers: {"cookie": cookie});
        final body = convert.jsonDecode(res.body);
        if (res.statusCode == 200 && body["data"]["error_warning"] == "") {
          Map<String, dynamic> data = body["data"]["shipping_methods"];
          for (var item in data.values.toList()) {
            list.add(ShippingMethod.fromOpencartJson(item));
          }
          return list;
        } else {
          throw Exception(body["data"]["error_warning"]);
        }
      } else {
        throw Exception(body["error"][0]);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PaymentMethod>> getPaymentMethods(
      {Address address, ShippingMethod shippingMethod, String token}) async {
    try {
      List<PaymentMethod> list = [];
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/shipping_method/save",
          body: convert.jsonEncode(
              {"shipping_method": shippingMethod.id, "comment": "no comment"}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body["success"] == 1) {
        response = await http.post(
            "$domain/index.php?route=extension/mstore/payment_address/save",
            body: convert.jsonEncode(address.toOpencartJson()),
            headers: {"content-type": "application/json", "cookie": cookie});
        final body = convert.jsonDecode(response.body);
        if (response.statusCode == 200 && body["success"] == 1) {
          var res = await http.get(
              "$domain/index.php?route=extension/mstore/payment_method",
              headers: {"cookie": cookie});
          final body = convert.jsonDecode(res.body);
          if (res.statusCode == 200 && body["data"]["error_warning"] == "") {
            Map<String, dynamic> data = body["data"]["payment_methods"];
            for (var item in data.values.toList()) {
              list.add(PaymentMethod.fromOpencartJson(item));
            }
            return list;
          } else {
            throw Exception(body["data"]["error_warning"]);
          }
        } else {
          throw Exception(body["error"][0]);
        }
      } else {
        throw Exception(body["error"][0]);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Order>> getMyOrders({UserModel userModel, int page}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/order/orders&page=1&limit=50",
          headers: {"content-type": "application/json", "cookie": cookie});
      List<Order> list = [];
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Order.fromOpencartJson(item));
        }
      }
      return list;
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Order> createOrder(
      {CartModel cartModel, UserModel user, bool paid}) async {
    try {
      var response = await http
          .post("$domain/index.php?route=extension/mstore/payment_method/save",
              body: convert.jsonEncode({
                "payment_method": cartModel.paymentMethod.id,
                "agree": "1",
                "comment": "no comment"
              }),
              headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200 && body["success"] == 1) {
        var res = await http.post(
            "$domain/index.php?route=extension/mstore/order/confirm",
            body: convert.jsonEncode({}),
            headers: {"cookie": cookie});
        final body = convert.jsonDecode(res.body);
        if (res.statusCode == 200 && body["success"] == 1) {
          var order = Order();
          order.id = body["data"]["order_id"]?.toString();
          order.number = body["data"]["order_id"]?.toString();
          return order;
        } else {
          throw Exception(body["error"][0]);
        }
      } else {
        throw Exception(body["error"][0]);
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future updateOrder(orderId, {status, token}) {
    return null;
  }

  @override
  Future<List<Product>> searchProducts(
      {name, categoryId, tag, attribute, attributeId, page, lang}) async {
    try {
      List<Product> list = [];

      var endPoint =
          "/index.php?route=extension/mstore/product&limit=$ApiPageSize&page=$page&search=$name";

      var response = await http.get("$domain$endPoint");
      if (response.statusCode == 200) {
        for (var item in convert.jsonDecode(response.body)["data"]) {
          list.add(Product.fromOpencartJson(item));
        }
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> createUser({firstName, lastName, username, password}) async {
    try {
      var response = await http
          .post("$domain/index.php?route=extension/mstore/account/register",
              body: convert.jsonEncode({
                "telephone": "123",
                "email": username,
                "firstname": firstName,
                "lastname": lastName,
                "password": password,
                "confirm": password
              }),
              headers: {"content-type": "application/json"});

      if (response.statusCode == 200) {
        return await login(username: username, password: password);
      } else {
        final body = convert.jsonDecode(response.body);
        List error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Can not create user");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> getUserInfo(cookie) async {
    try {
      var res = await http.get(
          "$domain/index.php?route=extension/mstore/account",
          headers: {"cookie": this.cookie});
      final body = convert.jsonDecode(res.body);
      if (res.statusCode == 200) {
        return User.fromOpencartJson(body["data"], cookie);
      } else {
        List error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("No match for E-Mail Address and/or Password");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<User> login({username, password}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/account/login",
          body: convert.jsonEncode({"email": username, "password": password}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body["data"], "");
      } else {
        List error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("No match for E-Mail Address and/or Password");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Product> getProduct(id) async {
    return null;
  }

  Future<bool> addItemsToCart(CartModel cartModel, String token) async {
    try {
      if (cookie != null) {
        List items = [];
        cartModel.productsInCart.keys.forEach((productId) {
          items.add({
            "product_id": productId,
            "quantity": cartModel.productsInCart[productId],
            "option": cartModel.productOptionInCart[productId]
          });
        });

        var res = await http.delete(
            "$domain/index.php?route=extension/mstore/cart/emptyCart",
            headers: {'cookie': cookie, "content-type": "application/json"});
        if (res.statusCode == 200) {
          final body = convert.jsonDecode(res.body);
          if (res.statusCode == 200 &&
              body["success"] == 1 &&
              body["data"]["total_product_count"] == 0) {
            var res = await http.post(
                "$domain/index.php?route=extension/mstore/cart/add",
                body: convert.jsonEncode(items),
                headers: {
                  'cookie': cookie,
                  "content-type": "application/json"
                });
            final body = convert.jsonDecode(res.body);
            if (res.statusCode == 200 &&
                body["success"] == 1 &&
                body["data"]["total_product_count"] > 0) {
              if (cartModel.couponObj != null &&
                  cartModel.couponObj.code != null) {
                await http.post(
                    "$domain/index.php?route=extension/mstore/cart/coupon",
                    body: convert
                        .jsonEncode({"coupon": cartModel.couponObj.code}),
                    headers: {
                      'cookie': cookie,
                      "content-type": "application/json"
                    });
              }
              return true;
            } else {
              throw Exception("Can not add items to cart");
            }
          } else {
            throw Exception(body["error"][0]);
          }
        } else {
          throw Exception(res.reasonPhrase);
        }
      } else {
        throw Exception("You need to login to checkout");
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Coupons> getCoupons() async {
    try {
      var res = await http.get(
          "$domain/index.php?route=extension/mstore/cart/coupons",
          headers: {'cookie': cookie, "content-type": "application/json"});
      final body = convert.jsonDecode(res.body);
      return Coupons.getListCouponsOpencart(body["data"]);
    } catch (e) {
      //This error exception is about your Rest API is not config correctly so that not return the correct JSON format, please double check the document from this link https://docs.inspireui.com/fluxstore/woocommerce-setup/
      rethrow;
    }
  }

  @override
  Future<AfterShip> getAllTracking() async {
    return null;
  }

  @override
  Future<List<OrderNote>> getOrderNote(
      {UserModel userModel, String orderId}) async {
    return null;
  }

  @override
  Future<Null> createReview(
      {String productId, Map<String, dynamic> data}) async {}

  @override
  Future<Null> getHomeCache() {
    return null;
  }

  @override
  Future<User> loginGoogle({String token}) async {
    try {
      var response = await http.post(
          "$domain/index.php?route=extension/mstore/account/socialLogin",
          body: convert.jsonEncode({"token": token, "type": "google"}),
          headers: {"content-type": "application/json", "cookie": cookie});
      final body = convert.jsonDecode(response.body);
      if (response.statusCode == 200) {
        return User.fromOpencartJson(body["data"], "");
      } else {
        List error = body["error"];
        if (error != null && error.isNotEmpty) {
          throw Exception(error[0]);
        } else {
          throw Exception("Login fail");
        }
      }
    } catch (err) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> json, String token) async {
    return null;
  }

  @override
  Future getCategoryWithCache() {
    // TO-DO: implement getCategoryCache
    return null;
  }

  @override
  Future<List<FilterAttribute>> getFilterAttributes() {
    // TO-DO: implement getFilterAttributes
    throw UnimplementedError();
  }

  @override
  Future<List<SubAttribute>> getSubAttributes({int id}) {
    // TO-DO: implement getAttributes
    throw UnimplementedError();
  }

  @override
  Future<List<FilterTag>> getFilterTags() {
    return null;
  }

  @override
  Future<String> getCheckoutUrl(Map<String, dynamic> params) {
    // TODO: implement getCheckoutUrl
    return null;
  }

  @override
  Future<String> submitForgotPassword(
      {String forgotPwLink, Map<String, dynamic> data}) {
    // TODO: implement submitForgotPassword
    return null;
  }

  @override
  Future logout() async {
    return await http.post(
        "$domain/index.php?route=extension/mstore/account/logout",
        headers: {"content-type": "application/json", "cookie": cookie});
  }
}
