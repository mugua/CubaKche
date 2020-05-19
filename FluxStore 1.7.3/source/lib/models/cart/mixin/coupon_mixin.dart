import '../../../common/tools.dart';
import '../../coupon.dart';
import 'cart_mixin.dart';

mixin CouponMixin on CartMixin {
  Coupon couponObj;

  String getCoupon() {
    if (couponObj != null) {
      if (couponObj.discountType == "percent") {
        return "-${couponObj.amount}%";
      } else if (couponObj.discountType == 'fixed_cart') {
        return "-" + Tools.getCurrecyFormatted(couponObj.amount, currency: currency);
      } else if (couponObj.discountType == 'fixed_product') {
        return "-" + Tools.getCurrecyFormatted(couponObj.amount * totalCartQuantity, currency: currency);
      }
    }
    return "";
  }

  double getCouponCost(subtotal) {
    if (couponObj != null) {
      if (couponObj.discountType == "percent") {
        return subtotal * couponObj.amount / 100;
      } else {
        return couponObj.amount * totalCartQuantity;
      }
    } else {
      return 0.0;
    }
  }
}
