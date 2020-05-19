import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/config.dart';
import '../common/constants.dart';
import '../services/index.dart';
import 'cart/cart_model.dart';
import 'category/category_model.dart';

class AppModel with ChangeNotifier {
  Map<String, dynamic> appConfig;
  bool isLoading = true;
  String message;
  bool darkTheme = false;
  String locale = kAdvanceConfig['DefaultLanguage'];
  String productListLayout;
  String currency; //USD, VND
  bool showDemo = false;
  String username;
  bool isInit = false;
  Function(int) navigateTab;

  void updateNavigateTab(value) {
    navigateTab = value;
    notifyListeners();
  }

  AppModel() {
    getConfig();
  }

  Future<bool> getConfig() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      locale = prefs.getString("language") ?? kAdvanceConfig['DefaultLanguage'];
      darkTheme = prefs.getBool("darkTheme") ?? false;
      currency = prefs.getString("currency") ??
          (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
      isInit = true;
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<bool> changeLanguage(String country, BuildContext context) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      locale = country;
      await prefs.setString("language", country);
      await loadAppConfig();
      notifyListeners();
      await Provider.of<CategoryModel>(context, listen: false)
          .getCategories(lang: country);
      return true;
    } catch (err) {
      return false;
    }
  }

  Future<void> changeCurrency(String item, BuildContext context) async {
    try {
      Provider.of<CartModel>(context, listen: false).changeCurrency(item);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = item;
      await prefs.setString("currency", currency);
      notifyListeners();
    } catch (error) {
      printLog('[_getFacebookLink] error: ${error.toString()}');
    }
  }

  Future<void> updateTheme(bool theme) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      darkTheme = theme;
      await prefs.setBool("darkTheme", theme);
      notifyListeners();
    } catch (error) {
      printLog('[_getFacebookLink] error: ${error.toString()}');
    }
  }

  void updateShowDemo(bool value) {
    showDemo = value;
    notifyListeners();
  }

  void updateUsername(String user) {
    username = user;
    notifyListeners();
  }

  void loadStreamConfig(config) {
    appConfig = config;
    productListLayout = appConfig['Setting']['ProductListLayout'];
    isLoading = false;
    notifyListeners();
  }

  Future<Map> loadAppConfig() async {
    try {
      if (!isInit) {
        await getConfig();
      }
      final LocalStorage storage = LocalStorage('builder.json');
      var config = await storage.getItem('config');
      if (config != null) {
        appConfig = config;
      } else {
        // ignore: prefer_contains
        if (kAppConfig.indexOf('http') != -1) {
          // load on cloud config and update on air
          final appJson = await http.get(Uri.encodeFull(kAppConfig),
              headers: {"Accept": "application/json"});
          appConfig = convert.jsonDecode(appJson.body);
        } else {
          // load local config
          String path = "lib/config/config_$locale.json";
          try {
            final appJson = await rootBundle.loadString(path);
            appConfig = convert.jsonDecode(appJson);
          } catch (e) {
            final appJson = await rootBundle.loadString(kAppConfig);
            appConfig = convert.jsonDecode(appJson);
          }
        }
      }
      productListLayout = appConfig['Setting']['ProductListLayout'];
      await Services().widget.onLoadedAppConfig((configCache) {
        appConfig = configCache;
      });
      isLoading = false;

      print('[Debug] Finish Load AppConfig');

      notifyListeners();

      return appConfig;
    } catch (err) {
      isLoading = false;
      message = err.toString();
      notifyListeners();
      return null;
    }
  }

  void updateProductListLayout(layout) {
    productListLayout = layout;
    notifyListeners();
  }
}

class App {
  Map<String, dynamic> appConfig;

  App(this.appConfig);
}
