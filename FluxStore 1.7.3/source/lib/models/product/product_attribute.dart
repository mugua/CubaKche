class ProductAttribute {
  String id;
  String name;
  List options;

  ProductAttribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"].toString();
    name = parsedJson["name"];
    options = parsedJson["options"];
  }

  ProductAttribute.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = "${parsedJson["attribute_id"]}";
    name = parsedJson["attribute_code"];
    options = parsedJson["options"];
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "options": options};
  }

  ProductAttribute.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      name = json['name'];
      options = json['options'];
    } catch (e) {
      print(e.toString());
    }
  }

  ProductAttribute.fromShopify(att) {
    try {
      id = att['id'];
      name = att['name'];
      options = att['values'];
    } catch (e) {
      print(e.toString());
    }
  }
}

class Attribute {
  int id;
  String name;
  String option;

  Attribute();

  Attribute.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    option = parsedJson["option"];
  }

  Attribute.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = int.parse(parsedJson["value"]);
    name = parsedJson["attribute_code"];
    option = parsedJson["value"];
  }

  Attribute.fromLocalJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    option = parsedJson["option"];
  }

  Attribute.fromShopifyJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"];
    name = parsedJson["name"];
    option = parsedJson["value"];
  }
  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "option": option};
  }
}
