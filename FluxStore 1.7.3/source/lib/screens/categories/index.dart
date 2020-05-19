import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/constants.dart';
import '../../generated/l10n.dart';
import '../../models/category/category_model.dart';
import '../../widgets/cardlist/index.dart';
import 'card.dart';
import 'column.dart';
import 'grid_category.dart';
import 'side_menu.dart';
import 'sub.dart';

class CategoriesScreen extends StatefulWidget {
  final String layout;
  CategoriesScreen({Key key, this.layout}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CategoriesScreenState();
  }
}

class CategoriesScreenState extends State<CategoriesScreen>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  @override
  bool get wantKeepAlive => true;

  FocusNode _focus;
  bool isVisibleSearch = false;
  String searchText;
  var textController = TextEditingController();

  Animation<double> animation;
  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    animation = Tween<double>(begin: 0, end: 60).animate(controller);
    animation.addListener(() {
      setState(() {});
    });

    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus.hasFocus && animation.value == 0) {
      controller.forward();
      setState(() {
        isVisibleSearch = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final category = Provider.of<CategoryModel>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: ListenableProvider.value(
        value: category,
        child: Consumer<CategoryModel>(
          builder: (context, value, child) {
            if (value.isLoading) {
              return kLoadingWidget(context);
            }

            if (value.categories == null) {
              return Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                child: Text(S.of(context).dataEmpty),
              );
            }
            return SafeArea(
              child: ['grid', 'column', 'sideMenu', 'subCategories']
                      .contains(widget.layout)
                  ? Column(
                      children: <Widget>[
                        Container(
                          width: screenSize.width,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Container(
                              width: screenSize.width /
                                  (2 / (screenSize.height / screenSize.width)),
                              child: Padding(
                                child: Text(
                                  S.of(context).category,
                                  style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold),
                                ),
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, bottom: 20, right: 10),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: renderCategories(value),
                        )
                      ],
                    )
                  : ListView(
                      children: <Widget>[
                        Container(
                          width: screenSize.width,
                          child: FittedBox(
                            fit: BoxFit.cover,
                            child: Container(
                              width: screenSize.width /
                                  (2 / (screenSize.height / screenSize.width)),
                              child: Padding(
                                child: Text(
                                  S.of(context).category,
                                  style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold),
                                ),
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, bottom: 20, right: 10),
                              ),
                            ),
                          ),
                        ),
                        renderCategories(value)
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget renderCategories(value) {
    switch (widget.layout) {
      case 'card':
        return CardCategories(value.categories);
      case 'column':
        return ColumnCategories(value.categories);
      case 'subCategories':
        return SubCategories(value.categories);
      case 'sideMenu':
        return SideMenuCategories(value.categories);
      case 'animation':
        return HorizonMenu();
      case 'grid':
        return GridCategory();
      default:
        return HorizonMenu();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
