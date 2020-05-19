import 'package:flutter/material.dart';

import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../widgets/home/search/custom_search.dart';
import 'search/custom_search_page.dart' as search;

class Logo extends StatelessWidget {
  final config;

  Logo({this.config, Key key}) : super(key: key);

  Widget renderLogo() {
    if (config['image'] != null) {
      if (config['image'].indexOf('http') != -1) {
        return Image.network(
          config['image'],
          height: 40,
        );
      }
      return Image.asset(
        config['image'],
        height: 40,
      );
    }
    return Image.asset(kLogoImage, height: 40);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      width: screenSize.width,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Container(
          width:
              screenSize.width / (2 / (screenSize.height / screenSize.width)),
          constraints: BoxConstraints(minHeight: 40),
          child: Stack(
            children: <Widget>[
              if (config['showSearch'] ?? false)
                Positioned(
                  // top: 55,
                  right: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.search,
                      color: config['color'] != null
                          ? HexColor(config['color'])
                          : Theme.of(context).accentColor.withOpacity(0.6),
                      size: 22,
                    ),
                    onPressed: () {
                      search.showSearch(
                          context: context, delegate: CustomSearch());
                    },
                  ),
                ),
              if (config['showMenu'] ?? false)
                Positioned(
                  // top: 55,
                  left: 10,
                  child: IconButton(
                    icon: Icon(
                      Icons.blur_on,
                      color: config['color'] != null
                          ? HexColor(config['color'])
                          : Theme.of(context).accentColor.withOpacity(0.9),
                      size: 22,
                    ),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              Container(
                constraints: BoxConstraints(minHeight: 40),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      if (config['showLogo'] ?? false)
                        Center(child: renderLogo()),
                      if ((config['showLogo'] ?? true) &&
                          config['name'] != null)
                        SizedBox(
                          width: 5,
                        ),
                      if (config['name'] != null)
                        Text(
                          config['name'],
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
