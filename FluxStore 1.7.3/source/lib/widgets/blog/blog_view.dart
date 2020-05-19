import 'package:flutter/material.dart';
import 'package:html/parser.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../models/blogs/blog.dart';
import 'detailed_blog_fullsize_image.dart';
import 'detailed_blog_half_image.dart';
import 'detailed_blog_quarter_image.dart';
import 'detailed_blog_view.dart';

Widget getDetailPageView(List<Blog> posts) {
  return PageView.builder(
    itemCount: posts.length,
    itemBuilder: (context, position) {
      return getDetailScreen(posts, position);
    },
  );
}

Widget getDetailScreen(List<Blog> posts, index) {
  if (Videos.getVideoLink(posts[index].content) != null) {
    return OneQuarterImageType(item: posts[index]);
  } else {
    switch (kAdvanceConfig['DetailedBlogLayout']) {
      case kBlogLayout.halfSizeImageType:
        return HalfImageType(item: posts[index]);
      case kBlogLayout.fullSizeImageType:
        return FullImageType(item: posts[index]);
      case kBlogLayout.oneQuarterImageType:
        return OneQuarterImageType(item: posts[index]);
      default:
        return BlogDetail(item: posts[index]);
    }
  }
}

class BlogItemView extends StatelessWidget {
  final List<Blog> posts;
  final int index;

  const BlogItemView({this.posts, this.index});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            fullscreenDialog: kLayoutWeb,
            builder: (context) => getDetailPageView(posts.sublist(index)),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(
          maxWidth: kLayoutWeb
              ? MediaQuery.of(context).size.width * 0.6
              : MediaQuery.of(context).size.width,
        ),
        child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Container(
            width: 400,
            child: ListTile(
              leading: Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                alignment: Alignment.center,
                child: Tools.image(
                  url: posts[index].imageFeature,
                  width: 100,
                  size: kSize.medium,
                  isVideo: Videos.getVideoLink(posts[index].content) == null
                      ? false
                      : true,
                ),
              ),
              title: Text(posts[index].title ?? '',
                  maxLines: 2, style: TextStyle(fontSize: 15.0)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  posts[index].date ?? '',
                  style: TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ),
              dense: false,
            ),
          ),
        ),
      ),
    );
  }
}

class BlogCardView extends StatelessWidget {
  final List<Blog> posts;
  final int index;

  BlogCardView({this.posts, this.index});

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return posts[index].id != null
        ? InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  fullscreenDialog: kLayoutWeb,
                  builder: (context) => getDetailPageView(posts.sublist(index)),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.only(right: 15, left: 15),
              child: Column(
                children: <Widget>[
                  SizedBox(height: 20.0),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3.0),
                    child: Hero(
                      tag: 'blog-${posts[index].id}',
                      child: Tools.image(
                        url: posts[index].imageFeature,
                        width: screenWidth,
                        height: screenWidth * 0.5,
                        fit: BoxFit.fitWidth,
                        size: kSize.medium,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                    width: screenWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          posts[index].date ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                Theme.of(context).accentColor.withOpacity(0.5),
                          ),
                          maxLines: 2,
                        ),
                        SizedBox(width: 20.0),
                        if (posts[index].author != null)
                          Text(
                            posts[index].author.toUpperCase(),
                            style: TextStyle(
                                fontSize: 11,
                                height: 2,
                                fontWeight: FontWeight.bold),
                            maxLines: 2,
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    posts[index].title ?? '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    posts[index].subTitle != null
                        ? parse(posts[index].subTitle).documentElement.text
                        : '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.3,
                      color: Theme.of(context).accentColor.withOpacity(0.8),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 20.0),
                ],
              ),
            ))
        : Container();
  }
}
