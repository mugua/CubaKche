import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/app.dart';
import '../../models/cart/cart_model.dart';
import '../../models/product/product.dart';
import '../../models/recent_product.dart';
import '../../routes/aware.dart';
import '../../screens/detail/index.dart';
import '../common/start_rating.dart';
import 'heart_button.dart';

class ProductCard extends StatelessWidget {
  final Product item;
  final width;
  final maxWidth;
  final marginRight;
  final kSize size;
  final bool isHero;
  final bool showCart;
  final bool showHeart;
  final height;
  final bool hideDetail;
  final offset;
  final tablet;

  ProductCard(
      {this.item,
      this.width,
      this.maxWidth,
      this.size = kSize.medium,
      this.isHero = false,
      this.showHeart = false,
      this.showCart = false,
      this.height,
      this.offset,
      this.hideDetail = false,
      this.tablet,
      this.marginRight = 6.0});

  Widget getImageFeature(onTapProduct) {
    // double _maxWidth = maxWidth ?? width;
    // double _height = math.min(_maxWidth * 1.2, height ?? width * 1.2);

    return GestureDetector(
      onTap: onTapProduct,
      child: isHero
          ? Hero(
              tag: 'product-${item.id}',
              child: Tools.image(
                url: item.imageFeature,
                width: width,
                size: kSize.medium,
                isResize: true,
                // height: _height,
                fit: BoxFit.cover,
              ),
            )
          : Tools.image(
              url: item.imageFeature,
              width: width,
              size: kSize.medium,
              isResize: true,
              // height: _height,
              fit: BoxFit.cover,
              offset: offset ?? 0.0,
            ),
    );
  }

  onTapProduct(context) {
    if (item.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false).addRecentProduct(item);
    //Load update product detail screen for FluxBuilder
    eventBus.fire(-1);

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (BuildContext context) => RouteAwareWidget(
          'detail',
          child: Detail(product: item),
        ),
        fullscreenDialog: kLayoutWeb,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final addProductToCart =
        Provider.of<CartModel>(context, listen: false).addProductToCart;
    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final isTablet = tablet ?? Tools.isTablet(MediaQuery.of(context));

    double titleFontSize = isTablet ? 18.0 : 14.0;
    double priceFontSize = isTablet ? 16.0 : 12.0;
    double ratingCountFontSize = isTablet ? 16.0 : 12.0;
    double iconSize = isTablet ? 20.0 : 18.0;
    double starSize = isTablet ? 16.0 : 10.0;

    final gauss = offset != null
        ? math.exp(-(math.pow(offset.abs() - 0.5, 2) / 0.08))
        : 0.0;
    bool isSale = (item.onSale ?? false) &&
        Tools.getPriceProductValue(item, currency, onSale: true) !=
            Tools.getPriceProductValue(item, currency, onSale: false);
    if (hideDetail) {
      return getImageFeature(
        () => onTapProduct(context),
      );
    }
    return Stack(
      children: <Widget>[
        Container(
          constraints: BoxConstraints(maxWidth: maxWidth ?? width),
          width: width,
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(3.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 15.0),
                      child: Transform.translate(
                        offset: Offset(18 * gauss, 0.0),
                        child: getImageFeature(
                          () => onTapProduct(context),
                        ),
                      ),
                    ),
                    if ((item.onSale ?? false) && item.regularPrice.isNotEmpty)
                      Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.only(
                                      bottomRight: Radius.circular(8))),
                              child: Text(
                                '${(100 - double.parse(item.price) / double.parse(item.regularPrice.toString()) * 100).toInt()} %',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                              )))
                  ],
                ),
              ),
              Text(item.name ?? '',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1),
              SizedBox(height: 6),
              Wrap(
                children: <Widget>[
                  Text(
                    item.type == 'grouped'
                        ? 'From ${Tools.getPriceProduct(item, currency, onSale: true)}'
                        : Tools.getPriceProduct(item, currency, onSale: true),
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          fontSize: priceFontSize,
                          color: theme.accentColor,
                        ),
                  ),
                  if (isSale) SizedBox(width: 5),
                  if (isSale)
                    Text(
                      item.type == 'grouped'
                          ? ''
                          : Tools.getPriceProduct(item, currency,
                              onSale: false),
                      style: Theme.of(context).textTheme.headline6.copyWith(
                            fontSize: priceFontSize,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.6),
                            decoration: TextDecoration.lineThrough,
                          ),
                    ),
                ],
              ),
              SizedBox(height: 4),
              SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    if (kAdvanceConfig['EnableRating'])
                      if (kAdvanceConfig['hideEmptyProductListRating'] ==
                              false ||
                          (item.ratingCount != null && item.ratingCount > 0))
                        SmoothStarRating(
                            allowHalfRating: true,
                            starCount: 5,
                            rating: item.averageRating ?? 0.0,
                            size: starSize,
                            color: theme.primaryColor,
                            borderColor: theme.primaryColor,
                            label: Text(
                              item.ratingCount == 0 || item.ratingCount == null
                                  ? ''
                                  : '${item.ratingCount}',
                              style: TextStyle(
                                fontSize: ratingCountFontSize,
                              ),
                            ),
                            spacing: 0.0),
                    SizedBox(width: 10),
                    if (showCart &&
                        !item.isEmptyProduct() &&
                        item.type != "variable")
                      IconButton(
                          padding: const EdgeInsets.all(2.0),
                          icon: Icon(Icons.add_shopping_cart, size: iconSize),
                          onPressed: () {
                            addProductToCart(product: item);
                          }),
                  ],
                ),
              )
            ],
          ),
        ),
        if (showHeart && !item.isEmptyProduct())
          Positioned(
            top: 10,
            right: 10,
            child: HeartButton(product: item, size: 18),
          )
      ],
    );
  }
}
