import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../generated/l10n.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/app.dart';
import '../../models/search.dart';
import 'widgets/filters/filter_search.dart';
import 'widgets/product_list.dart';
import 'widgets/recent/recent_search.dart';
import 'widgets/search_box.dart';

class SearchScreen extends StatefulWidget {
  final isModal;

  SearchScreen({Key key, this.isModal}) : super(key: key);

  @override
  _StateSearchScreen createState() => _StateSearchScreen();
}

class _StateSearchScreen extends State<SearchScreen>
    with AutomaticKeepAliveClientMixin<SearchScreen> {
  @override
  bool get wantKeepAlive => true;
  FocusNode _focus;
  bool isVisibleSearch = false;
  String _searchText;

  void _onFocusChange() {
    setState(() {
      isVisibleSearch = _focus.hasFocus;
    });
  }

  PreferredSizeWidget _renderAppbar(Size screenSize) {
    if (widget.isModal != null) {
      return AppBar(
        backgroundColor: Theme.of(context).backgroundColor,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios,
            size: 22,
          ),
        ),
        title: Container(
          width: screenSize.width,
          child: Container(
            width:
                screenSize.width / (2 / (screenSize.height / screenSize.width)),
            child: Text(
              S.of(context).search,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
    return null;
  }

  Widget _renderHeader(Size screenSize) {
    Widget _headerContent = SizedBox(height: 10.0);
    if (widget.isModal == null) {
      _headerContent = AnimatedContainer(
        height: isVisibleSearch ? 0.1 : 58,
        padding: const EdgeInsets.only(
          left: 12,
          top: 5,
          bottom: 5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Text(
              S.of(context).search,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        duration: Duration(milliseconds: 250),
      );
    }

    return Container(
      width: screenSize.width,
      child: Container(
        width: screenSize.width / (2 / (screenSize.height / screenSize.width)),
        child: _headerContent,
      ),
    );
  }

  Widget _renderSearchLayout() {
    final screenSize = MediaQuery.of(context).size;

    return ListenableProvider.value(
      value: Provider.of<SearchModel>(context),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        if (_searchText == null || _searchText.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              top: 15,
            ),
            child: RecentSearches(
              onTap: (text) {
                setState(() {
                  _searchText = text;
                });
                FocusScope.of(context)
                    .requestFocus(FocusNode()); //dismiss keyboard
                Provider.of<SearchModel>(context, listen: false).searchProducts(
                  name: text,
                  page: 1,
                  lang: Provider.of<AppModel>(context, listen: false).locale,
                );
              },
            ),
          );
        }

        if (model.loading) {
          return kLoadingWidget(context);
        }

        return Column(
          children: <Widget>[
            Container(
              width: screenSize.width /
                  (2 / (screenSize.height / screenSize.width)),
              height: 45,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Text(
                    S.of(context).weFoundProducts(
                          model.products.length.toString(),
                        ),
                    style: TextStyle(
                      color: Theme.of(context).accentColor,
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration:
                    BoxDecoration(color: Theme.of(context).backgroundColor),
                child: ProductList(
                  name: _searchText,
                  products: model.products,
                ),
              ),
            )
          ],
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchText = '';
    _focus = FocusNode();
    _focus.addListener(_onFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenSize = MediaQuery.of(context).size;
    double widthSearchBox =
        screenSize.width / (2 / (screenSize.height / screenSize.width));

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: _renderAppbar(screenSize),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => Utils.hideKeyboard(context),
          child: Column(
            children: <Widget>[
              _renderHeader(screenSize),
              SearchBox(
                width: widthSearchBox,
                focusNode: _focus,
                onCancel: () {
                  setState(() {
                    _searchText = "";
                    isVisibleSearch = false;
                  });
                },
                onChange: (result) {
                  setState(() {
                    _searchText = result;
                  });
                  Provider.of<SearchModel>(context, listen: false)
                      .searchProducts(
                    name: result,
                    page: 1,
                    lang: Provider.of<AppModel>(context, listen: false).locale,
                  );
                },
              ),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: SearchFilter(
                    onChange: (searchFilter) {
                      Provider.of<SearchModel>(
                        context,
                        listen: false,
                      ).searchByFilter(
                        searchFilter,
                        _searchText,
                        Provider.of<AppModel>(context, listen: false).locale,
                      );
                    },
                  ),
                ),
              ),
              Expanded(child: _renderSearchLayout()),
            ],
          ),
        ),
      ),
    );
  }
}
