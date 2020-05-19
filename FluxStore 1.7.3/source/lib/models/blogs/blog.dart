import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html_unescape/html_unescape.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../services/config.dart';

class BlogModel with ChangeNotifier {
  List<Blog> blogs = [];

  void addBlogs(List<Blog> list) {
    blogs = [...list];
    notifyListeners();
  }

  Future getBlogs() async {
    var _blogs = [];
    var _jsons = await Blog.getBlogs(
      url: Config().blog ?? Config().url,
      page: 1,
    );
    for (var item in _jsons) {
      _blogs.add(Blog.fromJson(item));
    }
    blogs = [..._blogs];
    notifyListeners();
  }
}

class Blog {
  int id;
  String title;
  String subTitle;
  String date;
  String content;
  String author;
  String imageFeature;

  Blog.fromJson(Map<String, dynamic> json) {
    try {
      var imgJson = json["better_featured_image"];
      if (imgJson != null) {
        if (imgJson["media_details"]["sizes"]["medium_large"] != null) {
          imageFeature =
              imgJson["media_details"]["sizes"]["medium_large"]["source_url"];
        }
      }

      if (imageFeature == null) {
        var imgMedia = json['_embedded']['wp:featuredmedia'];
        if (imgMedia != null &&
            imgMedia[0]['media_details']["sizes"]["large"] != null) {
          imageFeature =
              imgMedia[0]['media_details']["sizes"]["large"]['source_url'];
        }
      }

      author = json["_embedded"]["author"][0]["name"];

      date = DateFormat.yMMMMd("en_US").format(DateTime.parse(json['date']));

      subTitle = HtmlUnescape().convert(json['excerpt']['rendered']);
      content = json['content']['rendered'];
      id = json['id'];
      title = HtmlUnescape().convert(json['title']['rendered']);
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  Blog.empty(this.id)
      : title = '',
        subTitle = '',
        date = '',
        author = '',
        content = '',
        imageFeature = '';

  static Future<dynamic> getBlogs({url, page = 1}) async {
    final response =
        await http.get("$url/wp-json/wp/v2/posts?_embed&page=$page");
    return jsonDecode(response.body);
  }

  @override
  String toString() => 'Blog { id: $id  title: $title}';
}
