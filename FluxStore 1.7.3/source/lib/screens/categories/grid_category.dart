import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../models/category/category_model.dart';
import '../../models/product/product.dart';

class GridCategory extends StatefulWidget {
  @override
  _StateGridCategory createState() => _StateGridCategory();
}

class _StateGridCategory extends State<GridCategory> {
  @override
  Widget build(BuildContext context) {
    var categories =
        Provider.of<CategoryModel>(context, listen: false).categories;
    var icons = kGridIconsCategories.values.toList();

    if (categories == null) {
      return Container(
        child: kLoadingWidget(context),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            children: <Widget>[
              for (int i = 0; i < categories.length; i++)
                GestureDetector(
                  child: Container(
                    width: constraints.maxWidth /
                            kAdvanceConfig['GridCount'] -
                        20 * kAdvanceConfig['GridCount'],
                    margin: EdgeInsets.all(20.0),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: Image.asset(
                              kGridIconsCategories[categories[i].id] ??
                                  icons[i % icons.length],
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            categories[i].name,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  onTap: () {
                    Product.showList(
                        context: context,
                        cateId: categories[i].id,
                        cateName: categories[i].name);
                  },
                )
            ],
          ),
        );
      },
    );
  }
}
