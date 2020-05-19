import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/category/category.dart';
import '../../models/category/category_model.dart';
import '../../models/filter_attribute.dart';
import '../common/tree_view.dart';
import '../layout/layout_web.dart';

class BackdropMenu extends StatefulWidget {
  final Function onFilter;

  const BackdropMenu({
    Key key,
    this.onFilter,
  }) : super(key: key);

  @override
  _BackdropMenuState createState() => _BackdropMenuState();
}

class _BackdropMenuState extends State<BackdropMenu> {
  double mixPrice = 0.0;
  double maxPrice = kMaxPriceFilter / 2;
  String categoryId = '-1';
  String currentSlug;
  int currentSelectedAttr = -1;

  @override
  Widget build(BuildContext context) {
    final category = Provider.of<CategoryModel>(context);
    final selectLayout = Provider.of<AppModel>(context).productListLayout;
    final currency = Provider.of<AppModel>(context).currency;
    final filterAttr = Provider.of<FilterAttributeModel>(context);
    return ListenableProvider.value(
        value: category,
        child: Consumer<CategoryModel>(builder: (context, value, child) {
          if (value.isLoading) {
            print('Loading');
            return Center(child: Container(child: kLoadingWidget(context)));
          }

          if (value.categories != null) {
            print(value.categories.length);
            final categories =
                value.categories.where((item) => item.parent == '0').toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  kLayoutWeb
                      ? SizedBox(
                          height: 100,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              SizedBox(width: 20),
                              GestureDetector(
                                child: Icon(Icons.arrow_back_ios,
                                    size: 22, color: Colors.white70),
                                onTap: () {
                                  if (kLayoutWeb) {
                                    LayoutWebCustom.changeStateMenu(true);
                                  }
                                  Navigator.of(context).pop();
                                },
                              ),
                              SizedBox(width: 20),
                              Text(
                                S.of(context).products,
                                style: TextStyle(
                                  fontSize: 21,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      : SizedBox(),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      S.of(context).layout.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Wrap(
                    children: <Widget>[
                      for (var item in kProductListLayout)
                        GestureDetector(
                          onTap: () =>
                              Provider.of<AppModel>(context, listen: false)
                                  .updateProductListLayout(item['layout']),
                          child: Container(
                            width: 40,
                            height: 40,
                            margin: const EdgeInsets.all(10.0),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Image.asset(
                                item['image'],
                                color: selectLayout == item['layout']
                                    ? Colors.white
                                    : Colors.black.withOpacity(0.2),
                              ),
                            ),
                            decoration: BoxDecoration(
                                color: selectLayout == item['layout']
                                    ? Colors.black.withOpacity(0.15)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(9.0)),
                          ),
                        )
                    ],
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: Text(
                      S.of(context).byPrice.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        Tools.getCurrecyFormatted(mixPrice, currency: currency),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        " - ",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      Text(
                        Tools.getCurrecyFormatted(maxPrice, currency: currency),
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  ),
                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: Color(kSliderActiveColor),
                      inactiveTrackColor: Color(kSliderInactiveColor),
                      activeTickMarkColor: Colors.white70,
                      inactiveTickMarkColor: Colors.black,
                      overlayColor: Colors.black12,
                      thumbColor: Color(kSliderActiveColor),
                      showValueIndicator: ShowValueIndicator.always,
                    ),
                    child: RangeSlider(
                      min: 0.0,
                      max: kMaxPriceFilter,
                      divisions: kFilterDivision,
                      values: RangeValues(mixPrice, maxPrice),
                      onChanged: (RangeValues values) {
                        setState(() {
                          mixPrice = values.start;
                          maxPrice = values.end;
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 30),
                    child: Text(
                      S.of(context).attributes.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  ListenableProvider.value(
                    value: filterAttr,
                    child: Consumer<FilterAttributeModel>(
                        builder: (context, value, child) {
                      if (value.lstProductAttribute != null) {
                        List<Widget> list = List.generate(
                            value.lstProductAttribute.length, (index) {
                          return InkWell(
                            onTap: () {
                              if (!value.isLoading) {
                                currentSelectedAttr = index;

                                currentSlug =
                                    value.lstProductAttribute[index].slug;
                                value.getAttr(
                                    id: value.lstProductAttribute[index].id);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.all(5.0),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 13.0, vertical: 10.0),
                                child: Text(
                                  value.lstProductAttribute[index].name
                                      .toUpperCase(),
                                  style: currentSelectedAttr != -1
                                      ? currentSelectedAttr == index
                                          ? TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                              fontSize: 13,
                                            )
                                          : TextStyle(
                                              color:
                                                  Colors.black.withOpacity(0.3),
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                              fontSize: 13,
                                            )
                                      : TextStyle(
                                          color: Colors.black.withOpacity(0.3),
                                          fontWeight: FontWeight.bold,
                                        ),
                                ),
                              ),
                              decoration: BoxDecoration(
                                color: currentSelectedAttr != -1
                                    ? currentSelectedAttr == index
                                        ? Colors.black.withOpacity(0.15)
                                        : Colors.black.withOpacity(0.05)
                                    : Colors.black.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(9.0),
                              ),
                            ),
                          );
                        });

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            Container(
                              child: Wrap(
                                children: [
                                  ...list,
                                ],
                              ),
                              margin: EdgeInsets.symmetric(horizontal: 10),
                            ),
                            value.isLoading
                                ? Center(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        top: 10.0,
                                      ),
                                      width: 25.0,
                                      height: 25.0,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.0,
                                      ),
                                    ),
                                  )
                                : Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    child: currentSelectedAttr == -1
                                        ? Container()
                                        : Wrap(
                                            children: List.generate(
                                                value.lstCurrentAttr.length,
                                                (index) {
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5),
                                                child: FilterChip(
                                                  label: Text(value
                                                      .lstCurrentAttr[index]
                                                      .name),
                                                  selected: value
                                                          .lstCurrentSelectedTerms[
                                                      index],
                                                  onSelected: (val) {
                                                    setState(() {
                                                      value.lstCurrentSelectedTerms[
                                                          index] = !value
                                                              .lstCurrentSelectedTerms[
                                                          index];
                                                    });
                                                  },
                                                ),
                                              );
                                            }),
                                          ),
                                  ),
                          ],
                        );
                      }
                      return Container();
                    }),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, top: 30),
                    child: Text(
                      S.of(context).byCategory.toUpperCase(),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 20),
                      child: Container(
                        padding: const EdgeInsets.only(top: 15.0),
                        decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(3.0)),
                        child: TreeView(
                          parentList: [
                            for (var item in categories)
                              Parent(
                                  parent: CategoryItem(
                                    item,
                                    hasChild:
                                        hasChildren(value.categories, item.id),
                                    isSelected: item.id == categoryId,
                                    onTap: (val) {
                                      setState(() {
                                        categoryId = val;
                                      });
                                    },
                                  ),
                                  childList: ChildList(children: [
                                    for (var category in getSubCategories(
                                        value.categories, item.id))
                                      Parent(
                                          parent: CategoryItem(
                                            category,
                                            isLast: true,
                                            isSelected:
                                                category.id == categoryId,
                                            onTap: (val) {
                                              setState(() {
                                                categoryId = val;
                                              });
                                            },
                                          ),
                                          childList: ChildList(
                                            children: const [],
                                          ))
                                  ]))
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.only(left: 15, right: 15),
                    child: Row(children: [
                      Expanded(
                        child: ButtonTheme(
                          height: 44,
                          child: RaisedButton(
                            elevation: 0.0,
                            color: Colors.white70,
                            onPressed: () {
                              widget.onFilter(
                                minPrice: mixPrice,
                                maxPrice: maxPrice,
                                categoryId: categoryId,
                                attribute: currentSlug,
                                currentSelectedTerms:
                                    filterAttr.lstCurrentSelectedTerms,
                              );
                            },
                            child: Text(S.of(context).apply),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3.0),
                            ),
                          ),
                        ),
                      )
                    ]),
                  ),
                  SizedBox(
                    height: 70,
                  )
                ],
              ),
            );
          }

          return null;
        }));
  }

  bool hasChildren(categories, id) {
    return categories.where((o) => o.parent == id).toList().length > 0;
  }

  List<Category> getSubCategories(categories, id) {
    return categories.where((o) => o.parent == id).toList();
  }
}

class CategoryItem extends StatelessWidget {
  final Category category;
  final bool isLast;
  final bool isSelected;
  final bool hasChild;
  final Function onTap;

  CategoryItem(this.category,
      {this.isLast = false,
      this.isSelected = true,
      this.hasChild = false,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: hasChild
          ? null
          : () {
              onTap(category.id);
            },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10.0),
        child: Row(
          children: <Widget>[
            Container(
                child: Icon(Icons.check,
                    color: isSelected ? Colors.white : Colors.transparent,
                    size: 20)),
            SizedBox(
              width: isLast ? 50 : 10,
            ),
            Expanded(
                child: Text(
              "${category.name}  "
              "${category.totalProduct != null ? '(${category.totalProduct})' : ''}",
              style: TextStyle(color: Colors.white, fontSize: 14),
            )),
            if (hasChild)
              Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 20,
              ),
            SizedBox(
              width: 20,
            )
          ],
        ),
      ),
    );
  }
}
