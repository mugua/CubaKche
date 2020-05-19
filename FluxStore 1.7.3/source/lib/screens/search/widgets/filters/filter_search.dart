import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../generated/l10n.dart';
import '../../../../models/category/category.dart';
import '../../../../models/filter_attribute.dart';
import '../../../../models/filter_tags.dart';
import 'filter_search_attributes.dart';
import 'filter_search_category.dart';
import 'filter_search_tags.dart';

class SearchFilter extends StatefulWidget {
  final Function(Map<String, List>) onChange;

  SearchFilter({this.onChange});

  @override
  _SearchFilterState createState() => _SearchFilterState();
}

class _SearchFilterState extends State<SearchFilter> {
  final Map<String, List> _listResult = Map();

  List<FilterTag> listTag = List();
  List<Category> listCategory = List();
  List<SubAttribute> listAttribute = List();
  var colorSelected = Colors.white;

  StreamController<double> streamLocal = StreamController.broadcast();
  double initial = 0;
  double currentdy = -1;
  double heighPopup = 500;
  String slugAttri = '';

  get getPosition => 1 - ((currentdy < 0 ? 0 : currentdy) / heighPopup);

  renderWidgetFilter(List listItem, [bool isTag = false]) {
    final String tabLabel = isTag ? '#' : '';
    List<Widget> _list = List.generate(
      listItem.length,
      (int index) {
        return FlatButton(
          color: Theme.of(context).primaryColorLight,
          onPressed: () {
            listItem.removeAt(index);
            widget.onChange(_listResult);
            setState(() {});
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                '$tabLabel${listItem[index].name}',
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontSize: 14,
                ),
              ),
              SizedBox(width: 10),
              Icon(
                Icons.cancel,
                color: Theme.of(context).primaryColor,
                size: 15,
              )
            ],
          ),
        );
      },
    );
    return _list.isNotEmpty ? _list : [];
  }

  renderContent(BuildContext context) {
    return GestureDetector(onPanStart: (DragStartDetails details) {
      initial = details.globalPosition.dy;
    }, onPanUpdate: (DragUpdateDetails details) {
      currentdy = details.globalPosition.dy - initial;
      streamLocal?.add(getPosition);
    }, onPanEnd: (DragEndDetails details) {
      if (getPosition < 0.4) {
        Navigator.pop(context);
      } else {
        streamLocal?.add(1);
      }
    }, child: Builder(
      builder: (context) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: heighPopup,
            padding: const EdgeInsets.symmetric(vertical: 15),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              boxShadow: kElevationToShadow[12],
              color: Theme.of(context).backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: Material(
              child: Container(
                color: Theme.of(context).backgroundColor,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      FilterSearchTags(
                        onSelect: (tag, currentSlug) {
                          listTag = tag;
                          _listResult['$currentSlug'] = listTag;
                          setState(() {});
                        },
                        listSelected: listTag,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 25,
                          bottom: 10,
                          left: 30,
                        ),
                        child: Text(
                          S.of(context).categories,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      FilderSearchCategory(
                        onSelect: (category, currentSlug) {
                          listCategory = category;
                          _listResult['$currentSlug'] = listCategory;
                          setState(() {});
                        },
                        listSelected: listCategory,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 25,
                          bottom: 10,
                          left: 30,
                        ),
                        child: Text(
                          S.of(context).attributes,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      FilterSearchAttributes(
                        listSelected: listAttribute,
                        slug: slugAttri,
                        onSelect: (attributes, currentSlug) {
                          listAttribute = attributes;
                          slugAttri = currentSlug;
                          _listResult['$currentSlug'] = listAttribute;
                          _listResult.removeWhere((key, value) =>
                              !key.contains('categorys') &&
                              !key.contains('tags') &&
                              !key.contains('$currentSlug'));
                          setState(() {});
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    ));
  }

  showFilter() async {
    await showGeneralDialog(
      useRootNavigator: false,
      transitionBuilder: (context, a1, a2, widget) {
        return StreamBuilder<double>(
            stream: streamLocal.stream,
            initialData: null,
            builder: (context, snapshot) {
              double _vitri = snapshot.data ?? a1.value;
              _vitri = _vitri < 0 ? 0 : _vitri > 1 ? 1 : _vitri;
              final curvedValue = Curves.linear.transform(1 - _vitri);
              return Transform(
                transform:
                    Matrix4.translationValues(0.0, curvedValue * 300, 0.0),
                child: widget,
              );
            });
      },
      transitionDuration: Duration(milliseconds: 200),
      barrierDismissible: true,
      barrierLabel: '',
      context: context,
      pageBuilder: (BuildContext context, Animation animation,
          Animation secondaryAnimation) {
        return renderContent(context);
      },
    );
    // handle filter
    widget.onChange(_listResult);
  }

  @override
  Widget build(BuildContext context) {
    colorSelected = Theme.of(context).primaryColor;
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 10, top: 15, right: 5),
          child: Text(
            S.of(context).all,
            style: TextStyle(
              fontSize: 13,
            ),
          ),
        ),
        ...renderWidgetFilter(listTag, true),
        ...renderWidgetFilter(listCategory),
        ...renderWidgetFilter(listAttribute),
        FlatButton.icon(
          color: Theme.of(context).primaryColorLight,
          onPressed: showFilter,
          icon: Icon(
            Icons.add,
            color: Theme.of(context).accentColor,
            size: 15,
          ),
          label: Text(
            S.of(context).filter,
            style: TextStyle(
              color: Theme.of(context).accentColor,
            ),
          ),
        ),
      ],
    );
  }
}
