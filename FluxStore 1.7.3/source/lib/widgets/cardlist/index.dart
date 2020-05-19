import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/category/category.dart';
import '../../models/category/category_model.dart';
import 'menu_card.dart';

class HorizonMenu extends StatefulWidget {
  @override
  _StateHorizonMenu createState() => _StateHorizonMenu();
}

class _StateHorizonMenu extends State<HorizonMenu> {
  List<Category> getCategory() {
    final categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    return categories.where((item) => item.parent == '0').toList();
  }

  List getChildrenOfCategory(Category category) {
    final categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    var children = categories.where((o) => o.parent == category.id).toList();
    return children;
  }

  @override
  Widget build(BuildContext context) {
    final categories = getCategory();

    return Column(
              children: List.generate(categories.length, (index) {
            return MenuCard(
                getChildrenOfCategory(categories[index]),
                categories[index]);
          }));
  }
}
