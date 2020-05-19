import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/constants.dart';
import '../generated/l10n.dart';
import '../models/cart/cart_model.dart';
import '../models/user/user_model.dart';
import '../screens/cart/cart.dart';
import '../screens/categories/index.dart';
import '../screens/home/home.dart';
import '../screens/users/user.dart';
import '../widgets/common/cuberto_bottom_bar.dart';

class MainTabs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainTabsState();
  }
}

class MainTabsState extends State<MainTabs> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int pageIndex = 0;
  int currentPage = 0;
  String currentTitle = "Home";
  Color currentColor = Colors.deepPurple;

  @override
  Widget build(BuildContext context) {
    var totalCart = Provider.of<CartModel>(context).totalCartQuantity;
    bool loggedIn = Provider.of<UserModel>(context).loggedIn;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
      body: _showScreensByIndex(pageIndex),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: Row(
                children: <Widget>[
                  Image.asset(kLogoImage, height: 38),
                ],
              ),
              decoration: BoxDecoration(
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0),
              child: Column(
                children: <Widget>[
                  ListTile(
                    leading: Icon(Icons.shopping_basket, size: 20),
                    title: Text(S.of(context).shop),
                    onTap: () {
                      Navigator.pushReplacementNamed(context, "/home");
                    },
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.wordpress, size: 20),
                    title: Text(S.of(context).blog),
                    onTap: () {
                      Navigator.pushNamed(context, "/blogs");
                    },
                  ),
                  ListTile(
                    leading: Icon(FontAwesomeIcons.heart, size: 20),
                    title: Text(S.of(context).myWishList),
                    onTap: () {
                      Navigator.pushNamed(context, "/wishlist");
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.exit_to_app, size: 20),
                    title: loggedIn
                        ? Text(S.of(context).logout)
                        : Text(S.of(context).login),
                    onTap: () {
                      loggedIn
                          ? Provider.of<UserModel>(context, listen: false)
                              .logout()
                          : Navigator.pushNamed(context, "/login");
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: CubertoBottomBar(
        inactiveIconColor: Theme.of(context).accentColor,
        initialSelection: 0,
        drawer: CubertoDrawer.NO_DRAWER,
        tabs: [
          TabData(
              iconData: "assets/icons/tabs/icon-home.png",
              title: S.of(context).shop,
              tabColor: Color(0xFF0066B4)),
          TabData(
              iconData: "assets/icons/tabs/icon-search.png",
              title: S.of(context).search,
              tabColor: Color(0xFF0095C9)),
          TabData(
              iconData: "assets/icons/tabs/icon-cart2.png",
              title: S.of(context).cart,
              tabColor: Color(0xFF0091D1),
              badge: totalCart),
          TabData(
              iconData: "assets/icons/tabs/icon-user.png",
              title: S.of(context).settings,
              tabColor: Color(0xFF00C1F2)),
        ],
        onTabChangedListener: (position, title, color) {
          setState(() {
            pageIndex = position;
            currentTitle = title;
            currentColor = color;
          });
        },
      ),
    );
  }

  Widget _showScreensByIndex(index) {
    switch (index) {
      case 0:
        return HomeScreen();
      case 1:
        return CategoriesScreen();
      case 2:
        return CartScreen();
      case 3:
        return UserScreen();
        break;
      default:
    }
    return null;
  }
}
