import 'package:after_layout/after_layout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../models/filter_attribute.dart';

class FilterSearchAttributes extends StatefulWidget {
  final Function(List<SubAttribute>, String) onSelect;
  final List<SubAttribute> listSelected;
  final String slug;

  FilterSearchAttributes({this.onSelect, this.listSelected, this.slug});

  @override
  _FilterSearchAttributesState createState() => _FilterSearchAttributesState();
}

class _FilterSearchAttributesState extends State<FilterSearchAttributes>
    with AfterLayoutMixin {
  FilterAttributeModel filterAttr;
  String currentSlug;
  int indexSelect = 0;
  int currentAttrID = -1;
  int currentTermId = -1;
  int currentSelectedAttr = -1;
  Color colorSelected = Colors.white;

  bool checkSubAttributeSelected(SubAttribute itemCheck) {
    bool _isFound = false;
    widget.listSelected.forEach((item) {
      _isFound = (item.name == itemCheck.name && item.id == itemCheck.id)
          ? true
          : _isFound;
    });
    return _isFound;
  }

  bool checkAttributeSelected(String slug) {
    return slug != null && slug == currentSlug;
  }

  void _onTapSubAttribute(SubAttribute _subAttribute) {
    bool _isFound = false;
    widget.listSelected.forEach((item) {
      _isFound =
          (item.name == _subAttribute.name && item.id == _subAttribute.id)
              ? true
              : _isFound;
    });

    widget.listSelected?.clear();
    if (_isFound == false) {
      widget.listSelected.add(_subAttribute);
    }

    widget.onSelect(widget.listSelected, currentSlug);
    setState(() {});
  }

  @override
  void afterFirstLayout(BuildContext context) {
    filterAttr = Provider.of<FilterAttributeModel>(context, listen: false);
    if (widget.listSelected?.isEmpty ?? true) {
      currentSelectedAttr = 0;
      currentSlug = filterAttr.lstProductAttribute.first.slug;
      currentAttrID = filterAttr.lstProductAttribute.first.id;
    }
  }

  @override
  void initState() {
    currentSlug = widget.slug;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    filterAttr = Provider.of<FilterAttributeModel>(context);
    getColorSelectTextTitle(bool isSelected) => isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).accentColor;

    getColorSelectTextButton(bool isSelected) =>
        isSelected ? Colors.white : Theme.of(context).accentColor;

    getColorSelectBackgroundButton(bool isSelected) => isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColorLight;

    return ListenableProvider.value(
      value: filterAttr,
      child: Consumer<FilterAttributeModel>(
        builder: (context, value, child) {
          if (value.lstProductAttribute != null &&
              value.lstProductAttribute.isNotEmpty) {
            List<Widget> list = List.generate(
              value.lstProductAttribute.length,
              (index) {
                return InkWell(
                  onTap: () {
                    if (!value.isLoading) {
                      currentSelectedAttr = index;
                      currentAttrID = value.lstProductAttribute[index].id;
                      currentSlug = value.lstProductAttribute[index].slug;
                      widget.listSelected?.clear();
                      widget.onSelect(widget.listSelected, currentSlug);
                      value.getAttr(id: currentAttrID);
                      setState(() {});
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text(
                          value.lstProductAttribute[index].name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: getColorSelectTextTitle(
                              checkAttributeSelected(
                                value.lstProductAttribute[index].slug,
                              ),
                            ),
                            letterSpacing: 1.2,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '|',
                          style: TextStyle(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.6),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: <Widget>[
                      SizedBox(
                        width: 20,
                      ),
                      ...list,
                    ],
                  ),
                ),
                if (value.isLoading)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(
                        top: 10.0,
                      ),
                      width: 25.0,
                      height: 25.0,
                      child: kLoadingWidget(context),
                    ),
                  ),
                SizedBox(height: 5),
                if (!value.isLoading)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: <Widget>[
                        SizedBox(width: 30),
                        ...List.generate(
                          value.lstCurrentAttr.length,
                          (index) {
                            return GestureDetector(
                              onTap: () {
                                _onTapSubAttribute(value.lstCurrentAttr[index]);
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 15),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 20,
                                ),
                                child: Text(
                                  value.lstCurrentAttr[index].name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: getColorSelectTextButton(
                                      checkSubAttributeSelected(
                                        value.lstCurrentAttr[index],
                                      ),
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                decoration: BoxDecoration(
                                  color: getColorSelectBackgroundButton(
                                    checkSubAttributeSelected(
                                      value.lstCurrentAttr[index],
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
              ],
            );
          }
          return Container();
        },
      ),
    );
  }
}
