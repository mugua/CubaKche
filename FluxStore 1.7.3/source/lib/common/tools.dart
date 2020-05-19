import 'dart:convert' as convert;
import 'dart:io' show Platform;
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_statusbarcolor/flutter_statusbarcolor.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:quiver/strings.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:transparent_image/transparent_image.dart';
import 'package:validate/validate.dart';

import '../common/constants.dart';
import '../generated/l10n.dart';
import '../services/config.dart';
import '../widgets/common/skeleton.dart';
import 'config.dart';
import 'constants.dart';

enum kSize { small, medium, large }

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}

class Tools {
  static double formatDouble(dynamic value) => value * 1.0;

  static formatDateString(String date) {
    DateTime timeFormat = DateTime.parse(date);
    final timeDif = DateTime.now().difference(timeFormat);
    return timeago.format(DateTime.now().subtract(timeDif), locale: 'en');
  }

  static String formatImage(String url, [kSize size = kSize.medium]) {
    if (Config().isCacheImage ?? kAdvanceConfig['kIsResizeImage']) {
      String pathWithoutExt = p.withoutExtension(url);
      String ext = p.extension(url);
      String imageURL = url ?? kDefaultImage;

      if (ext == ".jpeg") {
        imageURL = url;
      } else {
        switch (size) {
          case kSize.large:
            imageURL = '$pathWithoutExt-large$ext';
            break;
          case kSize.small:
            imageURL = '$pathWithoutExt-small$ext';
            break;
          default: // kSize.medium:e
            imageURL = '$pathWithoutExt-medium$ext';
            break;
        }
      }

      return imageURL;
    } else {
      return url;
    }
  }

  static NetworkImage networkImage(String url, [kSize size = kSize.medium]) {
    return NetworkImage(formatImage(url, size) ?? kDefaultImage);
  }

  /// Smart image function to load image cache and check empty URL to return empty box
  /// Only apply for the product image resize with (small, medium, large)
  static image(
      {String url,
      kSize size,
      double width,
      double height,
      BoxFit fit,
      String tag,
      double offset = 0.0,
      bool isResize = false,
      isVideo = false,
      hidePlaceHolder = false}) {
    if (height == null && width == null) {
      width = 200;
    }

    if (url == null || url == '') {
      return Container(
          width: width,
          height: height ?? width * 1.2,
          color: Color(kEmptyColor));
    }

    if (isVideo) {
      return Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: Colors.black12.withOpacity(1)),
            child: ExtendedImage.network(
              isResize ? formatImage(url, size) : url,
              width: width,
              height: height ?? width * 1.2,
              fit: fit,
              cache: true,
              enableLoadState: false,
              alignment: Alignment(
                  (offset >= -1 && offset <= 1)
                      ? offset
                      : (offset > 0) ? 1.0 : -1.0,
                  0.0),
            ),
          ),
          Positioned.fill(
            child: Icon(
              Icons.play_circle_outline,
              color: Colors.white70.withOpacity(0.5),
              size: width == null ? 30 : width / 1.7,
            ),
          ),
        ],
      );
    }

    if (kIsWeb) {
      return FadeInImage.memoryNetwork(
        image: isResize ? formatImage(url, size) : url,
        fit: fit,
        width: width,
        height: height,
        placeholder: kTransparentImage,
      );
    }

    return ExtendedImage.network(isResize ? formatImage(url, size) : url,
        width: width,
        height: height,
        fit: fit,
        cache: true,
        enableLoadState: false,
        alignment: Alignment(
            (offset >= -1 && offset <= 1) ? offset : (offset > 0) ? 1.0 : -1.0,
            0.0), loadStateChanged: (ExtendedImageState state) {
      Widget widget;
      switch (state.extendedImageLoadState) {
        case LoadState.loading:
          widget = hidePlaceHolder
              ? Container()
              : Skeleton(
                  width: width ?? 100,
                  height: height ?? 140,
                );
          break;
        case LoadState.completed:
          widget = ExtendedRawImage(
              image: state.extendedImageInfo?.image,
              width: width,
              height: height,
              fit: fit);
          break;
        case LoadState.failed:
          widget = Container(
              width: width,
              height: height ?? width * 1.2,
              color: Color(kEmptyColor));
          break;
      }
      return widget;
    });

