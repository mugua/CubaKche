import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/product/product_attribute.dart';
import '../../models/product/product.dart';

class AdditionalInformation extends StatelessWidget {
  final Product product;

  AdditionalInformation(this.product);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (var i = 0; i < product.infors.length; i++)
          renderItem(product.infors[i])
      ],
    );
  }

  Widget renderItem(ProductAttribute attribute) {
    if (attribute == null) Container();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 80,
            child: Text(attribute.name.toUpperCase(),
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
          Container(
              width: 1, height: 30, decoration: BoxDecoration(color: kGrey200)),
          SizedBox(width: 15),
          Expanded(
            child: attribute.name != "color"
                ? Text(attribute.options.join(", "),
                    style: TextStyle(color: kGrey600, fontSize: 14))
                : Row(
                    children: <Widget>[
                      for (var i = 0; i < attribute.options.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: HexColor(kNameToHex[
                                  attribute.options[i].toLowerCase()]),
                            ),
                          ),
                        )
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
