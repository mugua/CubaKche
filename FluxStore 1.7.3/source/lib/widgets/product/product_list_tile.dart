import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/cart/cart_model.dart';
import '../../models/product/product.dart';
import '../../models/recent_product.dart';
import '../../routes/aware.dart';
import '../../screens/detail/index.dart';
import '../common/start_rating.dart';
import 'heart_button.dart';

class ProductItemTileView extends StatelessWidget {
  final Product item;

  ProductItemTileView({this.item});

  onTapProduct(context) {
    if (item.imageFeature == '') return;
    Provider.of<RecentModel>(context, listen: false).addRecentProduct(item);
    //Load update item detail screen for FluxBuilder
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

  Widget getImageFeature(onTapProduct) {
    return GestureDetector(
      onTap: onTapProduct,
      child: Tools.image(
        url: item.imageFeature,
        size: kSize.medium,
        isResize: true,
        // height: _height,
        fit: BoxFit.fitHeight,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: InkWell(
              onTap: () => onTapProduct(context),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2.0),
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 15.0),
                      child: getImageFeature(
                        () => onTapProduct(context),
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
            ),
          ),
          SizedBox(width: 4),
          Expanded(
            flex: 3,
            child: _ProductDescription(item: item),
          ),
        ],
      ),
    );
  }
}

class _ProductDescription extends StatelessWidget {
  const _ProductDescription({Key key, this.item}) : super(key: key);

  final Product item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final addProductToCart =
        Provider.of<CartModel>(context, listen: false).addProductToCart;

    final currency = Provider.of<AppModel>(context, listen: false).currency;
    final isTablet = Tools.isTablet(MediaQuery.of(context));

    bool isSale = (item.onSale ?? false) &&
        Tools.getPriceProductValue(item, currency, onSale: true) !=
            Tools.getPriceProductValue(item, currency, onSale: false);

    double ratingCountFontSize = isTablet ? 16.0 : 12.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 10),
            Text(
              item.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15.0,
              ),
            ),
            SizedBox(height: 4),
            if (isSale) SizedBox(width: 5),
            Wrap(
              children: <Widget>[
                Text(
                  item.type == 'grouped'
                      ? 'From ${Tools.getPriceProduct(item, currency, onSale: true)}'
                      : Tools.getPriceProduct(item, currency, onSale: true),
                  style: Theme.of(context).textTheme.headline6.copyWith(
                        fontSize: 18,
                        color: theme.accentColor,
                      ),
                ),
                SizedBox(width: 10),
                if (isSale)
                  Text(
                    Tools.getPriceProduct(item, currency, onSale: false),
                    style: Theme.of(context).textTheme.headline6.copyWith(
                          fontSize: 16,
                          color: Theme.of(context).accentColor.withOpacity(0.5),
                          decoration: TextDecoration.lineThrough,
                        ),
                  ),
              ],
            ),
            SizedBox(height: 20),
            if (kAdvanceConfig['EnableRating'])
              if (kAdvanceConfig['hideEmptyProductListRating'] == false ||
                  (item.ratingCount != null && item.ratingCount > 0))
                SmoothStarRating(
                  allowHalfRating: true,
                  starCount: 5,
                  rating: item.averageRating ?? 0.0,
                  size: 14,
                  color: theme.primaryColor,
                  borderColor: theme.primaryColor,
                  label: Text(
                    item.ratingCount == 0 || item.ratingCount == null
                        ? ''
                        : '${item.ratingCount} ',
                    style: TextStyle(
                      fontSize: ratingCountFontSize,
                    ),
                  ),
                  spacing: 0.0,
                ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                FlatButton(
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text(S.of(context).addToCart),
                  onPressed: () => addProductToCart(product: item),
                ),
                Spacer(),
                CircleAvatar(child: HeartButton(product: item, size: 18)),
                SizedBox(width: 8)
              ],
            ),
            SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}
