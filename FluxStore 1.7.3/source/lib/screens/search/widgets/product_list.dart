import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../models/app.dart';
import '../../../common/constants.dart';
import '../../../models/product/product.dart';
import '../../../models/search.dart';
import '../../../services/index.dart';
import '../../../widgets/product/product_card_view.dart';

class ProductList extends StatefulWidget {
  final name;
  final padding;
  final products;

  ProductList({this.products, this.name, this.padding = 10.0});

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  RefreshController _refreshController;
  final Services _service = Services();
  List<Product> _products;
  int _page = 1;
  bool _isEnd = false;

  @override
  void initState() {
    super.initState();
    _products = widget.products ?? [];
    _refreshController = RefreshController(initialRefresh: _products.isEmpty);
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_products != widget.products) {
      setState(() {
        _products = widget.products;
      });
    }
  }

  Future<void> _loadProduct() async {
    var newProducts = await _service.searchProducts(
        name: widget.name,
        page: _page,
        lang: Provider.of<AppModel>(context, listen: false).locale);
    if (newProducts.isEmpty) {
      _isEnd = true;
    } else {
      _products.addAll(newProducts);
      Provider.of<SearchModel>(context, listen: false).refeshProduct(_products);
    }
    setState(() {});
  }

  Future<void> _onRefresh() async {
    _page = 1;
    _products = [];
    await _loadProduct();
    _refreshController.refreshCompleted();
  }

  Future<void> _onLoading() async {
    if (_isEnd == false) {
      _page = _page + 1;
      await _loadProduct();
    }
    _refreshController.loadComplete();
  }

  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final widthContent = (constraints.maxWidth / 2) - 4;
        return SmartRefresher(
          header: MaterialClassicHeader(
              backgroundColor: Theme.of(context).primaryColor),
          controller: _refreshController,
          enablePullUp: !_isEnd,
          enablePullDown: false,
          onRefresh: _onRefresh,
          onLoading: _onLoading,
          footer: kCustomFooter(context),
          child: _products == null
              ? Container()
              : ListView(
                  scrollDirection: Axis.vertical,
                  children: <Widget>[
                    Wrap(
                      alignment: WrapAlignment.center,
                      children: <Widget>[
                        for (var i = 0; i < _products.length; i++)
                          ProductCard(
                            item: _products[i],
                            width: widthContent,
                            maxWidth: constraints.maxWidth / 2,
                          )
                      ],
                    ),
                  ],
                ),
        );
      },
    );
  }
}
