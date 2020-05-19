import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/search.dart';
import '../../../../widgets/product/product_card_view.dart';

class Recent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return LayoutBuilder(
      builder: (context, constraints) {
        var screenWidth = constraints.maxWidth;

        return ListenableProvider.value(
          value: Provider.of<SearchModel>(context),
          child: Consumer<SearchModel>(builder: (context, model, child) {
            if (model.products == null || model.products.isEmpty) {
              return Container();
            }
            return Container(
              width: screenWidth,
              constraints: BoxConstraints(minHeight: 0),
              child: FittedBox(
                fit: BoxFit.cover,
                child: Container(
                  width: screenWidth,
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        width: screenWidth,
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Container(
                            width: screenWidth /
                                (2 / (MediaQuery.of(context).size.height / screenWidth)),
                            child: Row(
                              children: <Widget>[
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    S.of(context).recents,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Divider(
                        height: 1,
                        color: kGrey200,
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: screenWidth,
                        height: screenWidth * 0.35 + 120,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              for (var item in model.products)
                                FittedBox(
                                  child: ProductCard(
                                    item: item,
                                    width: screenWidth * 0.35,
                                  ),
                                )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
