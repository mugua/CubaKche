import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/cart/cart_model.dart';
import '../../models/product/product.dart';
import '../../models/wishlist.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../detail/index.dart';

class WishList extends StatefulWidget {
  final bool canPop;

  WishList({this.canPop = true});

  @override
  State<StatefulWidget> createState() {
    return WishListState();
  }
}

class WishListState extends State<WishList>
    with SingleTickerProviderStateMixin {
  AnimationController _hideController;

  @override
  void initState() {
    super.initState();
    _hideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 450),
      value: 1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
            elevation: 0.5,
            leading: widget.canPop
                ? IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 22,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                : Container(),
            title: Text(
              S.of(context).myWishList,
              style: TextStyle(color: Theme.of(context).accentColor),
            ),
            backgroundColor: Theme.of(context).backgroundColor),
        body: ListenableProvider.value(
            value: Provider.of<WishListModel>(context, listen: false),
            child: Consumer<WishListModel>(builder: (context, model, child) {
              if (model.products.isEmpty) {
                return EmptyWishlist();
              } else {
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 15),
                        child: Text(
                            "${model.products.length} " + S.of(context).items,
                            style: TextStyle(fontSize: 14, color: kGrey400)),
                      ),
                      Divider(height: 1, color: kGrey200),
                      SizedBox(height: 15),
                      Expanded(
                        child: ListView.builder(
                            itemCount: model.products.length,
                            itemBuilder: (context, index) {
                              return WishlistItem(
                                  product: model.products[index],
                                  onRemove: () {
                                    Provider.of<WishListModel>(context,
                                            listen: false)
                                        .removeToWishlist(
                                            model.products[index]);
                                  },
                                  onAddToCart: () {
                                    Provider.of<CartModel>(context,
                                            listen: false)
                                        .addProductToCart(
                                            product: model.products[index],
                                            quantity: 1);
                                  });
                            }),
                      )
                    ]);
              }
            })),
      ),
      Align(
          child: ExpandingBottomSheet(hideController: _hideController),
          alignment: Alignment.bottomRight)
    ]);
  }
}

class EmptyWishlist extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: <Widget>[
          SizedBox(height: 80),
          Image.asset(
            'assets/images/empty_wishlist.png',
            width: 120,
            height: 120,
          ),
          SizedBox(height: 20),
          Text(S.of(context).noFavoritesYet,
              style: TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.center),
          SizedBox(height: 15),
          Text(S.of(context).emptyWishlistSubtitle,
              style: TextStyle(fontSize: 14, color: kGrey900),
              textAlign: TextAlign.center),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 45,
                  child: RaisedButton(
                      child: Text(S.of(context).startShopping.toUpperCase()),
                      color: Colors.black,
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.of(context).popAndPushNamed('/home');
                      }),
                ),
              )
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ButtonTheme(
                  height: 44,
                  child: RaisedButton(
                      child: Text(S.of(context).searchForItems.toUpperCase()),
                      color: kGrey200,
                      textColor: kGrey400,
                      onPressed: () {
                        Navigator.of(context).popAndPushNamed('/search');
                      }),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class WishlistItem extends StatelessWidget {
  WishlistItem({@required this.product, this.onAddToCart, this.onRemove});

  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final localTheme = Theme.of(context);
    final currency = Provider.of<CartModel>(context).currency;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) => Detail(product: product),
                    fullscreenDialog: true,
                  ));
            },
            child: Row(
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
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              width: constraints.maxWidth * 0.25,
                              height: constraints.maxWidth * 0.3,
                              child: Tools.image(
                                  url: product.imageFeature,
                                  size: kSize.medium),
                            ),
                            SizedBox(width: 16.0),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name ?? '',
                                    style: localTheme.textTheme.caption,
                                  ),
                                  SizedBox(height: 7),
                                  Text(Tools.getPriceProduct(product, currency),
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle1
                                          .copyWith(
                                              color: kGrey400, fontSize: 14)),
                                  SizedBox(height: 10),
                                  RaisedButton(
                                      textColor: Colors.white,
                                      color: localTheme.primaryColor,
                                      child: Text(S
                                          .of(context)
                                          .addToCart
                                          .toUpperCase()),
                                      onPressed: onAddToCart)
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.0),
          Divider(color: kGrey200, height: 1),
          SizedBox(height: 10.0),
        ]);
      },
    );
  }
}
