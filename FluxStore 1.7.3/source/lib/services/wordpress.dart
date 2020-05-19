import 'dart:async';
import 'dart:convert' as convert;
import "dart:core";

import 'package:http/http.dart' as http;

import '../models/blogs/blog_news.dart';
import '../models/category/category.dart';
import '../models/user/user_model.dart';
import '../services/helper/woocommerce_api.dart';
import 'helper/blognews_api.dart';
import 'helper/woocommerce_api.dart';

class WordPress {
  WordPress serviceApi;
  WooCommerceAPI wcApi;
  static final WordPress _instance = WordPress._internal();

  factory WordPress() => _instance;

  WordPress._internal();

  static BlogNewsApi blogApi;

  String isSecure;

  String url;

  void setAppConfig(appConfig) {
    blogApi = BlogNewsApi(appConfig["blog"]);
    isSecure = appConfig["url"].indexOf('https') != -1 ? '' : '&insecure=cool';
    url = appConfig["url"];
    wcApi = WooCommerceAPI(appConfig["url"], appConfig["consumerKey"],
        appConfig["consumerSecret"]);
  }

  static Future<Null> createComment(
      {int blogId, Map<String, dynamic> data}) async {
    try {
      await blogApi.postAsync("comments?post=$blogId", data);
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<BlogNews>> searchBlog({name}) async {
    try {
      var response = await blogApi.getAsync("posts?_embed&search=$name");

      List<BlogNews> list = [];
      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }
      print(list);
      return list;
    } catch (e) {
      rethrow;
    }
  }

//  static Future<List<Comment>> getCommentsByPostId({postId}) async {
//    try {
//      print(postId);
//      List<Comment> list = [];
//
//      var endPoint = "comments?";
//      if (postId != null) {
//        endPoint += "&post=$postId";
//      }
//
//      var response = await blogApi.getAsync(endPoint);
//
//      for (var item in response) {
//        list.add(Comment.fromJson(item));
//      }
//
//      return list;
//    } catch (e) {
//      rethrow;
//    }
//  }

  Future<List<Category>> getCategories({lang = "en"}) async {
    try {
      var response = await blogApi.getAsync("categories?per_page=20");
      List<Category> list = [];
      for (var item in response) {
        list.add(Category.fromJson(item));
      }
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BlogNews>> getBlogs() async {
    try {
      var response = await blogApi.getAsync("posts");
      List<BlogNews> list = [];
      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }
      print("list $list");
      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future<BlogNews> getBlog(id) async {
    try {
      var response = await blogApi.getAsync("posts/$id");

      return BlogNews.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<BlogNews> getPageById(int pageId) async {
    var response = await blogApi.getAsync("pages/$pageId?_embed");
    return BlogNews.fromJson(response);
  }

  Future<List<BlogNews>> fetchBlogLayout({config, lang}) async {
    try {
      List<BlogNews> list = [];

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
//      print('Error: ${e.toString()}');
      rethrow;
    }
  }

  Future<List<BlogNews>> fetchBlogsByCategory({categoryId, page, lang}) async {
    try {
      print(categoryId);
      List<BlogNews> list = [];

      var endPoint = "posts?_embed&lang=$lang&per_page=15&page=$page";
      if (categoryId != null) {
        endPoint += "&categories=$categoryId";
      }
      var response = await blogApi.getAsync(endPoint);

      for (var item in response) {
        list.add(BlogNews.fromJson(item));
      }

      return list;
    } catch (e) {
      rethrow;
    }
  }

  Future getNonce({method = 'register'}) async {
    try {
      http.Response response = await http.get(
          "$url/api/get_nonce/?controller=mstore_user&method=$method&$isSecure");
      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body)['nonce'];
      } else {
        throw Exception(['error getNonce', response.statusCode]);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> loginFacebook({String token}) async {
    const cookieLifeTime = 120960000000;

    try {
      var endPoint = "$url/api/mstore_user/fb_connect/?second=$cookieLifeTime"
          "&access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      if (jsonDecode['status'] != 'ok') {
        return jsonDecode['msg'];
      }

      return User.fromJsonFB(jsonDecode);
    } catch (e) {
      // print(e.toString());
      rethrow;
    }
  }

  Future<User> loginSMS({String token}) async {
    try {
      var endPoint =
          "$url/api/mstore_user/sms_login/?access_token=$token$isSecure";

      var response = await http.get(endPoint);

      var jsonDecode = convert.jsonDecode(response.body);

      return User.fromJsonSMS(jsonDecode);
    } catch (e) {
//      print(e.toString());
      rethrow;
    }
  }

  Future<User> getUserInfo(cookie) async {
    try {
//      print("$url/api/mstore_user/get_currentuserinfo/?cookie=$cookie&$isSecure");

      final http.Response response = await http.get(
          "$url/api/mstore_user/get_currentuserinfo/?cookie=$cookie&$isSecure");
      if (response.statusCode == 200) {
        return User.fromAuthUser(
            convert.jsonDecode(response.body)['user'], cookie);
      } else {
        throw Exception("Can not get user info");
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<User> createUser({firstName, lastName, username, password}) async {
    try {
      String niceName = firstName + lastName;
      var nonce = await getNonce();

      final http.Response response = await http.get(
          "$url/api/mstore_user/register/?insecure=cool&nonce=$nonce&user_login=$username&username=$username&user_pass=$password&email=$username&user_nicename=$niceName&display_name=$niceName&$isSecure");

      if (response.statusCode == 200) {
        var cookie = convert.jsonDecode(response.body)['cookie'];
        return await getUserInfo(cookie);
      } else {
        var message = convert.jsonDecode(response.body)["error"];
        throw Exception(message != null ? message : "Can not create the user.");
      }
    } catch (err) {
      rethrow;
    }
  }

  Future<User> login({username, password}) async {
    var cookieLifeTime = 120960000000;
    try {
      print('login execute');
      final http.Response response = await http.get(
          "$url/api/mstore_user/generate_auth_cookie/?second=$cookieLifeTime&username=$username&password=$password&$isSecure");

      if (response.statusCode == 200) {
        var cookie = convert.jsonDecode(response.body)['cookie'];
        return await getUserInfo(cookie);
      } else {
        throw Exception("The username or password is incorrect.");
      }
    } catch (err) {
      rethrow;
    }
  }
}
