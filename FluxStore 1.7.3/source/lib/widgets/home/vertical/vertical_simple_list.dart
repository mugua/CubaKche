import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/tools.dart';
import '../../../models/product/product.dart';
import '../../../models/app.dart';
import '../../../screens/detail/index.dart';

enum SimpleListType { BackgroundColor, PriceOnTheRight }

class SimpleListView extends StatelessWidget {
  final Product item;
  final SimpleListType type;

  SimpleListView({this.item, this.type});

  @override
  Widget build(BuildContext context) {
    final currency = Provider.of<AppModel>(context).currency;
    var screenWidth = MediaQuery.of(context).size.width;
    double titleFontSize = 15;
    double imageWidth = 60;
    double imageHeight = 60;
    void onTapProduct() {
      if (item.imageFeature == '') return;
      Navigator.push(
          context,
          MaterialPageRoute<void>(
            builder: (BuildContext context) => Detail(product: item),
            fullscreenDialog: true,
          ));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      child: GestureDetector(
        onTap: onTapProduct,
        child: Container(
          width: screenWidth,
          decoration: BoxDecoration(
            color: type == SimpleListType.BackgroundColor
                ? Theme.of(context).primaryColorLight
                : null,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Tools.image(
                    url: item.imageFeature,
                    width: imageWidth,
                    size: kSize.medium,
                    isResize: true,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      (type != SimpleListType.PriceOnTheRight)
                          ? Text(
                              Tools.getPriceProduct(item, currency),
                              style: TextStyle(
                                  color: Theme.of(context).accentColor),
                            )
                          : Container(),
                    ],
                  ),
                ),
                (type == SimpleListType.PriceOnTheRight)
                    ? Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          Tools.getPriceProduct(item, currency),
                          style:
                              TextStyle(color: Theme.of(context).accentColor),
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
