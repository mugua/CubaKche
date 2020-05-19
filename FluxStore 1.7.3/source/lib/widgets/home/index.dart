import 'package:flutter/material.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import 'banner/banner_animate_items.dart';
import 'banner/banner_group_items.dart';
import 'banner/banner_slider_items.dart';
import 'category/category_icon_items.dart';
import 'category/category_image_items.dart';
import 'header/header_search.dart';
import 'header/header_text.dart';
import 'horizontal/blog_list_items.dart';
import 'horizontal/horizontal_list_items.dart';
import 'horizontal/instagram_items.dart';
import 'horizontal/simple_list.dart';
import 'horizontal/video/index.dart';
import 'logo.dart';
import 'product_list_layout.dart';
import 'vertical.dart';
import 'package:sticky_headers/sticky_headers.dart';

class HomeLayout extends StatefulWidget {
  final configs;

  HomeLayout({this.configs, Key key}) : super(key: key);

  @override
  _HomeLayoutState createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  /// convert the JSON to list of horizontal widgets
  Widget jsonWidget(config) {
    switch (config["layout"]) {
      case "logo":
        if (kLayoutWeb || widget.configs["Setting"]["StickyHeader"]) {
          return Container();
        }
        return Logo(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'header_text':
        if (kLayoutWeb) return Container();
        return HeaderText(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case 'header_search':
        if (kLayoutWeb) return Container();
        return HeaderSearch(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case "category":
        return (config['type'] == 'image')
            ? CategoryImages(
                config: config,
                key: config['key'] != null ? Key(config['key']) : null,
              )
            : CategoryIcons(
                config: config,
                key: config['key'] != null ? Key(config['key']) : null,
              );

      case "bannerAnimated":
        if (kLayoutWeb) return Container();
        return BannerAnimated(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case "bannerImage":
        if (config['isSlider'] == true) {
          return BannerSliderItems(
              config: config,
              key: config['key'] != null ? Key(config['key']) : null);
        }
        return BannerGroupItems(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case "largeCardHorizontalListItems":
        return LargeCardHorizontalListItems(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case "simpleVerticalListItems":
        return SimpleVerticalProductList(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case "instagram":
        return InstagramItems(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case "blog":
        return BlogListItems(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      case "video":
        return VideoLayout(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );

      default:
        return ProductListLayout(
          config: config,
          key: config['key'] != null ? Key(config['key']) : null,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.configs == null) return Container();
    ErrorWidget.builder = (error) {
      return Container(
        constraints: BoxConstraints(minHeight: 150),
        decoration: BoxDecoration(
            color: Colors.lightBlue.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5)),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),

        /// *   Hide error, if you're developer, enable it to fix error it has
        child: Center(
          child: Text('Error in ${error.exceptionAsString()}'),
        ),
      );
    };

    Widget listWidgets = Column(
      children: <Widget>[
        for (var config in widget.configs["HorizonLayout"])
          jsonWidget(
            config,
          ),
        if (widget.configs["VerticalLayout"] != null)
          VerticalLayout(
            config: widget.configs["VerticalLayout"],
            key: widget.configs["VerticalLayout"]['key'] != null
                ? Key(widget.configs["VerticalLayout"]['key'])
                : null,
          ),
      ],
    );

    Widget content = SingleChildScrollView(child: listWidgets);

    /// Override the content widget
    if (widget.configs["Setting"]["StickyHeader"]) {
      Map config = widget.configs["HorizonLayout"][0];
      content = SingleChildScrollView(
        child: StickyHeader(
          header: Container(
            height: 50.0,
            color: Theme.of(context).backgroundColor,
            alignment: Alignment.centerLeft,
            child: Logo(
              config: config,
              key: config['key'] != null ? Key(config['key']) : null,
            ),
          ),
          content: listWidgets,
        ),
      );
    }

    if (kIsWeb) return content;

    return RefreshIndicator(
      onRefresh: () => Future.delayed(
        Duration(milliseconds: 300),
      ),
      child: content,
    );
  }
}
