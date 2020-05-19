import 'package:flutter/material.dart';
import '../../services/index.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/app.dart';
import '../../models/product/product.dart';
import '../../models/product/product_variation.dart';
import 'product_variant.dart';

class ShoppingCartRow extends StatelessWidget {
  ShoppingCartRow(
      {@required this.product,
      @required this.quantity,
      this.onRemove,
      this.onChangeQuantity,
      this.variation});

  final Product product;
  final ProductVariation variation;
  final int quantity;
  final Function onChangeQuantity;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    String currency = Provider.of<AppModel>(context).currency;
    final price =
        Services().widget.getPriceItemInCart(product, variation, currency);
    final imageFeature = variation != null && variation.imageFeature != null
        ? variation.imageFeature
        : product.imageFeature;

    ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(children: [
          Row(
            key: ValueKey(product.id),
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove_circle_outline),
                onPressed: onRemove,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Stack(children: <Widget>[
                        Container(
                            width: constraints.maxWidth * 0.25,
                            height: constraints.maxWidth * 0.3,
                            child: Tools.image(url: imageFeature)),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.white),
                            child: QuantitySelection(
                              width: 60,
                              height: 32,
                              color: Colors.black,
                              value: quantity,
                              onChanged: onChangeQuantity,
                            ),
                          ),
                        )
                      ]),
                      SizedBox(width: 16.0),
                      Expanded(
                        child: Container(
                          height: constraints.maxWidth * 0.3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  color: theme.accentColor,
                                ),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 7),
                              Text(
                                price,
                                style: TextStyle(
                                    color: theme.accentColor, fontSize: 14),
                              ),
                              SizedBox(height: 10),
                              variation != null
                                  ? Services()
                                      .widget
                                      .renderVariantCartItem(variation)
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Divider(color: kGrey200, height: 1),
          SizedBox(height: 10.0),
        ]);
      },
    );
  }
}
