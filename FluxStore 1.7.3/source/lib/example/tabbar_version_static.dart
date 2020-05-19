import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/constants.dart';
import '../generated/l10n.dart';
import '../models/user/user_model.dart';
import '../screens/cart/cart.dart';
import '../screens/categories/index.dart';
import '../screens/home/home.dart';
import '../screens/users/user.dart';

class MainTabs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MainTabsState();
  }
}

class MainTabsState extends State<MainTabs> {
  final _homeScreen = HomeScreen();
  final _categoriesScreen = CategoriesScreen();
  final _cartScreen = CartScreen();
  final _userScreen = UserScreen();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int pageIndex = 4;

  void _onChangePageIndex(index) {
    setState(() {
      pageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool loggedIn = Provider.of<UserModel>(context).loggedIn;

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      key: _scaffoldKey,
//      appBar: AppBar(
//        elevation: 0,
//        backgroundColor: Colors.white,
//        title: Container(
//          height: 30,
//          child: Image.asset('assets/images/logo.png'),
//        ),
//        leading: IconButton(
//          icon: Icon(Icons.menu),
//          onPressed: () {
//            _scaffoldKey.currentState.openDrawer();
//          },
//        ),
//      ),

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
      bottomNavigationBar: BottomNavigationBar(
        elevation: 3.0,
        items: [
          BottomNavigationBarItem(
              icon: Image.asset(
                "assets/icons/tabs/icon-home.png",
                fit: BoxFit.contain,
                width: 26,
                height: 26,
                color: pageIndex == 0
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).hintColor,
              ),
              title: Container(height: 0.0)),
          BottomNavigationBarItem(
              icon: Image.asset("assets/icons/tabs/icon-search.png",
                  fit: BoxFit.contain,
                  width: 26,
                  height: 26,
                  color: pageIndex == 1
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).hintColor),
              title: Container(height: 0.0)),
          BottomNavigationBarItem(
              icon: Image.asset("assets/icons/tabs/icon-cart2.png",
                  fit: BoxFit.contain,
                  width: 26,
                  height: 26,
                  color: pageIndex == 2
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).hintColor),
              title: Container(height: 0.0)),
          BottomNavigationBarItem(
            icon: Image.asset("assets/icons/tabs/icon-user.png",
                fit: BoxFit.contain,
                width: 26,
                height: 26,
                color: pageIndex == 3
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).hintColor),
            title: Container(height: 0.0),
          ),
        ],
        onTap: _onChangePageIndex,
        currentIndex: pageIndex,
        fixedColor: Theme.of(context).primaryColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _showScreensByIndex(index) {
    switch (index) {
      case 0:
        return _homeScreen;
      case 1:
        return _categoriesScreen;
      case 2:
        return _cartScreen;
      case 3:
        return _userScreen;
        break;
      default:
    }
    return null;
  }
}
