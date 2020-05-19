import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/config.dart';
import 'common/constants.dart';
import 'common/tools.dart';
import 'generated/l10n.dart';
import 'menu.dart';
import 'models/app.dart';
import 'models/cart/cart_model.dart';
import 'pages/index.dart';
import 'route.dart';
import 'screens/blogs/post_screen.dart';
import 'screens/cart/cart.dart';
import 'screens/categories/index.dart';
import 'screens/custom/static_site.dart';
import 'screens/custom/webview_screen.dart';
import 'screens/home/home.dart';
import 'screens/search/search.dart';
import 'screens/settings/wishlist.dart' as screen;
import 'screens/users/user.dart';
import 'widgets/blog/slider_list.dart';
import 'widgets/icons/feather.dart';
import 'widgets/layout/adaptive.dart';
import 'widgets/layout/layout_web.dart';

const int tabCount = 3;
const int turnsToRotateRight = 1;
const int turnsToRotateLeft = 3;

class MainTabControlDelegate {
  int index;
  Function(String nameTab) changeTab;
  Function(int index) tabAnimateTo;

  static MainTabControlDelegate _instance;
  static MainTabControlDelegate getInstance() {
    return _instance ??= MainTabControlDelegate._();
  }

  MainTabControlDelegate._();
}

class MainTabs extends StatefulWidget {
  MainTabs({Key key}) : super(key: key);

  @override
  MainTabsState createState() => MainTabsState();
}

