import 'package:flutter/material.dart';
import '../../models/category/category.dart';
import '../../models/product/product.dart';

class ColumnCategories extends StatefulWidget {
  final List<Category> categories;

  ColumnCategories(this.categories);

  @override
  State<StatefulWidget> createState() {
    return ColumnCategoriesState();
  }
}

class ColumnCategoriesState extends State<ColumnCategories> {
  @override
  Widget build(BuildContext context) {
    return GridView(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 200.0,
        mainAxisSpacing: 0.0,
        crossAxisSpacing: 0.0,
        childAspectRatio: 0.75,
      ),
      children: List.generate(widget.categories.length, (index) {
        return Container(
          padding: _edgeInsetsForIndex(index),
          child: CategoryColumnItem(widget.categories[index]),
        );
      }),
    );
  }

  EdgeInsets _edgeInsetsForIndex(int index) {
    if (index % 2 == 0) {
      return EdgeInsets.only(top: 4.0, left: 8.0, right: 4.0, bottom: 4.0);
    } else {
      return EdgeInsets.only(top: 4.0, left: 4.0, right: 8.0, bottom: 4.0);
    }
  }
}

class CategoryColumnItem extends StatelessWidget {
  final Category category;

  CategoryColumnItem(this.category);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Product.showList(
          context: context, cateId: category.id, cateName: category.name),
      child: Container(
        child: Stack(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                    image: NetworkImage(category.image), fit: BoxFit.cover),
              ),
            ),
            Container(
                color: Color.fromRGBO(0, 0, 0, 0.4),
                child: Center(
                  child: Text(
                    category.name,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
