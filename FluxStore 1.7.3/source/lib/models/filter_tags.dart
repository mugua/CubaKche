import 'package:flutter/material.dart';

import '../services/index.dart';

class FilterTagModel with ChangeNotifier {
  List<FilterTag> lstProductTag = [];
  final Services _service = Services();
  bool isLoading = false;

  Future<void> getFilterTags() async {
    try {
      lstProductTag = await _service.getFilterTags();
    } catch (err) {
      print('getFilterTags: $err');
    }
  }
}

class FilterTag {
  int id;
  String slug;
  String name;
  String description;
  int count;

  FilterTag({this.id, this.name, this.slug, this.description, this.count});

  FilterTag.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    slug = parsedJson['slug'];
    name = parsedJson['name'];
    description = parsedJson['description'];
    count = parsedJson['count'];
  }
}