//    return ImageCustom(url: imageUrl, mainUrl: url, width: width, fit: fit, height: height, offset: offset,);
  }

  static String getVariantPriceProductValue(product, String currency,
      {bool onSale}) {
    String price = onSale == true
        ? (isNotBlank(product.salePrice) ? product.salePrice : product.price)
        : product.price;
    if (product.multiCurrencies != null &&
        product.multiCurrencies[currency] != null) {
      return product.multiCurrencies[currency]["price"];
    } else {
      return price;
    }
  }

  static String getPriceProductValue(product, String currency, {bool onSale}) {
    try {
      String price = onSale == true
          ? (isNotBlank(product.salePrice)
              ? product.salePrice ?? '0'
              : product.price)
          : (isNotBlank(product.regularPrice)
              ? product.regularPrice ?? '0'
              : product.price);
      if (product.multiCurrencies != null &&
          product.multiCurrencies[currency] != null &&
          onSale == true) {
        return product.multiCurrencies[currency]["price"];
      } else {
        return price;
      }
    } catch (e, trace) {
      print(e.toString());
      print(trace.toString());
      return '';
    }
  }

  static String getPriceProduct(product, String currency, {bool onSale}) {
    String price = getPriceProductValue(product, currency, onSale: onSale);
    return getCurrecyFormatted(price, currency: currency);
  }

  static String getCurrecyFormatted(price, {currency}) {
    Map<String, dynamic> defaultCurrency = kAdvanceConfig['DefaultCurrency'];
    List currencies = kAdvanceConfig["Currencies"] ?? [];
    if (currency != null && currencies.isNotEmpty) {
      currencies.forEach((item) {
        if ((item as Map)["currency"] == currency) {
          defaultCurrency = item;
        }
      });
    }

    final formatCurrency = NumberFormat.currency(
        symbol: "", decimalDigits: defaultCurrency['decimalDigits']);
    try {
      String number = "";
      if (price is String) {
        number =
            formatCurrency.format(price.isNotEmpty ? double.parse(price) : 0);
      } else {
        number = formatCurrency.format(price);
      }
      return defaultCurrency['symbolBeforeTheNumber']
          ? defaultCurrency['symbol'] + number
          : number + defaultCurrency['symbol'];
    } catch (err) {
      return defaultCurrency['symbolBeforeTheNumber']
          ? defaultCurrency['symbol'] + formatCurrency.format(0)
          : formatCurrency.format(0) + defaultCurrency['symbol'];
    }
  }

  /// check tablet screen
  static bool isTablet(MediaQueryData query) {
    if (kIsWeb) {
      return true;
    }

    if (Platform.isWindows || Platform.isMacOS) {
      return false;
    }

    var size = query.size;
    var diagonal =
        sqrt((size.width * size.width) + (size.height * size.height));
    var isTablet = diagonal > 1100.0;
    return isTablet;
  }

  /// cache avatar for the chat
  static getCachedAvatar(String avatarUrl) {
    return CachedNetworkImage(
      imageUrl: avatarUrl,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }

  static Future<List<dynamic>> loadStatesByCountry(String country) async {
    try {
      // load local config
      String path = "lib/config/states/state_${country.toLowerCase()}.json";
      final appJson = await rootBundle.loadString(path);
      return List<dynamic>.from(convert.jsonDecode(appJson));
    } catch (e) {
      return [];
    }
  }
}

class Validator {
  static String validateEmail(String value) {
    try {
      Validate.isEmail(value);
    } catch (e) {
      return 'The E-mail Address must be a valid email address.';
    }

    return null;
  }
}

class Videos {
  static String getVideoLink(String content) {
    if (_getYoutubeLink(content) != null) {
      return _getYoutubeLink(content);
    } else if (_getFacebookLink(content) != null) {
      return _getFacebookLink(content);
    } else {
      return _getVimeoLink(content);
    }
  }

  static String _getYoutubeLink(String content) {
    final regExp = RegExp(
        "https://www.youtube.com/((v|embed))\/?[a-zA-Z0-9_-]+",
        multiLine: true,
        caseSensitive: false);

    String youtubeUrl;

    try {
      if (content?.isNotEmpty ?? false) {
        Iterable<RegExpMatch> matches = regExp.allMatches(content);
        if (matches?.isNotEmpty ?? false) {
          youtubeUrl = matches?.first?.group(0) ?? '';
        }
      }
    } catch (error) {
//      printLog('[_getYoutubeLink] ${error.toString()}');
    }
    return youtubeUrl;
  }

