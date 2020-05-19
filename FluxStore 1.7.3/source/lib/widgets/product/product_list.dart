import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/product/product.dart';
import '../../widgets/product/product_card_view.dart';
import "../home/vertical/pinterest_card.dart";
import 'product_list_tile.dart';

class ProductList extends StatefulWidget {
  final List<Product> products;
  final bool isFetching;
  final bool isEnd;
  final String errMsg;
  final width;
  final padding;
  final String layout;
  final Function onRefresh;
  final Function onLoadMore;

  ProductList({
    this.isFetching = false,
    this.isEnd = true,
    this.errMsg,
    this.products,
    this.width,
    this.padding = 8.0,
    this.onRefresh,
    this.onLoadMore,
    this.layout = "list",
  });

  @override
  _ProductListState createState() => _ProductListState();
}

class _ProductListState extends State<ProductList> {
  RefreshController _refreshController;

  List<Product> emptyList = [
    Product.empty('1'),
    Product.empty('2'),
    Product.empty('3'),
    Product.empty('4'),
    Product.empty('5'),
    Product.empty('6')
  ];

  @override
  initState() {
    super.initState();

    /// if there are existing product from previous navigate we don't need to enable the refresh
    _refreshController = RefreshController(initialRefresh: false);
  }

  _onRefresh() async {
    if (!widget.isFetching) {
      widget.onRefresh();
    }
  }

  _onLoading() async {
    print('onLoading');
    if (!widget.isFetching) {
      widget.onLoadMore();
    }
  }

  @override
  void didUpdateWidget(ProductList oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isFetching == false && oldWidget.isFetching == true) {
      _refreshController.refreshCompleted();
      _refreshController.loadComplete();
    }
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = widget.width / screenSize.height > 1.2;
    final widthScreen = widget.width != null ? widget.width : screenSize.width;
    var widthContent = 0.0;

    if (widget.layout == "card") {
      widthContent =
          isTablet ? 0.75 * widthScreen / 2 : widthScreen; //one column
    } else if (widget.layout == "columns") {
      widthContent =
          isTablet ? 0.78 * widthScreen / 5 : (widthScreen / 3); //three columns
    } else {
      //layout is list
      widthContent =
          isTablet ? 0.78 * widthScreen / 4 : (widthScreen / 2); //two columns
    }

    final productsList = (widget.products == null || widget.products.isEmpty) &&
            widget.isFetching
        ? emptyList
        : widget.products;

    if (productsList == null || productsList.isEmpty) {
      return Center(
          child: Text(S.of(context).noProduct,
              style: TextStyle(color: Colors.black)));
    }

    return SmartRefresher(
      header: MaterialClassicHeader(
        backgroundColor: Theme.of(context).backgroundColor,
      ),
      enablePullDown: true,
      enablePullUp: !widget.isEnd,
      controller: _refreshController,
      onRefresh: _onRefresh,
      onLoading: _onLoading,
      footer: kCustomFooter(context),
      child: widget.layout != "pinterest"
          ? Padding(
              padding: const EdgeInsets.only(left: 0.0),
              child: SingleChildScrollView(
                child: Wrap(
                  children: <Widget>[
                    if (widget.layout == "listTile")
                      for (var i = 0; i < productsList.length; i++)
                        ProductItemTileView(item: productsList[i]),

                    if (widget.layout != "listTile")
                      for (var i = 0; i < productsList.length; i++)
                        Container(
                          width: widthContent,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: ProductCard(
                              item: productsList[i],
                              showCart: widget.layout != "columns",
                              showHeart: true,
                              width: widthContent,
                              marginRight: widget.layout == "card" ? 0.0 : 10.0,
                              // tablet: widget.width / screenSize.height > 1.2,
                            ),
                          ),
                        ),

                    /// Load more widget
                    Container(
                      child: VisibilityDetector(
                        key: Key("loading_visible"),
                        child: Container(height: 100),
                        onVisibilityChanged: (VisibilityInfo info) =>
                            _onLoading(),
                      ),
                    )
                  ],
                ),
              ),
            )
          : StaggeredGridView.countBuilder(
              crossAxisCount: 4,
              mainAxisSpacing: 4.0,
              shrinkWrap: true,
              primary: false,
              crossAxisSpacing: 4.0,
              itemCount: productsList.length,
              itemBuilder: (context, index) => PinterestCard(
                item: productsList[index],
                showOnlyImage: false,
                width: MediaQuery.of(context).size.width / 2,
                showCart: false,
              ),
              staggeredTileBuilder: (index) => StaggeredTile.fit(2),
            ),
    );
  }
}
