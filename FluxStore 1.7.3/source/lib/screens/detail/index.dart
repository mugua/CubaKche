import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/product/product.dart';
import '../../models/wishlist.dart';
import '../../widgets/common/image_galery.dart';
import 'themes/full_size_image_type.dart';
import 'themes/half_size_image_type.dart';
import 'themes/simple_type.dart';

class Detail extends StatelessWidget {
  final Product product;

  static showMenu(context, product) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                  title:
                      Text(S.of(context).myCart, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  title: Text(S.of(context).showGallery,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    showDialog<void>(
                        context: context,
                        builder: (BuildContext context) {
                          return ImageGalery(images: product.images, index: 0);
                        });
                  }),
              ListTile(
                  title: Text(S.of(context).saveToWishList,
                      textAlign: TextAlign.center),
                  onTap: () {
                    Provider.of<WishListModel>(context, listen: false)
                        .addToWishlist(product);
                    Navigator.of(context).pop();
                  }),
              ListTile(
                  title: Text(S.of(context).share, textAlign: TextAlign.center),
                  onTap: () {
                    Navigator.of(context).pop();
                    Share.share(product.permalink);
                  }),
              Container(
                height: 1,
                decoration: BoxDecoration(color: kGrey200),
              ),
              ListTile(
                title: Text(
                  S.of(context).cancel,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );
        });
  }

  Detail({this.product});

  @override
  Widget build(BuildContext context) {
    var productDetail =
        Provider.of<AppModel>(context).appConfig['Setting']['ProductDetail'];
    var layoutType =
        productDetail ?? (kProductDetail['layout'] ?? 'simpleType');
    Widget layout;
    switch (layoutType) {
      case 'halfSizeImageType':
        layout = HalfSizeLayout(product: product);
        break;
      case 'fullSizeImageType':
        layout = FullSizeLayout(product: product);
        break;
      default:
        layout = SimpleLayout(product: product);
        break;
    }
    return layout;
    //   return Row(
    //     children: <Widget>[
    //       kLayoutWeb ? Container(
    //         width: 250, //  (cappedTextScale(context) - 1)
    //         alignment: Alignment.topCenter,
    //         padding: const EdgeInsets.only(bottom: 32),
    //         child: MenuBar(),
    //       ) : SizedBox(),
    //       Expanded(
    //         child: layout,
    //       )
    //     ]
    //   );
  }
}
