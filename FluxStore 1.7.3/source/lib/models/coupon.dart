class Coupons {
  var coupons = [];

  Coupons.getListCoupons(List a) {
    for (var i in a) {
      coupons.add(Coupon.fromJson(i));
    }
  }

  Coupons.getListCouponsOpencart(List a) {
    for (var i in a) {
      coupons.add(Coupon.fromOpencartJson(i));
    }
  }
}

class Coupon {
  double amount;
  var code;
  var message;
  var id;
  var discountType;
  var dateExpires;
  var description;
  double minimumAmount;
  double maximumAmount;

  Coupon.fromJson(Map<String, dynamic> json) {
    try {
      amount = double.parse(json["amount"].toString());
      code = json["code"];
      id = json["id"];
      discountType = json["discount_type"];
      description = json["description"];
      minimumAmount = json["minimum_amount"] != null ? double.parse(json["minimum_amount"].toString()) : 0.0;
      maximumAmount = json["maximum_amount"] != null ? double.parse(json["maximum_amount"].toString()) : 0.0;
      dateExpires = json["date_expires"] != null ? DateTime.parse(json["date_expires"]) : null;
      message = "";
    } catch (e) {
      print(e.toString());
    }
  }

  Coupon.fromOpencartJson(Map<String, dynamic> json) {
    try {
      amount = double.parse(json["discount"].toString());
      code = json["code"];
      id = json["coupon_id"];
      discountType = json["type"] == "P" ? "percent" : "fixed_cart";
      description = json["name"];
      minimumAmount = 0.0;
      maximumAmount = 0.0;
      dateExpires = DateTime.parse(json["date_end"]);
      message = "";
    } catch (e) {
      print(e.toString());
    }
  }

  Coupon.fromShopify(Map<String, dynamic> json) {
    try {
      amount = double.parse(json["totalPrice"].toString());
      code = json["code"];
      id = json["code"];
      discountType = "fixed_cart";
      description = "";
      minimumAmount = 0.0;
      maximumAmount = 0.0;
      dateExpires = null;
      message = "Hello";
    } catch (e) {
      print(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "amount": amount,
      "code": code,
      "discount_type": discountType,
      // "description": description,
      // "minimum_amount": minimumAmount,
      // "maximum_amount": maximumAmount,
      // "date_expires": dateExpires,
    };
  }
}
