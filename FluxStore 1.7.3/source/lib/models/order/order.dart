import '../product/product_variation.dart';

import '../../common/config.dart';
import '../address.dart';
import '../cart/cart_model.dart';
import '../product/product.dart';

class Order {
  String id;
  String number;
  String status;
  DateTime createdAt;
  DateTime dateModified;
  double total;
  double totalTax;
  String paymentMethodTitle;
  String shippingMethodTitle;
  String customerNote;
  List<ProductItem> lineItems = [];
  Address billing;
  String statusUrl;
  double subtotal;

  Order({this.id, this.number, this.status, this.createdAt, this.total});

  Order.fromJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["id"].toString();
      customerNote = parsedJson["customer_note"];
      number = parsedJson["number"];
      status = parsedJson["status"];
      createdAt = parsedJson["date_created"] != null ? DateTime.parse(parsedJson["date_created"]) : DateTime.now();
      dateModified = parsedJson["date_modified"] != null ? DateTime.parse(parsedJson["date_modified"]) : DateTime.now();
      total = parsedJson["total"] != null ? double.parse(parsedJson["total"]) : 0.0;
      totalTax = parsedJson["total_tax"] != null ? double.parse(parsedJson["total_tax"]) : 0.0;
      paymentMethodTitle = parsedJson["payment_method_title"];

      parsedJson["line_items"].forEach((item) {
        lineItems.add(ProductItem.fromJson(item));
      });

