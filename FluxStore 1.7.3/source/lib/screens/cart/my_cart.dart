import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/cart/cart_model.dart';
import '../../models/product/product.dart';
import '../../models/user/user_model.dart';
import '../../services/index.dart';
import '../../tabbar.dart';
import '../../widgets/product/cart_item.dart';
import '../../widgets/product/product_bottom_sheet.dart';
import '../users/login.dart';
import 'cart_sumary.dart';
import 'empty_cart.dart';
import 'wishlist.dart';

class MyCart extends StatefulWidget {
  final PageController controller;
  final bool isModal;
  final bool isBuyNow;

  MyCart({this.controller, this.isModal, this.isBuyNow = false});

  @override
  _MyCartState createState() => _MyCartState();
}

class _MyCartState extends State<MyCart> with SingleTickerProviderStateMixin {
  bool isLoading = false;
  String errMsg = '';

  List<Widget> _createShoppingCartRows(CartModel model, BuildContext context) {
    return model.productsInCart.keys.map(
      (key) {
        String productId = Product.cleanProductID(key);
        Product product = model.getProductById(productId);

        return ShoppingCartRow(
          product: product,
          variation: model.getProductVariationById(key),
          quantity: model.productsInCart[key],
          onRemove: () {
            model.removeItemFromCart(key);
          },
          onChangeQuantity: (val) {
            String message = Provider.of<CartModel>(context, listen: false)
                .updateQuantity(product, key, val);
            if (message.isNotEmpty) {
              final snackBar = SnackBar(
                content: Text(message),
                duration: Duration(seconds: 1),
              );
              Future.delayed(Duration(milliseconds: 300),
                  () => Scaffold.of(context).showSnackBar(snackBar));
            }
          },
        );
      },
    ).toList();
  }

  _loginWithResult(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginScreen(
          fromCart: true,
        ),
        fullscreenDialog: kLayoutWeb,
      ),
    );

    if (result != null && result.name != null) {
      Scaffold.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(S.of(context).welcome + " ${result.name} !"),
        ));
    }
  }

  @override
  Widget build(BuildContext context) {
    printLog("[Cart] build");

    final localTheme = Theme.of(context);
    bool isLoggedIn = Provider.of<UserModel>(context).loggedIn;
    final screenSize = MediaQuery.of(context).size;
    var productDetail =
        Provider.of<AppModel>(context).appConfig['Setting']['ProductDetail'];
    var layoutType =
        productDetail ?? (kProductDetail['layout'] ?? 'simpleType');

    return SafeArea(
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).backgroundColor,
          leading: widget.isModal == true
              ? IconButton(
                  onPressed: () {
                    if (widget.isBuyNow) {
                      Navigator.of(context).pop();
                    }
                    if (layoutType == 'simpleType') {
                      ExpandingBottomSheet.of(context).close();
                    } else if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Icon(
                    Icons.close,
                    size: 22,
                  ),
                )
              : Container(),
          title: Text(
            S.of(context).myCart,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
        ),
        body: Consumer<CartModel>(
          builder: (context, model, child) {
            return Container(
              decoration:
                  BoxDecoration(color: Theme.of(context).backgroundColor),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (model.totalCartQuantity > 0)
                      Container(
                        margin: EdgeInsets.only(top: 10.0),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 15.0, top: 4.0),
                          child: Container(
                            width: screenSize.width,
                            child: Container(
                              width: screenSize.width /
                                  (2 / (screenSize.height / screenSize.width)),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 25.0,
                                  ),
                                  Text(
                                    S.of(context).total.toUpperCase(),
                                    style: localTheme.textTheme.subtitle1
                                        .copyWith(
                                            fontWeight: FontWeight.w600,
                                            color:
                                                Theme.of(context).primaryColor,
                                            fontSize: 14),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Text(
                                    '${model.totalCartQuantity} ${S.of(context).items}',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: RaisedButton(
                                        child: Text(
                                          S.of(context).clearCart.toUpperCase(),
                                          style: TextStyle(
                                              color: Colors.redAccent,
                                              fontSize: 12),
                                        ),
                                        onPressed: () {
                                          if (model.totalCartQuantity > 0) {
                                            model.clearCart();
                                          }
                                        },
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        textColor: Colors.white,
                                        elevation: 0.1,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (model.totalCartQuantity > 0)
                      Divider(
                        height: 1,
                        indent: 25,
                      ),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(height: 16.0),
                          if (model.totalCartQuantity > 0)
                            Column(
                              children: _createShoppingCartRows(model, context),
                            ),
                          if (model.totalCartQuantity > 0)
                            ShoppingCartSummary(model: model),
                          if (model.totalCartQuantity == 0) EmptyCart(),
                          if (errMsg.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 10),
                              child: Text(
                                errMsg,
                                style: TextStyle(color: Colors.red),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          Container(
                            width: screenSize.width,
                            child: Container(
                              width: screenSize.width /
                                  (2 / (screenSize.height / screenSize.width)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: ButtonTheme(
                                        height: 45,
                                        child: RaisedButton(
                                          child: model.totalCartQuantity > 0
                                              ? (isLoading
                                                  ? Text(S
                                                      .of(context)
                                                      .loading
                                                      .toUpperCase())
                                                  : Text(S
                                                      .of(context)
                                                      .checkout
                                                      .toUpperCase()))
                                              : Text(
                                                  S
                                                      .of(context)
                                                      .startShopping
                                                      .toUpperCase(),
                                                ),
                                          color: Theme.of(context).primaryColor,
                                          textColor: Colors.white,
                                          elevation: 0.1,
                                          onPressed: () =>
                                              onCheckout(model, isLoggedIn),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 4.0,
                          ),
                          WishList()
                        ])
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void onCheckout(model, isLoggedIn) {
    if (isLoading) return;

    if (model.totalCartQuantity == 0) {
      widget.isModal == true
          ? ExpandingBottomSheet.of(context).close()
          : MainTabControlDelegate.getInstance().tabAnimateTo(0);
    } else if (isLoggedIn || kPaymentConfig['GuestCheckout'] == true) {
      doCheckout();
    } else {
      _loginWithResult(context);
    }
  }

  Future<void> doCheckout() async {
    showLoading();

    await Services().widget.doCheckout(
      context,
      success: () async {
        hideLoading('');
        await widget.controller.animateToPage(1,
            duration: Duration(milliseconds: 250), curve: Curves.easeInOut);
      },
      error: (message) {
        hideLoading(message);
        Future.delayed(Duration(seconds: 3), () {
          setState(() => errMsg = '');
        });
      },
    );
  }

  void showLoading() {
    setState(() {
      isLoading = true;
      errMsg = '';
    });
  }

  void hideLoading(error) {
    setState(() {
      isLoading = false;
      errMsg = error;
    });
  }
}
