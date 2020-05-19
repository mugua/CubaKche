import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../screens/blogs/posts.dart';
import '../../services/wordpress.dart';
import '../app.dart';

class BlogNewsModel with ChangeNotifier {
  List<BlogNews> blogList = [];

  final WordPress _service = WordPress();

  bool isFetching = false;
  bool isEnd;
  int categoryId;
  String categoryName;
  String errMsg;

  Future<List<BlogNews>> fetchBlogLayout(config, lang) async {
    return _service.fetchBlogLayout(config: config, lang: lang);
  }

  void setBlogNewsList(blogs) {
    blogList = blogs;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }

  void fetchBlogsByCategory({categoryId, categoryName}) {
    this.categoryId = categoryId;

    this.categoryName = categoryName;
    notifyListeners();
  }

  Future<void> saveBlogs(Map<String, dynamic> data) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["home"], data);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> getBlogsList(
      {categoryId, minPrice, maxPrice, orderBy, order, lang, page}) async {
    try {
      print(categoryId);
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      isFetching = true;
      isEnd = false;
      notifyListeners();

      final blogs = await _service.fetchBlogsByCategory(
          categoryId: categoryId, lang: lang, page: page);
      if (blogs.isEmpty) {
        isEnd = true;
      }

      if (page == 0 || page == 1) {
        blogList = blogs;
      } else {
        blogList = [...blogList, ...blogs];
      }
      isFetching = false;
      notifyListeners();
    } catch (err) {
      errMsg = err.toString();
      isFetching = false;
      notifyListeners();
    }
  }

  void setBlogsList(blogs) {
    blogList = blogs;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }
}

class BlogNews {
  int id;
  String date;
  String title;
  String author;
  String content;
  String excerpt;
  String slug;
  String imageFeature;
//  int categoryId;

  BlogNews.empty(this.id) {
    date = '';
    title = 'Loading...';
    author = '';
    content = '';
    excerpt = '';
    imageFeature = '';
  }

  bool isEmptyBlog() {
    return date == '' &&
        title == 'Loading...' &&
        content == 'Loading...' &&
        excerpt == 'Loading...' &&
        imageFeature == '';
  }

  static Future<dynamic> getBlogs({url, page = 1}) async {
    final response = await http.get("$url/wp-json/wp/v2/posts?page=$page");
    return json.decode(response.body);
  }

  BlogNews.fromJson(Map<String, dynamic> parsedJson) {
    try {
//      categoryId = parsedJson["categories"][0];
      id = parsedJson["id"];
      slug = parsedJson["slug"];
      title = HtmlUnescape().convert(parsedJson["title"]["rendered"]);
      content = parsedJson["content"]["rendered"];

      var imgJson = parsedJson["better_featured_image"];
      if (imgJson != null) {
        if (imgJson["media_details"]["sizes"]["medium_large"] != null) {
          imageFeature =
              imgJson["media_details"]["sizes"]["medium_large"]["source_url"];
        }
      }

      if (imageFeature == null) {
        var imgMedia = parsedJson['_embedded']['wp:featuredmedia'];
        if (imgMedia != null &&
            imgMedia[0]['media_details']["sizes"]["large"] != null) {
          imageFeature =
              imgMedia[0]['media_details']["sizes"]["large"]['source_url'];
        }
      }

//      author = parsedJson["_embedded"]["author"][0]["name"];
      excerpt = HtmlUnescape().convert(parsedJson['excerpt']['rendered']);
      date = parsedJson["date"];
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  static showList(
      {cateId, cateName, context, List<BlogNews> blogs, config, noRouting}) {
    var categoryId = cateId ?? config['category'];

    var categoryName = cateName ?? config['name'];
    final blog = Provider.of<BlogNewsModel>(context, listen: false);

    // for caching current products list
    if (blogs != null) {
      blog.setBlogNewsList(blogs);
      return Navigator.push(
          context,
          MaterialPageRoute(
              fullscreenDialog: kLayoutWeb,
              builder: (context) =>
                  BlogsPage(blogs: blogs, categoryId: categoryId)));
    }
    if (categoryId != null) {
      blog.fetchBlogsByCategory(
          categoryId: categoryId, categoryName: categoryName);
    }

    blog.setBlogsList(List<BlogNews>()); //clear old products
    blog.getBlogsList(
      categoryId: categoryId,
      page: 1,
      lang: Provider.of<AppModel>(context, listen: false).locale,
    );

    if (noRouting == null) {
      Navigator.push(
          context,
          MaterialPageRoute(
              fullscreenDialog: kLayoutWeb,
              builder: (context) =>
                  BlogsPage(blogs: blogs ?? [], categoryId: categoryId)));
    } else {
      return BlogsPage(blogs: blogs ?? [], categoryId: categoryId);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "title": title,
      "slug": slug,
      "content": content,
      "imageFeature": imageFeature,
//      "categoryId": categoryId,
      "excerpt": excerpt,
      "date": date,
    };
  }

  BlogNews.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      title = json['title'];
      slug = json['slug'];
      content = json['content'];
      imageFeature = json["imageFeature"];
      excerpt = json["excerpt"];
      date = json["date"];
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  @override
  String toString() => 'Blog { id: $id title: $title }';
}