      billing = Address.fromJson(parsedJson["billing"]);
      shippingMethodTitle = parsedJson["shipping_lines"] != null && parsedJson["shipping_lines"].length > 0
          ? parsedJson["shipping_lines"][0]["method_title"]
          : null;
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  Order.fromOpencartJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["order_id"].toString();
      number = parsedJson["order_id"];
      status = parsedJson["status"];
      createdAt = parsedJson["date_added"] != null ? DateTime.parse(parsedJson["date_added"]) : DateTime.now();
      total = parsedJson["total"] != null ? double.parse(parsedJson["total"]) : 0.0;
      paymentMethodTitle = "";
      shippingMethodTitle = "";
      lineItems = [];
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  Order.fromMagentoJson(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["entity_id"];
      number = "${parsedJson["entity_id"]}";
      status = parsedJson["status"];
      createdAt = parsedJson["created_at"] != null ? DateTime.parse(parsedJson["created_at"]) : DateTime.now();
      total = parsedJson["base_grand_total"] != null ? double.parse("${parsedJson["base_grand_total"]}") : 0.0;
      paymentMethodTitle = parsedJson["payment"]["additional_information"][0];
      shippingMethodTitle = parsedJson["shipping_description"];
      parsedJson["items"].forEach((item) {
        lineItems.add(ProductItem.fromMagentoJson(item));
      });
      billing = Address.fromMagentoJson(parsedJson["billing_address"]);
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  Map<String, dynamic> toOrderJson(CartModel cartModel, userId) {
    var items = lineItems.map((index) {
      return index.toJson();
    }).toList();

    return {
      "status": status,
      "total": total.toString(),
      "shipping_lines": [
        {"method_title": shippingMethodTitle}
      ],
      "number": number,
      "billing": billing,
      "line_items": items,
      "id": id,
      "date_created": createdAt.toString(),
      "payment_method_title": paymentMethodTitle
    };
  }

  Map<String, dynamic> toJson(CartModel cartModel, userId, paid) {
    var lineItems = cartModel.productsInCart.keys.map((key) {
      String productId = Product.cleanProductID(key);
      String productVariantId = ProductVariation.cleanProductVariantID(key);
//      Product product = cartModel.item[productId];

      var item = {"product_id": productId, "quantity": cartModel.productsInCart[key]};
      //int quantity = cartModel.productsInCart[key];
//      String total;
//      String subtotal;
      if (cartModel.productVariationInCart[key] != null && productVariantId != null) {
        item["variation_id"] = cartModel.productVariationInCart[key].id;
//        total = (double.parse(isNotBlank(cartModel.productVariationInCart[key].price)
//                    ? cartModel.productVariationInCart[key].price
//                    : "0") *
//                quantity)
//            .toString();
//        subtotal = (cartModel.getItemTotal(
//                productVariation: cartModel.productVariationInCart[key], product: product, quantity: quantity))
//            .toString();
//      } else {
//        total = (double.parse(isNotBlank(product.price) ? product.price : "0") * quantity).toString();
//        subtotal = (cartModel.getItemTotal(product: product, quantity: quantity)).toString();
      }

//      //before apply any coupons
//      item['subtotal'] = total;
//
//      /// after apply any coupons
//      item['total'] = subtotal;
      return item;
    }).toList();

    var params = {
      "set_paid": paid,
      "line_items": lineItems,
      "customer_id": userId,
    };
    try {
      if (cartModel.paymentMethod != null) {
        params["payment_method"] = cartModel.paymentMethod.id;
      }
      if (cartModel.paymentMethod != null) {
        params["payment_method_title"] = cartModel.paymentMethod.title;
      }
      if (paid) params["status"] = "completed";

      if (cartModel.address.mapUrl != null && cartModel.address.mapUrl.isNotEmpty) {
        params["customer_note"] = "URL:" + cartModel.address.mapUrl;
      }
      if (kPaymentConfig['EnableReview'] && cartModel.notes != null && cartModel.notes.isNotEmpty) {
        if (params["customer_note"] != null) {
          params["customer_note"] += "\n" + cartModel.notes;
        } else {
          params["customer_note"] = cartModel.notes;
        }
      }

      if (kPaymentConfig['EnableAddress'] && cartModel.address != null) {
        params["billing"] = cartModel.address.toJson();
        params["shipping"] = cartModel.address.toJson();
      }

      if (kPaymentConfig['EnableShipping'] && cartModel.shippingMethod != null) {
        params["shipping_lines"] = [
          {
            "method_id": "${cartModel.shippingMethod.methodId}:${cartModel.shippingMethod.id}",
            "method_title": cartModel.shippingMethod.title,
            "total": cartModel.getShippingCost().toString()
          }
        ];
      }

      if (cartModel.couponObj != null) {
        params["coupon_lines"] = [
          cartModel.couponObj.toJson(),
        ];
        params["subtotal"] = cartModel.getSubTotal();
        params["total"] = cartModel.getTotal();
      }
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
    return params;
  }

  Map<String, dynamic> toMagentoJson(CartModel cartModel, userId, paid) {
    return {
      "set_paid": paid,
      "paymentMethod": {"method": cartModel.paymentMethod.id},
      "billing_address": cartModel.address.toMagentoJson()["address"],
    };
  }

  Order.fromShopify(Map<String, dynamic> parsedJson) {
    try {
      id = parsedJson["id"];
      number = "${parsedJson["orderNumber"]}";
//    status = parsedJson["statusUrl"];

      status = "";
      createdAt = DateTime.parse(parsedJson["processedAt"]);
      total = double.parse(parsedJson["totalPrice"]);
      paymentMethodTitle = "";
      shippingMethodTitle = "";
      statusUrl = parsedJson['statusUrl'];

      var totalTaxV2 = parsedJson["totalTaxV2"]["amount"] ?? "0";
      totalTax = double.parse(totalTaxV2);
      var subtotalTaxV2 = parsedJson["subtotalPriceV2"]["amount"] ?? "0";
      subtotal = double.parse(subtotalTaxV2);

      var items = parsedJson['lineItems']['edges'];
      items.forEach((item) {
        lineItems.add(ProductItem.fromShopifyJson(item['node']));
      });
      billing = Address.fromShopifyJson(parsedJson["shippingAddress"]);
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  @override
  String toString() => 'Order { id: $id  number: $number}';
}

class ProductItem {
  String productId;
  String name;
  int quantity;
  String total;

  ProductItem.fromJson(Map<String, dynamic> parsedJson) {
    try {
      productId = parsedJson["product_id"].toString();
      name = parsedJson["name"];
      quantity = parsedJson["quantity"];
      total = parsedJson["total"];
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {"product_id": productId, "name": name, "quantity": quantity, "total": total};
  }

  ProductItem.fromMagentoJson(Map<String, dynamic> parsedJson) {
    try {
      productId = "${parsedJson["item_id"]}";
      name = parsedJson["name"];
      quantity = parsedJson["qty_ordered"];
      total = parsedJson["base_row_total"].toString();
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }

  ProductItem.fromShopifyJson(Map<String, dynamic> parsedJson) {
    try {
      productId = parsedJson["title"];
      name = parsedJson["title"];
      quantity = parsedJson["quantity"];
      total = "";
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
    }
  }
}
