import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/category/category.dart';
import '../../../models/category/category_model.dart';
import '../../../models/product/product.dart';
import '../../../services/index.dart';
import '../../../widgets/product/product_card_view.dart';
import 'product_select_card.dart';

class MenuLayout extends StatefulWidget {
  final config;

  MenuLayout({this.config});

  @override
  _StateSelectLayout createState() => _StateSelectLayout();
}

class _StateSelectLayout extends State<MenuLayout> {
  int position = 0;
  bool loading = false;
  List<List<Product>> products = [];
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Future<bool> getAllListProducts({
    minPrice,
    maxPrice,
    orderBy,
    order,
    lang,
    page = 1,
    categories,
  }) async {
    if (this.products.isNotEmpty) return true;
    List<List<Product>> products = [];
    Services _service = Services();
    for (var category in categories) {
      try {
        var product = await _service.fetchProductsByCategory(
          categoryId: category.id,
          minPrice: minPrice,
          maxPrice: maxPrice,
          orderBy: orderBy,
          order: order,
          lang: lang,
          page: page,
        );
        products.add(product);
        setState(() {
          this.products = products;
        });
      } catch (e) {
        products.add([]);
        setState(() {
          this.products = products;
        });
      }
    }
    return true;
  }

  Future<List<Category>> getAllCategory() async {
    final categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    var listCategories =
        categories.where((item) => item.parent == '0').toList();
    List<Category> _categories = [];

    for (var category in listCategories) {
      var children = categories.where((o) => o.parent == category.id).toList();
      if (children.isNotEmpty) {
        _categories = [..._categories, ...children];
      } else {
        _categories = [..._categories, category];
      }
    }
    return _categories;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: getAllCategory(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.7,
            child: Center(
              child: kLoadingWidget(context),
            ),
          );
        }
        return Column(
          children: <Widget>[
            Container(
              height: 70,
              padding: const EdgeInsets.only(top: 15),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(snapshot.data.length, (index) {
                  bool check = (products.length > index)
                      ? (products[index].isEmpty ? false : true)
                      : true;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        position = index;
                      });
                    },
                    child: !check
                        ? Container()
                        : Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Column(
                              children: <Widget>[
                                Padding(
                                  child: Text(
                                    snapshot.data[index].name.toUpperCase(),
                                    style: TextStyle(
                                        color: index == position
                                            ? Theme.of(context).primaryColor
                                            : Theme.of(context).accentColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  padding: const EdgeInsets.only(bottom: 8),
                                ),
                                index == position
                                    ? Container(
                                        height: 4,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color:
                                                Theme.of(context).primaryColor),
                                        width: 20,
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                  );
                }),
              ),
            ),
            FutureBuilder<bool>(
              future: getAllListProducts(categories: snapshot.data),
              builder: (context, check) {
                if (products.isEmpty) {
                  return StaggeredGridView.countBuilder(
                    crossAxisCount: 4,
                    key: Key(snapshot.data[position].id.toString()),
                    shrinkWrap: true,
                    controller: _controller,
                    itemCount: 4,
                    itemBuilder: (context, value) {
                      return ProductCard(
                        item: Product.empty(value.toString()),
                        width: MediaQuery.of(context).size.width / 2,
                      );
                    },
                    staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                  );
                }
                if (products[position] == null || products[position].isEmpty) {
                  return Container(
                    height: MediaQuery.of(context).size.width / 2,
                    child: Center(
                      child: Text(S.of(context).noProduct),
                    ),
                  );
                }
                return MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return StaggeredGridView.countBuilder(
                        crossAxisCount: 4,
                        key: Key(snapshot.data[position].id.toString()),
                        shrinkWrap: true,
                        controller: _controller,
                        itemCount: products[position].length,
                        itemBuilder: (context, value) {
                          return ProductSelectCard(
                            item: products[position][value],
                            width: constraints.maxWidth / 2,
                          );
                        },
                        staggeredTileBuilder: (index) => StaggeredTile.fit(2),
                      );
                    },
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}
