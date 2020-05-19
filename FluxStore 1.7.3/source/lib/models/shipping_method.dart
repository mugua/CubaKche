import 'package:flutter/material.dart';
import 'package:quiver/strings.dart';

import '../common/constants.dart';
import '../models/address.dart';
import '../services/index.dart';

class ShippingMethodModel extends ChangeNotifier {
  final Services _service = Services();
  List<ShippingMethod> shippingMethods;
  bool isLoading = true;
  String message;

  Future<void> getShippingMethods(
      {Address address, String token, String checkoutId}) async {
    try {
      isLoading = true;
      notifyListeners();
      shippingMethods = await _service.getShippingMethods(
          address: address, token: token, checkoutId: checkoutId);
      isLoading = false;
      message = null;
      notifyListeners();
    } catch (err) {
      isLoading = false;
      message = "⚠️ " + err.toString();
      notifyListeners();
    }
  }
}

class ShippingMethod {
  String id;
  String title;
  String description;
  double cost;
  double min_amount;
  String classCost;
  String methodId;
  String methodTitle;

  Map<String, dynamic> toJson() {
    return {"id": id, "title": title, "description": description, "cost": cost};
  }

  ShippingMethod.fromJson(Map<String, dynamic> parsedJson) {
    try {
      id = "${parsedJson["id"]}";
      title = isNotBlank(parsedJson["title"])
          ? parsedJson["title"]
          : parsedJson["method_title"];
      description = parsedJson["method_description"];
      methodId = parsedJson["method_id"];
      methodTitle = parsedJson["method_title"];
      cost = 0.0;
      if (parsedJson["settings"]["cost"] != null) {
        cost = double.parse(parsedJson["settings"]["cost"]["value"]);
      }
      parsedJson["settings"]["min_amount"] != null
          ? min_amount =
              double.parse(parsedJson["settings"]["min_amount"]["value"])
          : min_amount = null;
      Map settings = parsedJson["settings"];
      settings.keys.forEach((key) {
        if (key is String && key.contains("class_cost_")) {
          classCost = parsedJson["settings"][key]["value"];
        }
      });
    } catch (e) {
      printLog('error parsing Shipping method');
    }
  }

  ShippingMethod.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["carrier_code"];
    title = parsedJson["carrier_title"];
    description = parsedJson["method_title"];
    cost = parsedJson["amount"] != null
        ? double.parse("${parsedJson["amount"]}")
        : 0.0;
  }

  ShippingMethod.fromOpencartJson(Map<String, dynamic> parsedJson) {
    Map<String, dynamic> quote = parsedJson["quote"];
    Map<String, dynamic> item =
        quote.values.isNotEmpty ? quote.values.toList()[0] : null;
    id = item != null ? item["code"] : "0";
    title = parsedJson["title"] ?? id;
    description = item != null && item["title"] != null ? item["title"] : "";
    cost = 0;
  }

  ShippingMethod.fromShopifyJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["handle"];
    title = parsedJson["title"];
    description = parsedJson["title"];
    var price = parsedJson["priceV2"] ?? parsedJson["price"] ?? "0";
    cost = double.parse(price);
  }
}
