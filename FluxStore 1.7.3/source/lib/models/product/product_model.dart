import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../services/index.dart';
import 'product.dart';
import 'product_variation.dart';

class ProductModel with ChangeNotifier {
  final Services _service = Services();
  List<List<Product>> products;
  String message;

  /// current select product id/name
  String categoryId;
  String categoryName;
  int tagId;

  //list products for products screen
  bool isFetching = false;
  List<Product> productsList;
  String errMsg;
  bool isEnd;

  ProductVariation productVariation;
  List<Product> lstGroupedProduct;
  String cardPriceRange;
  String detailPriceRange = '';

  changeProductVariation(ProductVariation variation) {
    productVariation = variation;
    notifyListeners();
  }

  Future<List<Product>> fetchGroupedProducts({Product product}) async {
    lstGroupedProduct = [];
    for (int productID in product.groupedProducts) {
      await _service.getProduct(productID).then((value) {
        lstGroupedProduct.add(value);
      });
    }
    return lstGroupedProduct;
  }

  changeDetailPriceRange(String currency) {
    if (lstGroupedProduct.isNotEmpty) {
      double currentPrice = double.parse(lstGroupedProduct[0].price);
      double max = currentPrice;
      double min = 0;
      for (var product in lstGroupedProduct) {
        min = double.parse(product.price);
        if (min > max) {
          double temp = min;
          max = min;
          min = temp;
        }
        detailPriceRange = currentPrice != max
            ? '${Tools.getCurrecyFormatted(currentPrice, currency: currency)} - ${Tools.getCurrecyFormatted(max, currency: currency)}'
            : '${Tools.getCurrecyFormatted(currentPrice, currency: currency)}';
      }
    }
  }

  Future<List<Product>> fetchProductLayout(config, lang) async {
    return _service.fetchProductsLayout(config: config, lang: lang);
  }

  void fetchProductsByCategory({categoryId, categoryName}) {
    this.categoryId = categoryId;
    this.categoryName = categoryName;
    notifyListeners();
  }

  void updateTagId({tagId}) {
    this.tagId = tagId;
    notifyListeners();
  }

  Future<void> saveProducts(Map<String, dynamic> data) async {
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

  Future<void> getProductsList({
    categoryId,
    minPrice,
    maxPrice,
    orderBy,
    order,
    lang,
    page,
    featured,
    onSale,
    attribute,
    attributeTerm,
  }) async {
    try {
      if (categoryId != null) {
        this.categoryId = categoryId;
      }
      isFetching = true;
      isEnd = false;
      notifyListeners();

      final products = await _service.fetchProductsByCategory(
        categoryId: categoryId,
        tagId: tagId,
        minPrice: minPrice,
        maxPrice: maxPrice,
        orderBy: orderBy,
        order: order,
        lang: lang,
        page: page,
        featured: featured,
        onSale: onSale,
        attribute: attribute,
        attributeTerm: attributeTerm,
      );
      isEnd = products.isEmpty || products.length < ApiPageSize;
      bool isExisted = productsList.indexWhere(
              (o) => products.isNotEmpty && o.id == products[0].id) >
          -1;
      if (!isExisted) {
        if (page == 0 || page == 1) {
          productsList = products;
        } else {
          productsList = [...productsList, ...products];
        }
      } else {
        isEnd = true;
      }

      isFetching = false;
      errMsg = null;
      notifyListeners();
    } catch (err, trace) {
      errMsg =
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString();
      isFetching = false;
      print(trace.toString());
      notifyListeners();
    }
  }

  void setProductsList(products) {
    productsList = products;
    isFetching = false;
    isEnd = false;
    notifyListeners();
  }
}
