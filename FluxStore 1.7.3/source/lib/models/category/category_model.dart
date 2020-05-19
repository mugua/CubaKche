import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

import '../../common/constants.dart';
import '../../services/index.dart';
import 'category.dart';

class CategoryModel with ChangeNotifier {
  final Services _service = Services();
  List<Category> categories;
  Map<String, Category> categoryList = {};

  bool isLoading = false;
  String message;

  Future<void> getCategories({lang}) async {
    try {
      printLog("[Category] getCategories");
      isLoading = true;
      notifyListeners();
      categories = await _service.getCategories(lang: lang);
      isLoading = false;
      message = null;
      for (Category cat in categories) {
        categoryList[cat.id] = cat;
      }
      notifyListeners();

      /// use for second category screens so that we don't need to await here
      unawaited(_service.getCategoryWithCache());
    } catch (err, trace) {
      isLoading = false;
      message = "There is an issue with the app during request the data, "
              "please contact admin for fixing the issues " +
          err.toString();
      print(trace.toString());
      notifyListeners();
    }
  }
}
