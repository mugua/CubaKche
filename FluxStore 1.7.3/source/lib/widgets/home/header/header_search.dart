import 'package:flutter/material.dart';

import '../../../common/tools.dart';
import '../../../widgets/home/search/custom_search.dart';
import '../../../widgets/home/search/custom_search_page.dart' as search;

class HeaderSearch extends StatelessWidget {
  final config;

  HeaderSearch({this.config, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final text = config["text"] ?? '';

    return Container(
      padding: EdgeInsets.all(Tools.formatDouble(config['padding'] ?? 20.0)),
      width: MediaQuery.of(context).size.width,
      height: Tools.formatDouble(config['height'] ?? 85.0),
      child: SafeArea(
        bottom: false,
        top: config['isSafeArea'] == true,
        child: InkWell(
          onTap: () {
            search.showSearch(context: context, delegate: CustomSearch());
          },
          child: Container(
            padding: const EdgeInsets.only(left: 15.0, right: 15.0),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColorLight,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: Tools.formatDouble(config['shadow'] ?? 15.0),
                  offset: Offset(0, Tools.formatDouble(config['shadow'] ?? 10.0)),
                ),
              ],
              borderRadius: BorderRadius.circular(
                Tools.formatDouble(config['radius'] ?? 30.0),
              ),
              border: Border.all(
                width: 1.0,
                color: Colors.black.withOpacity(0.05),
              ),
            ),
            child: Row(
              children: <Widget>[
                Icon(Icons.search, size: 24),
                SizedBox(
                  width: 12.0,
                ),
                Text(text)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
