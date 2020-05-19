import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../generated/l10n.dart';
import '../../../../models/filter_tags.dart';

class FilterSearchTags extends StatefulWidget {
  final Function(List<FilterTag>, String) onSelect;
  final List<FilterTag> listSelected;

  FilterSearchTags({this.onSelect, this.listSelected});

  @override
  _FilterSearchTagsState createState() => _FilterSearchTagsState();
}

class _FilterSearchTagsState extends State<FilterSearchTags> {
  List<FilterTag> _listSelected;
  bool checkAttributeSelected(String name) {
    bool _isFound = false;
    widget.listSelected.forEach((item) {
      _isFound = item.name == name ? true : _isFound;
    });
    return _isFound;
  }

  void _onTapTag(FilterTag _tag) {
    bool _isFound = false;
    _listSelected.forEach((item) {
      _isFound = _tag.name == item.name ? true : _isFound;
    });

    _listSelected?.clear();
    if (_isFound == false) {
      _listSelected.add(_tag);
    }
    widget.onSelect(_listSelected, 'tags');
    setState(() {});
  }

  @override
  void initState() {
    _listSelected = widget.listSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var filterTags = Provider.of<FilterTagModel>(context);

    getColorSelectTextButton(bool isSelected) =>
        isSelected ? Colors.white : Theme.of(context).accentColor;

    getColorSelectBackgroundButton(bool isSelected) => isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColorLight;

    return ListenableProvider.value(
      value: filterTags,
      child: Consumer<FilterTagModel>(
        builder: (context, value, child) {
          if (value.isLoading) {
            return Center(child: kLoadingWidget(context));
          }
          if (value.lstProductTag == null) {
            return Container();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  top: 15,
                  bottom: 10,
                  left: 30,
                ),
                child: Text(
                  S.of(context).tags,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
              Container(
                height: 80,
                child: Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(width: 30),
                        ...List.generate(
                          value.lstProductTag.length,
                          (int index) {
                            return GestureDetector(
                              onTap: () {
                                _onTapTag(value.lstProductTag[index]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 15),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                                child: Text(
                                  '#${value.lstProductTag[index].name}',
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: getColorSelectTextButton(
                                      checkAttributeSelected(
                                        value.lstProductTag[index].name,
                                      ),
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                decoration: BoxDecoration(
                                  color: getColorSelectBackgroundButton(
                                    checkAttributeSelected(
                                      value.lstProductTag[index].name,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(3.0),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
