import 'dart:collection';

import 'package:flutter/material.dart';
import '../variant_image_feature.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../common/constants.dart';
import '../../../common/tools.dart';
import '../../../models/advertisement.dart';
import '../../../models/app.dart';

import '../../../screens/detail/product_grouped.dart';
import '../../../widgets/product/heart_button.dart';
import '../../../widgets/product/product_bottom_sheet.dart';
import '../../custom/smartchat.dart';
import '../image_feature.dart';
import '../index.dart';
import '../product_booking.dart';
import '../product_description.dart';
import '../product_galery.dart';
import '../product_title.dart';
import '../product_variant.dart';
import '../related_product.dart';
import '../../../models/product/product.dart';
import '../../../models/user/user_model.dart';
import '../../../models/product/product_model.dart';

class SimpleLayout extends StatefulWidget {
  final Product product;

  SimpleLayout({this.product});

  @override
  _SimpleLayoutState createState() => _SimpleLayoutState(product: product);
}

class _SimpleLayoutState extends State<SimpleLayout>
    with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  Product product;

  _SimpleLayoutState({this.product});

  Map<String, String> mapAttribute = HashMap();
  AnimationController _hideController;

  var top = 0.0;

  @override
  void initState() {
    super.initState();

    if (kAdConfig['enable']) Ads().adInit();

    _hideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    if (kAdConfig['enable']) {
      Ads.hideBanner();
      Ads.hideInterstitialAd();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final widthHeight = MediaQuery.of(context).size.height;
    final user = Provider.of<UserModel>(context).user;
    //special advertisement type
    bool isGoogleBannerShown = kAdConfig['type'] == kAdType.googleBanner;

    final isTablet = Tools.isTablet(MediaQuery.of(context));
    kLayoutWeb = kIsWeb || isTablet;

    print('product.type ${product.type}');
    return Container(
      color: Theme.of(context).backgroundColor,
      child: SafeArea(
        bottom: false,
        top: kProductDetail["safeArea"] ?? false,
        child: ChangeNotifierProvider(
          create: (_) => ProductModel(),
          child: Stack(
            children: <Widget>[
              Scaffold(
                floatingActionButton: kConfigChat['EnableSmartChat']
                    ? SmartChat(
                        user: user,
                        margin: EdgeInsets.only(
                          bottom: kAdConfig['enable'] ? 100 : 50,
                          right: Provider.of<AppModel>(context).locale == 'ar'
                              ? 30
                              : 0.0,
                        ),
                      )
                    : Container(),
                backgroundColor: Theme.of(context).backgroundColor,
                body: CustomScrollView(
                  controller: _scrollController,
                  slivers: <Widget>[
                    SliverAppBar(
                      backgroundColor: Theme.of(context).backgroundColor,
                      elevation: 1.0,
                      expandedHeight: kLayoutWeb
                          ? 0
                          : widthHeight * kProductDetail['height'],
                      pinned: true,
                      floating: false,
                      leading: Padding(
                        padding: const EdgeInsets.all(8),
                        child: CircleAvatar(
                          backgroundColor: Colors.white.withOpacity(0.3),
                          child: IconButton(
                            icon: Icon(
                              Icons.close,
                              color: kGrey400,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      actions: <Widget>[
                        HeartButton(
                          product: product,
                          size: 18.0,
                          color: kGrey400,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: IconButton(
                              icon: const Icon(Icons.more_vert, size: 19),
                              color: kGrey400,
                              onPressed: () =>
                                  Detail.showMenu(context, widget.product),
                            ),
                          ),
                        ),
                      ],
                      flexibleSpace: kLayoutWeb
                          ? Container()
                          : product.type == 'variable'
                              ? VariantImageFeature(product)
                              : ImageFeature(product),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate(
                        <Widget>[
                          SizedBox(
                            height: 8,
                          ),
                          ProductGalery(product),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15.0, vertical: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                product.type == 'grouped'
                                    ? Container()
                                    : ProductTitle(product),
                                product.type != 'booking'
                                    ? product.type != 'grouped'
                                        ? ProductVariant(product)
                                        : GroupedProduct(product)
                                    : ProductBooking(product),
                                ProductDescription(product),
                                RelatedProduct(product),
                              ],
                            ),
                          ),
                          SizedBox(height: 100),
//                          isFBNativeAdShown
//                              ? Ads().facebookNative()
//                              : Container(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: isGoogleBannerShown
                    ? Positioned(
                        child: ExpandingBottomSheet(
                            hideController: _hideController,
                            onInitController: (controller) {}),
                        bottom: 50,
                        right: 0,
                      )
                    : Align(
                        child: ExpandingBottomSheet(
                            hideController: _hideController,
                            onInitController: (controller) {}),
                        alignment: Alignment.bottomRight),
              ),
              if (kAdConfig['enable'])
                Container(
                  alignment: Alignment.bottomCenter,
                  child: Ads().facebookBanner(),
                )
            ],
          ),
        ),
      ),
    );
  }
}
