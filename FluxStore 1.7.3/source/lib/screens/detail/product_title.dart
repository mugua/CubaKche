import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiver/strings.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/product/product.dart';
import '../../models/product/product_model.dart';
import '../../models/product/product_variation.dart';
import '../../widgets/common/start_rating.dart';

class ProductTitle extends StatefulWidget {
  final Product product;

  ProductTitle(this.product);

  @override
  _ProductTitleState createState() => _ProductTitleState();
}

class _ProductTitleState extends State<ProductTitle> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    ProductVariation productVariation;
    productVariation = Provider.of<ProductModel>(context).productVariation;
    final currency = Provider.of<AppModel>(context).currency;

    final regularPrice = productVariation != null
        ? productVariation.regularPrice
        : widget.product.regularPrice;
    final onSale = productVariation != null
        ? productVariation.onSale
        : widget.product.onSale;
    final price = productVariation != null
        ? productVariation.price
        : isNotBlank(widget.product.price)
            ? widget.product.price
            : widget.product.regularPrice;
    int sale = 100;
    if (regularPrice.isNotEmpty && double.parse(regularPrice) > 0) {
      sale = (100 - (double.parse(price) / double.parse(regularPrice)) * 100)
          .toInt();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: 10),
        Container(
          width: MediaQuery.of(context).size.width,
          child: Text(
            widget.product.name,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: <Widget>[
            Text(
              widget.product.type != 'grouped'
                  ? Tools.getCurrecyFormatted(price, currency: currency)
                  : Provider.of<ProductModel>(context).detailPriceRange,
              style: Theme.of(context).textTheme.subtitle1.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                    color: theme.accentColor,
                  ),
            ),
            if (onSale && widget.product.type != 'grouped')
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(width: 5),
                  Text(
                      Tools.getCurrecyFormatted(regularPrice,
                          currency: currency),
                      style: Theme.of(context).textTheme.subtitle1.copyWith(
                          fontSize: 14,
                          color: Theme.of(context).accentColor.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                          decoration: TextDecoration.lineThrough)),
                  SizedBox(width: 5),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      S.of(context).sale('$sale'),
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                          fontSize: 14),
                    ),
                  )
                ],
              )
          ],
        ),
        if (kAdvanceConfig['EnableRating'])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: SmoothStarRating(
              allowHalfRating: true,
              starCount: 5,
              spacing: 0.0,
              rating: widget.product.averageRating,
              size: 17.0,
              color: theme.primaryColor,
              borderColor: theme.primaryColor,
              label: Text(
                " (${widget.product.ratingCount})",
                style: Theme.of(context).textTheme.subtitle1.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).accentColor.withOpacity(0.8),
                    ),
              ),
            ),
          ),
      ],
    );
  }
}
