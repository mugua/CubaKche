import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/product/product.dart';
import '../../services/index.dart';
import '../../widgets/common/expansion_info.dart';
import 'additional_information.dart';
import 'review.dart';

class ProductDescription extends StatelessWidget {
  final Product product;

  ProductDescription(this.product);

  @override
  Widget build(BuildContext context) {
    bool enableReview =
        Services().widget.enableProductReview && kProductDetail['enableReview'];

    return Column(
      children: <Widget>[
        SizedBox(height: 15),
        if (product.description != null)
          ExpansionInfo(
              title: S.of(context).description,
              children: <Widget>[
                HtmlWidget(
                  product.description.replaceAll('src="//', 'src="https://'),
                  webView: true,
                  textStyle: TextStyle(color: Theme.of(context).accentColor),
                ),
              ],
              expand: true),
        if (enableReview)
          Container(
            height: 1,
            decoration: BoxDecoration(color: kGrey200),
          ),
        if (enableReview)
          ExpansionInfo(
            title: S.of(context).readReviews,
            children: <Widget>[
              Reviews(product.id),
            ],
          ),
        Container(height: 1, decoration: BoxDecoration(color: kGrey200)),
        if (product.attributes.isNotEmpty)
          ExpansionInfo(
            title: S.of(context).additionalInformation,
            children: <Widget>[
              AdditionalInformation(product),
            ],
          ),
      ],
    );
  }
}
