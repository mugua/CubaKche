import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/product/product.dart';
import '../../models/product/product_model.dart';
import '../../models/product/product_variation.dart';
import '../../widgets/common/image_galery.dart';

class VariantImageFeature extends StatelessWidget {
  final Product product;

  VariantImageFeature(this.product);

  @override
  Widget build(BuildContext context) {
    ProductVariation productVariation;
    productVariation = Provider.of<ProductModel>(context).productVariation;
    final imageFeature = productVariation != null ? productVariation.imageFeature : product.imageFeature;

    _onShowGallery(context, [index = 0]) {
      Navigator.push(
        context,
        PageRouteBuilder(pageBuilder: (context, __, ___) {
          return ImageGalery(images: product.images, index: index);
        }),
      );
    }

    print('product.type ${product.type}');

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return FlexibleSpaceBar(
          background: GestureDetector(
            onTap: () => _onShowGallery(context),
            child: Container(
              child: Stack(
                children: <Widget>[
                  kProductDetail['isHero']
                      ? Positioned(
                          top: double.parse(kProductDetail['marginTop'].toString()),
                          child: Hero(
                            tag: 'product-${product.id}',
                            child: Tools.image(
                              url: imageFeature,
                              fit: BoxFit.contain,
                              isResize: true,
                              size: kSize.medium,
                              width: constraints.maxWidth,
                              hidePlaceHolder: true,
                            ),
                          ),
                        )
                      : Positioned(
                          top: double.parse(kProductDetail['marginTop'].toString()),
                          child: Tools.image(
                            url: imageFeature,
                            fit: BoxFit.contain,
                            isResize: true,
                            size: kSize.medium,
                            width: constraints.maxWidth,
                            hidePlaceHolder: true,
                          ),
                        ),
                  Positioned(
                    top: double.parse(kProductDetail['marginTop'].toString()),
                    child: Tools.image(
                      url: imageFeature,
                      fit: BoxFit.contain,
                      width: constraints.maxWidth,
                      size: kSize.large,
                      hidePlaceHolder: true,
                    ),
                  ),
                  if (productVariation == null)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        width: 100,
                        height: 20.0,
                        margin: EdgeInsets.only(bottom: 10),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              width: 120,
                              height: 24.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20.0),
                                child: LinearProgressIndicator(
                                  backgroundColor: Colors.black45,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                                child: Text(
                              S.of(context).loading,
                              style: TextStyle(color: Colors.white, fontSize: 12.0),
                            )),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
