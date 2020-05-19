import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/category/category.dart';
import '../../models/category/category_model.dart';
import '../../models/filter_attribute.dart';
import '../../models/product/product.dart';
import '../../models/product/product_model.dart';
import '../../services/index.dart';
import '../../widgets/asymmetric/asymmetric_view.dart';
import '../../widgets/backdrop/backdrop.dart';
import '../../widgets/backdrop/backdrop_menu.dart';
import '../../widgets/layout/layout_web.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../../widgets/product/product_list.dart';
import 'products_backdrop.dart';

class ProductsPage extends StatefulWidget {
  final List<Product> products;
  final String categoryId;
  final config;

  ProductsPage({
    this.products,
    this.categoryId,
    this.config,
  });

  @override
  State<StatefulWidget> createState() {
    return ProductsPageState();
  }
}

class ProductsPageState extends State<ProductsPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  String newCategoryId;
  double minPrice;
  double maxPrice;
  String orderBy;
  String orDer;
  String attribute;
//  int attributeTerm;
  bool featured;
  bool onSale;

  bool isFiltering = false;
  List<Product> products = [];
  String errMsg;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    setState(() {
      newCategoryId = widget.categoryId ?? '-1';
    });
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450),
      value: 1.0,
    );

    if (widget.config != null) {
      onRefresh();
    }
  }

  void onFilter(
      {minPrice, maxPrice, categoryId, attribute, currentSelectedTerms}) {
    _controller.forward();

    final productModel = Provider.of<ProductModel>(context, listen: false);
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    newCategoryId = categoryId;
    this.minPrice = minPrice;
    this.maxPrice = maxPrice;
    if (attribute != null && !attribute.isEmpty) this.attribute = attribute;
    String terms = '';

    if (currentSelectedTerms != null) {
      for (int i = 0; i < currentSelectedTerms.length; i++) {
        if (currentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
    }

    productModel.setProductsList(List<Product>());

    productModel.getProductsList(
      categoryId: categoryId == -1 ? null : categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      page: 1,
      lang: Provider.of<AppModel>(context, listen: false).locale,
      orderBy: orderBy,
      order: orDer,
      featured: featured,
      onSale: onSale,
      attribute: attribute,
      attributeTerm: terms.isEmpty ? null : terms,
    );
  }

  void onSort(order) {
    if (order == "date") {
      featured = null;
      onSale = null;
    } else {
      featured = order == "featured";
      onSale = order == "on_sale";
    }

    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    String terms = '';
    for (int i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
      if (filterAttr.lstCurrentSelectedTerms[i]) {
        terms += '${filterAttr.lstCurrentAttr[i].id},';
      }
    }
    Provider.of<ProductModel>(context, listen: false).getProductsList(
        categoryId: newCategoryId == '-1' ? null : newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context, listen: false).locale,
        page: 1,
        orderBy: 'date',
        order: 'desc',
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: terms);
  }

  Future<void> onRefresh() async {
    _page = 1;
    if (widget.config == null) {
      final filterAttr =
          Provider.of<FilterAttributeModel>(context, listen: false);
      String terms = '';
      for (int i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
        if (filterAttr.lstCurrentSelectedTerms[i]) {
          terms += '${filterAttr.lstCurrentAttr[i].id},';
        }
      }
      await Provider.of<ProductModel>(context, listen: false).getProductsList(
        categoryId: newCategoryId == '-1' ? null : newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context, listen: false).locale,
        page: 1,
        orderBy: orderBy,
        order: orDer,
        attribute: attribute,
        attributeTerm: terms,
      );
    } else {
      try {
        var newProducts = await Services().fetchProductsLayout(
            config: widget.config,
            lang: Provider.of<AppModel>(context, listen: false).locale);
        setState(() {
          products = newProducts;
        });
      } catch (err) {
        setState(() {
          errMsg = err;
        });
      }
    }
  }

  Widget renderCategoryAppbar() {
    final category = Provider.of<CategoryModel>(context);
    String parentCategory = newCategoryId;
    if (category.categories != null && category.categories.isNotEmpty) {
      parentCategory =
          getParentCategories(category.categories, parentCategory) ??
              parentCategory;
      final listSubCategory =
          getSubCategories(category.categories, parentCategory);

      if (listSubCategory.length < 2) return null;

      return ListenableProvider.value(
        value: category,
        child: Consumer<CategoryModel>(builder: (context, value, child) {
          if (value.isLoading) {
            return Center(child: kLoadingWidget(context));
          }

          if (value.categories != null) {
            List<Widget> _renderListCategory = List();
            _renderListCategory.add(SizedBox(width: 10));

            _renderListCategory.add(_renderItemCategory(
                categoryId: parentCategory,
                categoryName: S.of(context).seeAll));

            _renderListCategory.addAll([
              for (var category
                  in getSubCategories(value.categories, parentCategory))
                _renderItemCategory(
                    categoryId: category.id, categoryName: category.name)
            ]);

            return Container(
              color: Theme.of(context).primaryColor,
              height: 50,
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: _renderListCategory,
                  ),
                ),
              ),
            );
          }

          return Container();
        }),
      );
    }
    return null;
  }

  List<Category> getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }

  String getParentCategories(categories, id) {
    for (var item in categories) {
      if (item.id == id) {
        return (item.parent == null || item.parent == '0') ? null : item.parent;
      }
    }
    return '0';
    // return categories.where((o) => ((o.id == id) ? o.parent : null));
  }

  Widget _renderItemCategory({String categoryId, String categoryName}) {
    return GestureDetector(
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        margin: EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          color:
              newCategoryId == categoryId ? Colors.white24 : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          categoryName.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      onTap: () {
        Provider.of<ProductModel>(context, listen: false).getProductsList(
          categoryId: categoryId,
          page: 1,
          lang: Provider.of<AppModel>(context, listen: false).locale,
        );

        setState(() {
          _page = 1;
          newCategoryId = categoryId;
          onFilter(
              minPrice: minPrice,
              maxPrice: maxPrice,
              categoryId: newCategoryId);
        });
      },
    );
  }

  void onLoadMore() {
    _page = _page + 1;
    final filterAttr =
        Provider.of<FilterAttributeModel>(context, listen: false);
    String terms = '';
    for (int i = 0; i < filterAttr.lstCurrentSelectedTerms.length; i++) {
      if (filterAttr.lstCurrentSelectedTerms[i]) {
        terms += '${filterAttr.lstCurrentAttr[i].id},';
      }
    }
    Provider.of<ProductModel>(context, listen: false).getProductsList(
        categoryId: newCategoryId == '-1' ? null : newCategoryId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        lang: Provider.of<AppModel>(context, listen: false).locale,
        page: _page,
        orderBy: orderBy,
        order: orDer,
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: terms);
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<ProductModel>(context, listen: false);
    final title = product.categoryName ?? S.of(context).products;
    final layout = widget.config != null && widget.config["layout"] != null
        ? widget.config["layout"]
        : Provider.of<AppModel>(context, listen: false).productListLayout;

    final isListView = layout != 'horizontal';

    /// load the product base on default 2 columns view or AsymmetricView
    /// please note that the AsymmetricView is not ready support for loading per page.
    final backdrop =
        ({products, isFetching, errMsg, isEnd, width}) => ProductBackdrop(
              backdrop: Backdrop(
                  frontLayer: isListView
                      ? ProductList(
                          products: products,
                          onRefresh: onRefresh,
                          onLoadMore: onLoadMore,
                          isFetching: isFetching,
                          errMsg: errMsg,
                          isEnd: isEnd,
                          layout: layout,
                          width: width,
                        )
                      : AsymmetricView(
                          products: products,
                          isFetching: isFetching,
                          isEnd: isEnd,
                          onLoadMore: onLoadMore,
                          width: width),
                  backLayer: BackdropMenu(onFilter: onFilter),
                  frontTitle: Text(title),
                  backTitle: Text(S.of(context).filter),
                  controller: _controller,
                  onSort: onSort,
                  appbarCategory: renderCategoryAppbar()),
              expandingBottomSheet:
                  ExpandingBottomSheet(hideController: _controller),
            );

    Widget buildaMain = Container(
      child: LayoutBuilder(
        builder: (context, constraint) {
          return FractionallySizedBox(
            widthFactor: 1.0,
            child: ListenableProvider.value(
              value: product,
              child: Consumer<ProductModel>(builder: (context, value, child) {
                return backdrop(
                    products: value.productsList,
                    isFetching: value.isFetching,
                    errMsg: value.errMsg,
                    isEnd: value.isEnd,
                    width: constraint.maxWidth);
              }),
            ),
          );
        },
      ),
    );
    return kLayoutWeb
        ? WillPopScope(
            onWillPop: () async {
              LayoutWebCustom.changeStateMenu(true);
              Navigator.of(context).pop();
              return false;
            },
            child: buildaMain)
        : buildaMain;
  }
}
