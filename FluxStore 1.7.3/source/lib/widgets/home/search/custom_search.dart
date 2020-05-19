import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/constants.dart';
import '../../../generated/l10n.dart';
import '../../../models/product/product.dart';
import '../../../models/search.dart';
import '../../../models/app.dart';
import '../../../screens/search/widgets/recent/recent_search.dart';
import '../vertical/vertical_simple_list.dart';
import 'custom_search_page.dart';

class CustomSearch extends SearchCustomDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.search),
              onPressed: () {},
            )
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios, size: 20),
      onPressed: () {
        close(context, null);
      },
    );
  }

  Future<List<Product>> searchProduct(context, {name, page = 1}) async {
    return await Provider.of<SearchModel>(context, listen: true).searchProducts(
        name: name,
        page: page,
        lang: Provider.of<AppModel>(context, listen: false).locale);
  }

  @override
  Widget buildResults(BuildContext mainContext) {
    if (query.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(S.of(mainContext).searchInput),
          )
        ],
      );
    }
    return Column(
      children: <Widget>[
        FutureBuilder<List<Product>>(
          future: searchProduct(mainContext, name: query),
          builder: (context, snapshot) {
            if (!snapshot.hasData ||
                snapshot.connectionState == ConnectionState.waiting) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: kLoadingWidget(context),
                    ),
                  ],
                ),
              );
            } else {
              FocusScope.of(mainContext)..unfocus();
            }

            if (snapshot.data.isEmpty) {
              return Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Text(S.of(context).noProduct),
                    ),
                  ],
                ),
              );
            } else {
              var results = snapshot.data;
              return Expanded(
                child: Container(
                  color: Theme.of(context).backgroundColor,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      var result = results[index];
                      return SimpleListView(item: result);
                    },
                  ),
                ),
              );
            }
          },
        )
      ],
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    FocusScopeNode currentFocus = FocusScope.of(context);
    currentFocus.requestFocus();
    return ListenableProvider.value(
      value: Provider.of<SearchModel>(context),
      child: Consumer<SearchModel>(builder: (context, model, child) {
        return Padding(
          child: RecentSearches(
            onTap: (text) {
              query = text;
              showResults(context);
            },
          ),
          padding: const EdgeInsets.only(left: 10, right: 10),
        );
      }),
    );
  }
}
