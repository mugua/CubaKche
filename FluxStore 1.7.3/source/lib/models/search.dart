import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/constants.dart';
import '../services/index.dart';
import 'product/product.dart';

class SearchModel extends ChangeNotifier {
  SearchModel() {
    getKeywords();
  }

  List<String> keywords = [];
  List<Product> products = [];
  var category = '';
  var tag = '';
  var attribute = '';
  var attribute_term = '';

  bool loading = false;
  String errMsg;

  void refeshProduct(List<Product> _products) {
    products = _products;
    notifyListeners();
  }

  void searchByFilter(
      Map<String, List<dynamic>> searchFilterResult, String searchText, lang) {
    searchFilterResult.forEach((key, value) {
      switch (key) {
        case 'categorys':
          category = value.isNotEmpty ? '${value.first.id}' : '';
          break;
        case 'tags':
          tag = value.isNotEmpty ? '${value.first.id}' : '';
          break;
        default:
          attribute = key;
          attribute_term = value.isNotEmpty ? '${value.first.id}' : '';
      }
    });

    searchProducts(
      name: searchText.isEmpty ? '' : searchText,
      page: 1,
      lang: lang,
    );
  }

  Future<List<Product>> searchProducts({String name, page, lang}) async {
    try {
      loading = true;
      notifyListeners();
      products = await Services().searchProducts(
          name: name,
          categoryId: category,
          tag: tag,
          attribute: attribute,
          attributeId: attribute_term,
          page: page,
          lang: lang);

      if (products.isNotEmpty && page == 1 && name.isNotEmpty) {
        int index = keywords.indexOf(name);
        if (index > -1) {
          keywords.removeAt(index);
        }
        keywords.insert(0, name);
        await saveKeywords(keywords);
      }
      loading = false;
      errMsg = null;
      notifyListeners();

      return products;
    } catch (err) {
      loading = false;
      errMsg = "⚠️ " + err.toString();
      notifyListeners();
      return [];
    }
  }

  void clearKeywords() {
    keywords = [];
    saveKeywords(keywords);
    notifyListeners();
  }

  Future<void> saveKeywords(List<String> keywords) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(kLocalKey["recentSearches"], keywords);
    } catch (err) {
      print(err);
    }
  }

  Future<void> getKeywords() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(kLocalKey["recentSearches"]);
      if (list != null && list.isNotEmpty) {
        keywords = list;
      }
    } catch (err) {
      print(err);
    }
  }
}
