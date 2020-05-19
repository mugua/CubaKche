import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'generated/l10n.dart';
import 'models/category/category.dart';
import 'models/category/category_model.dart';
import 'models/product/product.dart';
import 'models/user/user_model.dart';

class MenuBar extends StatefulWidget {
  final GlobalKey<NavigatorState> navigation;
  final StreamController<String> controllerRouteWeb;

  MenuBar({this.navigation, this.controllerRouteWeb});

  @override
  _MenuBarState createState() => _MenuBarState();
}

class _MenuBarState extends State<MenuBar> {
  @override
  Widget build(BuildContext context) {
    printLog("[MenuBar] build");
    bool loggedIn = Provider.of<UserModel>(context).loggedIn;

    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          DrawerHeader(
            child: Row(
              children: <Widget>[
                Image.asset(kLogoImage, height: 38),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(
                    Icons.shopping_basket,
                    size: 20,
                  ),
                  title: Text(S.of(context).shop),
                  onTap: () {
                    if (kLayoutWeb) {
                      widget.controllerRouteWeb.sink.add("/home-screen");
                    } else {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.of(context)
                            .pushReplacementNamed("/home-screen");
                      }
                    }
                  },
                ),
                if (kLayoutWeb)
                  ListTile(
                    leading: const Icon(
                      Icons.list,
                      size: 20,
                    ),
                    title: Text(S.of(context).category),
                    onTap: () {
                      widget.controllerRouteWeb.sink.add("/category");
                    },
                  ),
                if (kLayoutWeb)
                  ListTile(
                    leading: const Icon(
                      Icons.search,
                      size: 20,
                    ),
                    title: Text(S.of(context).search),
                    onTap: () {
                      widget.controllerRouteWeb.sink.add("/search");
                    },
                  ),
                ListTile(
                  leading: const Icon(FontAwesomeIcons.wordpress, size: 20),
                  title: Text(S.of(context).blog),
                  onTap: () {
                    if (kLayoutWeb) {
                      widget.controllerRouteWeb.sink.add("/blogs");
                    } else {
                      Navigator.of(context).pushNamed("/blogs");
                    }
                  },
                ),
                if (kLayoutWeb)
                  ListTile(
                    leading: const Icon(Icons.settings, size: 20),
                    title: Text(S.of(context).settings),
                    onTap: () {
                      if (kLayoutWeb) {
                        widget.controllerRouteWeb.sink.add("/setting");
                      } else {
                        Navigator.of(context).pushNamed("/setting");
                      }
                    },
                  ),
                ListTile(
                  leading: Icon(Icons.exit_to_app, size: 20),
                  title: loggedIn
                      ? Text(S.of(context).logout)
                      : Text(S.of(context).login),
                  onTap: () {
                    if (loggedIn) {
                      Provider.of<UserModel>(context, listen: false).logout();
                    } else {
                      if (kLayoutWeb) {
                        widget.controllerRouteWeb.sink.add("/login");
                      } else {
                        Navigator.pushNamed(context, "/login");
                      }
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(
                    S.of(context).byCategory.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).accentColor.withOpacity(0.5),
                    ),
                  ),
                  children: showCategories(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  List showCategories() {
    final categories = Provider.of<CategoryModel>(context).categories;
    List<Widget> widgets = [];

    if (categories != null) {
      var list = categories.where((item) => item.parent == '0').toList();
      for (var index in list) {
        widgets.add(
          ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.only(left: 0.0, top: 0),
              child: Text(
                index.name.toUpperCase(),
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
            ),
            children: getChildren(categories, index),
          ),
        );
      }
    }
    return widgets;
  }

  List getChildren(List<Category> categories, Category category) {
    List<Widget> list = [];
    var children = categories.where((o) => o.parent == category.id).toList();

    if (children.isEmpty) {
      list.add(
        ListTile(
          leading: Padding(
            child: Text(category.name),
            padding: const EdgeInsets.only(left: 20),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
          onTap: () {
            Product.showList(
                context: context, cateId: category.id, cateName: category.name);
          },
        ),
      );
    }
    for (var i in children) {
      list.add(
        ListTile(
          leading: Padding(
            child: Text(i.name),
            padding: const EdgeInsets.only(left: 20),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 12,
          ),
          onTap: () {
            Product.showList(context: context, cateId: i.id, cateName: i.name);
          },
        ),
      );
    }
    return list;
  }
}
