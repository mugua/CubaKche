import 'package:flutter/material.dart';

import '../services/index.dart';

class FilterAttributeModel with ChangeNotifier {
  List<FilterAttribute> lstProductAttribute = [];
  final Services _service = Services();
  List<SubAttribute> lstCurrentAttr = [];
  List<bool> lstCurrentSelectedTerms = [];
  bool isLoading = false;

  Future<void> getFilterAttributes() async {
    try {
      lstProductAttribute = await _service.getFilterAttributes();
      if (lstProductAttribute?.first?.id != null) {
        await getAttr(id: lstProductAttribute.first.id);
      }
    } catch (err) {
      print('getFilterAttributes: $err');
    }
  }

  Future<void> getAttr({int id}) async {
    try {
      isLoading = true;
      notifyListeners();
      lstCurrentAttr = await _service.getSubAttributes(id: id);
      lstCurrentSelectedTerms.clear();
      lstCurrentAttr.forEach((index) => lstCurrentSelectedTerms.add(false));
    } catch (err) {
      print('getAttr: $err');
    }
    isLoading = false;
    notifyListeners();
  }
}

class FilterAttribute {
  int id;
  String slug;
  String name;

  FilterAttribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    slug = parsedJson['slug'];
    name = parsedJson['name'];
  }
}

class SubAttribute {
  int id;
  String name;

  SubAttribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson['id'];
    name = parsedJson['name'];
  }
}
