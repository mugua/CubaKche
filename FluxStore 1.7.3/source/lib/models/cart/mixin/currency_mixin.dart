import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/config.dart';
import 'cart_mixin.dart';

mixin CurrencyMixin on CartMixin {
  Future getCurrency() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = prefs.getString("currency") ??
          (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    } catch (e) {
      currency = (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    }
  }

  Future getCurrencyString() async {
    String currency;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = prefs.getString("currency") ??
          (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    } catch (e) {
      currency = (kAdvanceConfig['DefaultCurrency'] as Map)['currency'];
    }
    return currency;
  }

  void changeCurrency(value) {
    currency = value;
  }
}
