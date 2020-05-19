import 'package:flutter/material.dart';

import '../../models/category/category.dart';
import '../../models/product/product.dart';
import '../../services/index.dart';
import '../../widgets/product/product_list.dart';

class SideMenuCategories extends StatefulWidget {
  final List<Category> categories;

  SideMenuCategories(this.categories);

  @override
  State<StatefulWidget> createState() => SideMenuCategoriesState();
}

class SideMenuCategoriesState extends State<SideMenuCategories> {
  int selectedIndex = 0;
  final Services _service = Services();
  List<Category> _categories = [];
  List<Product> _products = [];

  @override
  void initState() {
    getParentCategory();
    super.initState();
  }

  Future<void> getProducts() async {
    setState(() {
      _products = [];
    });
    if (hasChildren(_categories[selectedIndex])) {
      var category = getSubCategories(_categories[selectedIndex]);
      for (var item in category) {
        var data = await _service.fetchProductsByCategory(categoryId: item.id);
        setState(() {
          _products = [..._products, ...data];
        });
      }
    } else {
      var data = await _service.fetchProductsByCategory(
          categoryId: _categories[selectedIndex].id);
      setState(() {
        _products = data;
      });
    }
  }

  List<Category> getSubCategories(id) {
    return widget.categories.where((o) => o.parent == id).toList();
  }

  bool hasChildren(id) {
    return widget.categories.where((o) => o.parent == id).toList().isNotEmpty;
  }

  void getParentCategory() {
    setState(() {
      _categories =
          widget.categories.where((item) => item.parent == '0').toList();
    });
    getProducts();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenSize = MediaQuery.of(context).size;

    return Row(
      children: <Widget>[
        Container(
          width: 100,
          color: Theme.of(context).primaryColorLight,
          child: ListView.builder(
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                  getProducts();
                },
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 15, left: 4, right: 4),
                    child: Center(
                      child: Text(
                        _categories[index] != null &&
                                _categories[index].name != null
                            ? _categories[index].name.toUpperCase()
                            : '',
                        style: TextStyle(
                          fontSize: 10,
                          color: selectedIndex == index
                              ? theme.primaryColor
                              : theme.accentColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: ProductList(
            products: _products,
            width: screenSize.width - 100,
            padding: 4.0,
            layout: "list",
          ),
        )
      ],
    );
  }
}
