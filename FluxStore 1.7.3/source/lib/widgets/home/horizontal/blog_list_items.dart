import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../common/config.dart';
import '../../../models/blogs/blog.dart';
import '../../../screens/blogs/blogs.dart';
import '../../../widgets/blog/blog_view.dart';
import '../../../widgets/home/header/header_view.dart';

class BlogListItems extends StatefulWidget {
  final config;

  BlogListItems({this.config, Key key}) : super(key: key);

  @override
  _BlogListItemsState createState() => _BlogListItemsState();
}

class _BlogListItemsState extends State<BlogListItems> {
  Widget _buildHeader(context, blogs) {
    if (widget.config.containsKey("name")) {
      var showSeeAllLink = widget.config['layout'] != "instagram";
      return HeaderView(
        headerText: widget.config["name"] ?? '',
        showSeeAll: showSeeAllLink,
        callback: () => {
          Navigator.push(
            context,
            MaterialPageRoute(
              fullscreenDialog: kLayoutWeb,
              builder: (context) => BlogScreen(),
            ),
          )
        },
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    var emptyPosts = [Blog.empty(1), Blog.empty(2), Blog.empty(3)];
    var blogs = Provider.of<BlogModel>(context).blogs;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (blogs.isEmpty) {
          return Column(
            children: <Widget>[
              _buildHeader(context, null),
              BlogItemView(posts: emptyPosts, index: 0),
              BlogItemView(posts: emptyPosts, index: 1),
              BlogItemView(posts: emptyPosts, index: 2),
            ],
          );
        }
        return Column(
          children: <Widget>[
            _buildHeader(context, blogs),
            Container(
              width: constraints.maxWidth,
              height: constraints.maxWidth * (kLayoutWeb ? 0.4 : 0.6),
              color: Theme.of(context).cardColor.withOpacity(0.85),
              padding: const EdgeInsets.only(top: 8.0),
              child: PageView(
                children: [
                  for (var i = 0; i < blogs.length; i = i + 3)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        blogs[i] != null
                            ? Expanded(
                                child: BlogItemView(posts: blogs, index: i),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                        i + 1 < blogs.length
                            ? Expanded(
                                child: BlogItemView(posts: blogs, index: i + 1),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                        i + 2 < blogs.length
                            ? Expanded(
                                child: BlogItemView(posts: blogs, index: i + 2),
                              )
                            : Expanded(
                                child: Container(),
                              ),
                      ],
                    )
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
