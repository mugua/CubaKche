import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../common/constants.dart';
import '../../../../models/category/category.dart';
import '../../../../models/category/category_model.dart';

class FilderSearchCategory extends StatefulWidget {
  final Function(List<Category>, String) onSelect;
  final List<Category> listSelected;

  FilderSearchCategory({this.onSelect, this.listSelected});

  @override
  _FilderSearchCategoryState createState() => _FilderSearchCategoryState();
}

class _FilderSearchCategoryState extends State<FilderSearchCategory> {
  List<Category> _listSelect = List();

  bool checkAttributeSelected(String name) {
    bool _isFound = false;
    widget.listSelected.forEach((item) {
      _isFound = item.name == name ? true : _isFound;
    });
    return _isFound;
  }

  void _onTapCategory(Category _category) {
    bool _isFound = false;
    _listSelect.forEach((item) {
      _isFound = item.name == _category.name ? true : _isFound;
    });

    _listSelect?.clear();
    if (_isFound == false) {
      _listSelect.add(_category);
    }

    widget.onSelect(_listSelect, 'categorys');
    setState(() {});
  }

  @override
  void initState() {
    _listSelect = widget.listSelected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var Categorys = Provider.of<CategoryModel>(context);

    getColorSelectTextButton(bool isSelected) =>
        isSelected ? Colors.white : Theme.of(context).accentColor;

    getColorSelectBackgroundButton(bool isSelected) => isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).primaryColorLight;

    return ListenableProvider.value(
      value: Categorys,
      child: Consumer<CategoryModel>(builder: (context, value, child) {
        if (value.isLoading) {
          return Center(child: kLoadingWidget(context));
        }
        return Container(
          height: 80,
          child: Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(width: 30),
                  ...List.generate(
                    value.categories.length,
                    (int index) {
                      if (value.categories[index].parent == '0') {
                        return GestureDetector(
                          onTap: () {
                            _onTapCategory(value.categories[index]);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 15),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 20,
                            ),
                            child: Text(
                              '${value.categories[index].name}',
                              style: TextStyle(
                                fontSize: 17,
                                color: getColorSelectTextButton(
                                  checkAttributeSelected(
                                    value.categories[index].name,
                                  ),
                                ),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            decoration: BoxDecoration(
                              color: getColorSelectBackgroundButton(
                                checkAttributeSelected(
                                  value.categories[index].name,
                                ),
                              ),
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        );
                      }
                      return SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