class MainTabsState extends State<MainTabs>
    with SingleTickerProviderStateMixin, AfterLayoutMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final PageStorageBucket bucket = PageStorageBucket();

  final StreamController<String> _controllerRouteWeb =
      StreamController<String>.broadcast();

  final _auth = FirebaseAuth.instance;
  var tabData;
  Map saveIndexTab = Map();

  FirebaseUser loggedInUser;
  bool isAdmin = false;

  final List<Widget> _tabView = [];
  TabController tabController;

  @override
  void afterFirstLayout(BuildContext context) {
    loadTabBar(context);
  }

  Widget tabView(Map<String, dynamic> data) {
    switch (data['layout']) {
      case 'category':
        return CategoriesScreen(
            key: Key("category"), layout: data['categoryLayout']);
      case 'search':
        return SearchScreen(
          key: Key("search"),
        );
      case 'cart':
        return CartScreen();
      case 'profile':
        return UserScreen();
      case 'blog':
        return HorizontalSliderList(config: data);
      case 'wishlist':
        return screen.WishList(
          canPop: false,
        );
      case 'page':
        return WebViewScreen(title: data['title'], url: data['url']);
      case 'html':
        return StaticSite(data: data['data']);
      case 'static':
        return StaticPage(data: data['data']);
      case 'postScreen':
        return PostScreen(
          pageId: data['pageId'],
          pageTitle: data['pageTitle'],
          isLocatedInTabbar: true,
        );
      case 'dynamic':
      default:
        return HomeScreen();
    }
  }

  void changeTab(String nameTab) {
    if (kLayoutWeb) {
      _controllerRouteWeb.sink
          .add(nameTab.contains("/") ? nameTab : '/$nameTab');
    } else {
      tabController?.animateTo(saveIndexTab[nameTab] ?? 0);
    }
  }

  void loadTabBar(context) {
    tabData = Provider.of<AppModel>(context, listen: false).appConfig['TabBar']
        as List;

    setState(() {
      tabController = TabController(length: tabData.length, vsync: this);
    });

    if (MainTabControlDelegate.getInstance().index != null) {
      tabController.animateTo(MainTabControlDelegate.getInstance().index);
    } else {
      MainTabControlDelegate.getInstance().index = 0;
    }

    // Load the Design from FluxBuilder
    tabController.addListener(() {
      eventBus.fire(tabController.index + 2);
      MainTabControlDelegate.getInstance().index = tabController.index;
    });

    for (var i = 0; i < tabData.length; i++) {
      Map<String, dynamic> _dataOfTab = Map.from(tabData[i]);
      saveIndexTab[_dataOfTab['layout']] = i;

      setState(() {
        _tabView.add(tabView(_dataOfTab));
      });
    }
  }

  Future<void> getCurrentUser() async {
    try {
      //Provider.of<UserModel>(context).getUser();
      final user = await _auth.currentUser();
      if (user != null) {
        setState(() {
          loggedInUser = user;
        });
      }
    } catch (e) {
      printLog("[tabbar] getCurrentUser error ${e.toString()}");
    }
  }

  bool checkIsAdmin() {
    if (loggedInUser.email == adminEmail) {
      isAdmin = true;
    } else {
      isAdmin = false;
    }
    return isAdmin;
  }

  @override
  void initState() {
    if (!kIsWeb) {
      getCurrentUser();
    }
    MainTabControlDelegate.getInstance().changeTab = changeTab;
    MainTabControlDelegate.getInstance().tabAnimateTo = (int index) {
      tabController?.animateTo(index);
    };
    super.initState();
  }

  @override
  void dispose() {
    tabController?.dispose();
    _controllerRouteWeb?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printLog('[tabbar] ============== tabbar.dart DASHBOARD ==============');
    final isDesktop = isDisplayDesktop(context);
    Utils.setStatusBarWhiteForeground(false);
    kLayoutWeb = (kIsWeb && isDesktop);

    if (_tabView.isEmpty) {
      return Container(
        color: Colors.white,
        child: kLoadingWidget(context),
      );
    }

    return renderBody(context);
  }

  Widget renderBody(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    if (kLayoutWeb) {
      final isDesktop = isDisplayDesktop(context);

      return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          // For desktop layout we do not want to have SafeArea at the top and
          // bottom to display 100% height content on the accounts view.
          top: !isDesktop,
          bottom: !isDesktop,
          child: Theme(
              // This theme effectively removes the default visual touch
              // feedback for tapping a tab, which is replaced with a custom
              // animation.
              data: theme.copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
              child: LayoutWebCustom(
                menu: MenuBar(controllerRouteWeb: _controllerRouteWeb),
                content: StreamBuilder<String>(
                  initialData: RouteList.homeScreen,
                  stream: _controllerRouteWeb.stream,
                  builder: (context, snapshot) {
                    return Navigator(
                      key: Key(snapshot.data),
                      initialRoute: snapshot.data,
                      onGenerateRoute: (RouteSettings settings) {
                        return MaterialPageRoute(
                          builder: Routes.getRouteByName(settings.name),
                          settings: settings,
                          maintainState: false,
                          fullscreenDialog: true,
                        );
                      },
                    );
                  },
                ),
              )),
        ),
      );
    } else {
      final screenSize = MediaQuery.of(context).size;
      return Container(
        color: Theme.of(context).backgroundColor,
        child: Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          resizeToAvoidBottomPadding: false,
          key: _scaffoldKey,
          body: WillPopScope(
            onWillPop: () async {
              if (tabController.index != 0) {
                tabController.animateTo(0);
                return false;
              } else {
                return showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(S.of(context).areYouSure),
                        content: Text(S.of(context).doYouWantToExitApp),
                        actions: <Widget>[
                          FlatButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text(S.of(context).no),
                          ),
                          FlatButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: Text(S.of(context).yes),
                          ),
                        ],
                      ),
                    ) ??
                    false;
              }
            },
            child: TabBarView(
              controller: tabController,
              physics: NeverScrollableScrollPhysics(),
              children: _tabView,
            ),
          ),
          drawer: Drawer(child: MenuBar()),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              width: screenSize.width,
              child: FittedBox(
                child: Container(
                  width: screenSize.width /
                      (2 / (screenSize.height / screenSize.width)),
                  child: TabBar(
                    controller: tabController,
                    tabs: renderTabbar(),
                    isScrollable: false,
                    labelColor: Theme.of(context).primaryColor,
                    indicatorSize: TabBarIndicatorSize.label,
                    indicatorPadding: EdgeInsets.all(4.0),
                    indicatorColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  List<Widget> renderTabbar() {
    final isTablet = Tools.isTablet(MediaQuery.of(context));
    var totalCart = Provider.of<CartModel>(context).totalCartQuantity;
    final tabData = Provider.of<AppModel>(context, listen: false)
        .appConfig['TabBar'] as List;

    List<Widget> list = [];

    tabData.forEach((item) {
      var icon = !item["icon"].contains('/')
          ? Icon(
              featherIcons[item["icon"]],
              color: Theme.of(context).accentColor,
              size: 22,
            )
          : (item["icon"].contains('http')
              ? Image.network(
                  item["icon"],
                  color: Theme.of(context).accentColor,
                  width: 24,
                )
              : Image.asset(
                  item["icon"],
                  color: Theme.of(context).accentColor,
                  width: 24,
                ));

      if (item["layout"] == "cart") {
        icon = Stack(
          children: <Widget>[
            Container(
              width: 35,
              padding: const EdgeInsets.all(6.0),
              child: icon,
            ),
            if (totalCart > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    totalCart.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isTablet ? 14 : 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
          ],
        );
      }

      if (item["label"] != null) {
        list.add(Tab(icon: icon, text: item["label"]));
      } else {
        list.add(Tab(icon: icon));
      }
    });

    return list;
  }
}
