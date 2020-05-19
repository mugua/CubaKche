import 'package:flutter/material.dart';
import 'package:flutter_widgets/flutter_widgets.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../generated/l10n.dart';
import '../../../models/app.dart';
import '../../../models/product/product.dart';
import '../../../services/index.dart';
import '../../../widgets/product/product_card_view.dart';
import 'vertical_simple_list.dart';

class VerticalViewLayout extends StatefulWidget {
  final config;

  VerticalViewLayout({this.config});

  @override
  _PinterestLayoutState createState() => _PinterestLayoutState();
}

class _PinterestLayoutState extends State<VerticalViewLayout> {
  final Services _service = Services();
  List<Product> _products = [];
  bool canLoad = true;
  int _page = 0;

  _loadProduct() async {
    var config = widget.config;
    _page = _page + 1;
    config['page'] = _page;
    if (!canLoad) return;
    var newProducts = await _service.fetchProductsLayout(
        config: config, lang: Provider.of<AppModel>(context, listen: false).locale);
    if (newProducts.isEmpty) {
      setState(() {
        canLoad = false;
      });
    }
    setState(() {
      _products = [..._products, ...newProducts];
    });
  }

  @override
  Widget build(BuildContext context) {
    int widthContent = 0;
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    if (widget.config['layout'] == "card") {
      widthContent = 1; //one column
    } else if (widget.config['layout'] == "columns") {
      widthContent = isTablet ? 4 : 3; //three columns
    } else {
      //layout is list
      widthContent = isTablet ? 3 : 2; //two columns
    }
    // ignore: division_optimization
    int rows = (_products.length / widthContent).toInt();
    if (rows * widthContent < _products.length) rows++;

    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: Column(
        children: <Widget>[
          SingleChildScrollView(
            child: widget.config['layout'] == 'list'
                ? Column(
                    children: List.generate(_products.length, (index) {
                      return SimpleListView(
                        item: _products[index],
                        type: SimpleListType.BackgroundColor,
                      );
                    }),
                  )
                : Column(
                    children: List.generate(rows, (index) {
                      return Row(
                        children: List.generate(widthContent, (child) {
                          return Expanded(
                            child: index * widthContent + child < _products.length
                                ? LayoutBuilder(
                                    builder: (context, constraints) {
                                      return ProductCard(
                                        item: _products[index * widthContent + child],
                                        showHeart: true,
                                        showCart: widget.config['layout'] != "columns",
                                        width: constraints.maxWidth,
                                      );
                                    },
                                  )
                                : Container(),
                          );
                        }),
                      );
                    }),
                  ),
          ),
          VisibilityDetector(
            key: Key("loading_vertical"),
            child: !canLoad
                ? Container()
                : Container(
                    child: Center(
                      child: Text(S.of(context).loading),
                    ),
                  ),
            onVisibilityChanged: (VisibilityInfo info) => _loadProduct(),
          )
        ],
      ),
    );
  }
}
