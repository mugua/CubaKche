import '../../services/config.dart';
import '../../services/helper/magento.dart';
import 'product_attribute.dart';

class ProductVariation {
  String id;
  String sku;
  String price;
  String regularPrice;
  String salePrice;
  bool onSale;
  bool inStock;
  int stockQuantity;
  String imageFeature;
  List<Attribute> attributes = [];
  Map<String, dynamic> multiCurrencies;

  ProductVariation();

  ProductVariation.fromJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"].toString();
    price = parsedJson["price"];
    regularPrice = parsedJson["regular_price"];
    salePrice = parsedJson["sale_price"];
    onSale = parsedJson["on_sale"];
    inStock = parsedJson["in_stock"];
    inStock ? stockQuantity = parsedJson["stock_quantity"] : stockQuantity = 0;
    imageFeature = parsedJson["image"]["src"];

    List<Attribute> attributeList = [];
    parsedJson["attributes"].forEach((item) {
      attributeList.add(Attribute.fromJson(item));
    });
    attributes = attributeList;
    multiCurrencies = parsedJson['multi-currency-prices'];
  }

  ProductVariation.fromMagentoJson(Map<String, dynamic> parsedJson) {
    id = parsedJson["id"].toString();
    sku = parsedJson["sku"];
    price = parsedJson["price"].toString();
    regularPrice = parsedJson["price"].toString();
    salePrice = parsedJson["price"].toString();
    onSale = false;
    inStock = parsedJson["status"] == 1;

    final imageUrl = MagentoHelper.getCustomAttribute(parsedJson["custom_attributes"], "image");
    imageFeature = MagentoHelper.getProductImageUrlByName(Config().url, imageUrl);

    List<Attribute> attributeList = [];
    final color = MagentoHelper.getCustomAttribute(parsedJson["custom_attributes"], "color");
    final size = MagentoHelper.getCustomAttribute(parsedJson["custom_attributes"], "size");
    if (color != null) {
      attributeList.add(Attribute.fromMagentoJson({"value": color, "attribute_code": "color"}));
    }
    if (size != null) {
      attributeList.add(Attribute.fromMagentoJson({"value": size, "attribute_code": "size"}));
    }

    attributes = attributeList;
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "price": price,
      "regularPrice": regularPrice,
      "sale_price": salePrice,
      "on_sale": onSale,
      "in_stock": inStock,
      "stock_quantity": stockQuantity,
      "image": {"src": imageFeature},
      "attributes": attributes.map((item) {
        return item.toJson();
      }).toList()
    };
  }

  ProductVariation.fromLocalJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      price = json['price'];
      regularPrice = json['regularPrice'];
      onSale = json['onSale'];
      salePrice = json['salePrice'];
      inStock = json['inStock'];
      inStock ? stockQuantity = json["stock_quantity"] : stockQuantity = 0;
      imageFeature = json['image']["src"];
      List<Attribute> attributeList = [];

      if (json['attributes'] != null) {
        for (var item in json['attributes']) {
          attributeList.add(Attribute.fromLocalJson(item));
        }
      }

      attributes = attributeList;
    } catch (e) {
      print(e.toString());
    }
  }

  ProductVariation.fromShopifyJson(Map<String, dynamic> parsedJson) {
    var priceV2 = parsedJson['priceV2'];
    var compareAtPriceV2 = parsedJson['compareAtPriceV2'];
    var compareAtPrice = compareAtPriceV2 != null ? compareAtPriceV2['amount'] : null;

    id = parsedJson["id"];
    price = priceV2 != null ? priceV2['amount'] : null;
    regularPrice = compareAtPrice ?? price;
    onSale = compareAtPrice != null && compareAtPrice != price;
    inStock = parsedJson['availableForSale'];
    salePrice = compareAtPrice;
    imageFeature = parsedJson["image"]["src"];

    List<Attribute> attributeList = [];
    parsedJson["selectedOptions"].forEach((item) {
      attributeList.add(Attribute.fromShopifyJson(item));
    });
    attributes = attributeList;
  }

  /// Get product ID from mix String productID-ProductVariantID
  static String cleanProductVariantID(productString) {
    return productString.contains('-') ? productString.split('-')[1] : null;
  }
}