  static String _getFacebookLink(String content) {
    final regExp = RegExp(
        "https://www.facebook.com\/[a-zA-Z0-9\.]+\/videos\/(?:[a-zA-Z0-9\.]+\/)?([0-9]+)",
        multiLine: true,
        caseSensitive: false);

    String facebookVideoId;
    String facebookUrl;
    try {
      if (content?.isNotEmpty ?? false) {
        Iterable<RegExpMatch> matches = regExp.allMatches(content);
        if (matches?.isNotEmpty ?? false) {
          facebookVideoId = matches.first.group(1);
          if (facebookVideoId != null) {
            facebookUrl =
                'https://www.facebook.com/video/embed?video_id=$facebookVideoId';
          }
        }
      }
    } catch (error) {
      print(error);
    }
    return facebookUrl;
  }

  static String _getVimeoLink(String content) {
    final regExp = RegExp("https://player.vimeo.com/((v|video))\/?[0-9]+",
        multiLine: true, caseSensitive: false);

    String vimeoUrl;

    try {
      if (content?.isNotEmpty ?? false) {
        Iterable<RegExpMatch> matches = regExp.allMatches(content);
        if (matches?.isNotEmpty ?? false) {
          vimeoUrl = matches.first.group(0);
        }
      }
    } catch (error) {
      print(error);
    }
    return vimeoUrl;
  }
}

class Utils {
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static void setStatusBarWhiteForeground(bool active) {
    if (kIsWeb == true) {
      return;
    }

    FlutterStatusbarcolor.setStatusBarWhiteForeground(active);
  }

  static Future<dynamic> parseJsonFromAssets(String assetsPath) async {
    return rootBundle.loadString(assetsPath).then(convert.jsonDecode);
  }

  static Function getLanguagesList = ([context]) {
    return [
      {
        "name": context != null ? S.of(context).english : "English",
        "icon": ImageCountry.GB,
        "code": "en",
        "text": "English",
        "storeViewCode": ""
      },
      {
        "name": context != null ? S.of(context).vietnamese : "Vietnam",
        "icon": ImageCountry.VN,
        "code": "vi",
        "text": "Vietnam",
        "storeViewCode": ""
      },
      {
        "name": context != null ? S.of(context).japanese : "Japanese",
        "icon": ImageCountry.JA,
        "code": "ja",
        "text": "Japanese",
        "storeViewCode": ""
      },
      {
        "name": context != null ? S.of(context).chinese : "Chinese",
        "icon": ImageCountry.ZH,
        "code": "zh",
        "text": "Chinese",
        "storeViewCode": ""
      },
      {
        "name": context != null ? S.of(context).indonesian : "Indonesian",
        "icon": ImageCountry.ID,
        "code": "id",
        "text": "Indonesian",
        "storeViewCode": "id"
      },
      {
        "name": context != null ? S.of(context).spanish : "Spanish",
        "icon": ImageCountry.ES,
        "code": "es",
        "text": "Spanish",
        "storeViewCode": ""
      },
      {
        "name": context != null ? S.of(context).arabic : "Arabic",
        "icon": ImageCountry.AR,
        "code": "ar",
        "text": "Arabic",
        "storeViewCode": "ar"
      },
      {
        "name": context != null ? S.of(context).romanian : "Romanian",
        "icon": ImageCountry.RO,
        "code": "ro",
        "text": "Romanian",
        "storeViewCode": "ro"
      },
      {
        "name": context != null ? S.of(context).turkish : "Turkish",
        "icon": ImageCountry.TR,
        "code": "tr",
        "text": "Turkish",
        "storeViewCode": "tr"
      },
      {
        "name": context != null ? S.of(context).italian : "Italian",
        "icon": ImageCountry.IT,
        "code": "it",
        "text": "Italian",
        "storeViewCode": "it"
      },
      {
        "name": context != null ? S.of(context).german : "German",
        "icon": ImageCountry.DE,
        "code": "de",
        "text": "German",
        "storeViewCode": "de"
      },
      {
        "name": context != null ? S.of(context).brazil : "Brazil",
        "icon": ImageCountry.BR,
        "code": "pt",
        "text": "Portuguese",
        "storeViewCode": "pt"
      },
      {
        "name": context != null ? S.of(context).french : "French",
        "icon": ImageCountry.FR,
        "code": "fr",
        "text": "French",
        "storeViewCode": "fr"
      }
    ];
  };
}
