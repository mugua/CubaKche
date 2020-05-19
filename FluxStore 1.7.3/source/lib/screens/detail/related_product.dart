import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/product/product.dart';
import '../../services/index.dart';
import '../../widgets/product/product_card_view.dart';

class RelatedProduct extends StatelessWidget {
  final Product product;

  RelatedProduct(this.product);

  final _memoizer = AsyncMemoizer<List<Product>>();
  final services = Services();

  @override
  Widget build(BuildContext context) {
    Future<List<Product>> getRelativeProducts() => _memoizer.runOnce(() {
          return services.fetchProductsByCategory(
              categoryId: product.categoryId,
              lang: Provider.of<AppModel>(context).locale);
        });

    return LayoutBuilder(
      builder: (context, constraint) {
        return FutureBuilder<List<Product>>(
          future: getRelativeProducts(),
          builder:
              (BuildContext context, AsyncSnapshot<List<Product>> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
                return Container(
                  height: 100,
                  child: kLoadingWidget(context),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Container(
                    height: 100,
                    child: Center(
                      child: Text(
                        S.of(context).error(snapshot.error),
                        style: TextStyle(color: Theme.of(context).accentColor),
                      ),
                    ),
                  );
                } else if (snapshot.data.isEmpty) {
                  return Container();
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        child: Text(
                          S.of(context).youMightAlsoLike,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Container(
                          height: constraint.maxWidth * 0.7,
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: [
                              for (var item in snapshot.data)
                                if (item.id != product.id)
                                  ProductCard(
                                      item: item,
                                      width: constraint.maxWidth * 0.35)
                            ],
                          ))
                    ],
                  );
                }
            }
            return Container(); // unreachable
          },
        );
      },
    );
  }
}
