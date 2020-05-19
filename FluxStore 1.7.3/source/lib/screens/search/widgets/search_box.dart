import 'dart:async';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

import '../../../models/app.dart';
import '../../../generated/l10n.dart';

class SearchBox extends StatefulWidget {
  final FocusNode focusNode;
  final Function(String) onChange;
  final Function() onCancel;
  final double width;

  SearchBox({
    Key key,
    this.onChange,
    this.focusNode,
    this.onCancel,
    this.width,
  }) : super(key: key);

  @override
  _SearchBoxState createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  var textController = TextEditingController();
  Timer _timer;

  double get widthButtonCancel => textController.text?.isEmpty ?? true ? 0 : 50;
  Widget _transitionBuilder(BuildContext context, Widget suggestionsBox,
      AnimationController controller) {
    if (_timer != null) {
      _timer.cancel();
    }
    _timer = Timer(
      Duration(milliseconds: 500),
      () {
        widget.onChange(textController.text);
      },
    );
    return suggestionsBox;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> suggestSearch = List<String>.from(
        Provider.of<AppModel>(context).appConfig['searchSuggestion'] ?? ['']);

    return Container(
      width: widget.width,
      child: Row(children: [
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/icons/tabs/icon-search.png",
                  width: 20,
                  color: Theme.of(context).accentColor,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(
                        fillColor: Theme.of(context).accentColor,
                        hintText: S.of(context).searchForItems,
                        enabledBorder: InputBorder.none,
                        border: InputBorder.none,
                      ),
                      controller: textController,
                      focusNode: widget.focusNode,
                    ),
                    suggestionsCallback: (String pattern) {
                      return List()
                        ..addAll(suggestSearch)
                        ..retainWhere(
                          (s) =>
                              s.toLowerCase().contains(pattern.toLowerCase()),
                        );
                    },
                    errorBuilder: (context, suggestion) {
                      return SizedBox();
                    },
                    noItemsFoundBuilder: (context) {
                      return SizedBox();
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    transitionBuilder: _transitionBuilder,
                    onSuggestionSelected: (suggestion) {
                      FocusScope.of(context)
                          .requestFocus(FocusNode()); //dismiss keyboard

                      if (suggestion != textController.text) {
                        setState(() {
                          textController.text = suggestion;
                        });
                        widget.onChange(suggestion);
                      }
                    },
                  ),
                ),
                AnimatedContainer(
                  width: widthButtonCancel,
                  child: GestureDetector(
                    onTap: () {
                      widget.onCancel();
                      textController.text = "";
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                    child: Center(
                      child: Text(
                        S.of(context).cancel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  duration: Duration(milliseconds: 200),
                )
              ],
            ),
          ),
        ),
      ]),
    );
  }
}
