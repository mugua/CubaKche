import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/blogs/blog_news.dart';
import '../../services/index.dart';
import '../../widgets/blog/detailed_blog/blog_view.dart';
import '../home/header/header_view.dart';

class HorizontalSliderList extends StatefulWidget {
  final Map<String, dynamic> config;

  HorizontalSliderList({this.config});

  @override
  _HorizontalSliderListState createState() => _HorizontalSliderListState();
}

class _HorizontalSliderListState extends State<HorizontalSliderList>
    with AutomaticKeepAliveClientMixin {
  Future<List<BlogNews>> _fetchBlogs;

  final _memoizer = AsyncMemoizer<List<BlogNews>>();
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // only create the future once
    Future.delayed(Duration.zero, () {
      setState(() {
        _fetchBlogs = getBlogs(context);
      });
    });
    super.initState();
  }

  Future<List<BlogNews>> getBlogs(context) async {
    return _memoizer.runOnce(
      () => Services().fetchBlogLayout(
          config: widget.config,
          lang: Provider.of<AppModel>(context, listen: false).locale),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final double imageBorder = (widget.config['imageBorder'] != null)
        ? widget.config['imageBorder']
        : 3.0;
    final blogEmptyList = [
      BlogNews.empty(1),
      BlogNews.empty(2),
      BlogNews.empty(3)
    ];

    return SafeArea(
      child: FutureBuilder<List<BlogNews>>(
        future: _fetchBlogs,
        builder:
            (BuildContext context, AsyncSnapshot<List<BlogNews>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Column(
                  children: <Widget>[
                    HeaderView(
                      headerText: widget.config["name"] != null
                          ? widget.config["name"]
                          : ' ',
                      showSeeAll: false,
                      callback: () => null,
                    ),
                    for (var i = 0; i < 3; i++)
                      BlogItem(
                        blogs: blogEmptyList,
                        index: i,
                        type: widget.config["type"],
                        imageBorder: imageBorder,
                      )
                  ],
                ),
              );
            case ConnectionState.done:
            default:
              if (snapshot.hasError || snapshot.data.isEmpty) {
                return Container();
              } else {
                return Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        S.of(context).blog,
                        style: TextStyle(
                            fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 15),
                        child: ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, i) {
                            return BlogItem(
                              blogs: snapshot.data,
                              index: i,
                              type: widget.config["type"],
                              imageBorder: imageBorder,
                              isVideo: Videos.getVideoLink(
                                          snapshot.data[i].content) ==
                                      null
                                  ? false
                                  : true,
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              }
          }
        },
      ),
    );
  }
}

class BlogItem extends StatelessWidget {
  final List<BlogNews> blogs;
  final int index;
  final double width;
  final String type;
  final double imageBorder;
  final isVideo;

  BlogItem(
      {this.blogs,
      this.index,
      this.width,
      this.type,
      this.imageBorder,
      this.isVideo});

  @override
  Widget build(BuildContext context) {
    double imageWidth = (width == null) ? 150 : width;
    double titleFontSize = imageWidth / 10;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => getDetailPageView(blogs.sublist(index)),
            ),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: type == "imageOnTheRight"
              //display image on the right
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            blogs[index].title,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).accentColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: imageWidth / 35,
                          ),
                          Text(
                            blogs[index].date == ''
                                ? S.of(context).loading
                                : Tools.formatDateString(blogs[index].date),
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          blogs[index].excerpt == S.of(context).loading
                              ? Text(
                                  blogs[index].excerpt,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          fontSize: 13.0,
                                          height: 1.4,
                                          color: Theme.of(context).accentColor),
                                )
                              : Text(
                                  parse(blogs[index].excerpt)
                                      .documentElement
                                      .text,
                                  maxLines: 3,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          fontSize: 13.0,
                                          height: 1.4,
                                          color: Theme.of(context).accentColor),
                                ),
//                              : HtmlWidget(
//                                  blogs[index].excerpt.substring(0, 100) + ' ...',
//                                  bodypadding: const EdgeInsets.only(top: 15),
//                                  hyperlinkColor: Theme.of(context).primaryColor.withOpacity(0.9),
//                                  textStyle: Theme.of(context).textTheme.body1.copyWith(
//                                      fontSize: 13.0,
//                                      height: 1.4,
//                                      color: Theme.of(context).accentColor),
//                                ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(imageBorder),
                          ),
                          child: Tools.image(
                            url: blogs[index].imageFeature,
                            width: imageWidth,
                            height: imageWidth,
                            fit: BoxFit.cover,
                            isVideo:
                                Videos.getVideoLink(blogs[index].content) ==
                                        null
                                    ? false
                                    : true,
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              // else display image on the left
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.all(
                            Radius.circular(imageBorder),
                          ),
                          child: Tools.image(
                            url: blogs[index].imageFeature,
                            width: imageWidth,
                            height: imageWidth,
                            fit: BoxFit.cover,
                            isVideo: isVideo,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            blogs[index].title,
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).accentColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: imageWidth / 35,
                          ),
                          Text(
                            blogs[index].date == ''
                                ? S.of(context).loading
                                : Tools.formatDateString(blogs[index].date),
                            style: TextStyle(
                              color: Theme.of(context).accentColor,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          blogs[index].excerpt == S.of(context).loading
                              ? Text(blogs[index].excerpt)
                              : Text(
                                  parse(blogs[index].excerpt)
                                      .documentElement
                                      .text,
                                  maxLines: 3,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyText1
                                      .copyWith(
                                          fontSize: 13.0,
                                          height: 1.4,
                                          color: Theme.of(context).accentColor),
                                ),
                        ],
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }
}
