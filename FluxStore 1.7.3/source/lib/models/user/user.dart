import 'user_address.dart';

class User {
  String id;
  bool loggedIn;
  String name;
  String firstName;
  String lastName;
  String username;
  String email;
  String nicename;
  String userUrl;
  String picture;
  String cookie;
  Shipping shipping;
  Billing billing;
  bool isSocial = false;

  User.fromWoJson(Map<String, dynamic> json) {
    try {
      id = json['id'];
      username = json['username'];
      firstName = json['first_name'];
      lastName = json['last_name'];
      email = json['email'];
      shipping = Shipping.fromJson(json['shipping']);
      billing = Billing.fromJson(json['billing']);
    } catch (e) {
      print(e.toString());
    }
  }

  // from WooCommerce Json
  User.fromJsonFB(Map<String, dynamic> json) {
    try {
      isSocial = true;
      var user = json['user'];
      loggedIn = true;
      id = json['wp_user_id'].toString();
      name = user['name'];
      username = user['user_login'];
      cookie = json['cookie'];
      firstName = user["first_name"];
      lastName = user["last_name"];
      email = user["email"];
      picture = user["picture"] != null &&
              user["picture"]["data"] != null &&
              user["picture"]['data']['url'] != null
          ? user["picture"]['data']['url']
          : '';
    } catch (e) {
      print(e.toString());
    }
  }

  // from WooCommerce Json
  User.fromJsonSMS(Map<String, dynamic> json) {
    try {
      var user = json['user'];
      loggedIn = true;
      id = json['wp_user_id'].toString();
      name = json['user_login'];
      cookie = json['cookie'];
      username = user['id'];
      firstName = json['user_login'];
      lastName = '';
      email = user['email'] ?? user['id'];
      isSocial = true;
    } catch (e) {
      print(e.toString());
    }
  }

  // from Magento Json
  User.fromMagentoJsonFB(Map<String, dynamic> json, token) {
    try {
      loggedIn = true;
      id = json['id'].toString();
      name = json['firstname'] + " " + json["lastname"];
      username = "";
      cookie = token;
      firstName = json["firstname"];
      lastName = json["lastname"];
      email = json["email"];
      picture = "";
      isSocial = true;
    } catch (e) {
      print(e.toString());
    }
  }

  // from Opencart Json
  User.fromOpencartJson(Map<String, dynamic> json, token) {
    try {
      loggedIn = true;
      id = (json['customer_id'] != null ? int.parse(json['customer_id']) : 0)
          .toString();
      name = json['firstname'] + " " + json["lastname"];
      username = "";
      cookie = token;
      firstName = json["firstname"];
      lastName = json["lastname"];
      email = json["email"];
      picture = "";
    } catch (e) {
      print(e.toString());
    }
  }

  // from Shopify json
  User.fromShopifyJson(Map<String, dynamic> json, token) {
    try {
      print("fromShopifyJson user $json");

      loggedIn = true;
      id = json['id'].toString();
      name = json['displayName'];
      username = "";
      cookie = token;
      firstName = json["firstName"];
      lastName = json["firstName"];
      email = json["email"];
      picture = "";
    } catch (e) {
      print(e.toString());
    }
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "loggedIn": loggedIn,
      "name": name,
      "firstName": firstName,
      "lastName": lastName,
      "username": username,
      "email": email,
      "picture": picture,
      "cookie": cookie,
      "nicename": nicename,
      "url": userUrl,
      "isSocial": isSocial
    };
  }

  User.fromLocalJson(Map<String, dynamic> json) {
    try {
      loggedIn = json['loggedIn'];
      id = json['id'].toString();
      name = json['name'];
      cookie = json['cookie'];
      username = json['username'];
      firstName = json['firstName'];
      lastName = json['lastName'];
      email = json['email'];
      picture = json['picture'];
      nicename = json['nicename'];
      userUrl = json['url'];
      isSocial = json['isSocial'];
    } catch (e) {
      print(e.toString());
    }
  }

  // from Create User
  User.fromAuthUser(Map<String, dynamic> json, String _cookie) {
    try {
      cookie = _cookie;
      id = json['id'].toString();
      name = json['displayname'];
      username = json['username'];
      firstName = json['firstname'];
      lastName = json['lastname'];
      email = json['email'];
      picture = json['avatar'];
      nicename = json['nicename'];
      userUrl = json['url'];
      loggedIn = true;
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  String toString() => 'User { username: $id $name $email}';
}

class UserPoints {
  int points;
  List<UserEvent> events = [];

  UserPoints.fromJson(Map<String, dynamic> json) {
    points = json['points_balance'];

    if (json['events'] != null) {
      for (var event in json['events']) {
        events.add(UserEvent.fromJson(event));
      }
    }
  }
}

class UserEvent {
  String id;
  String userId;
  String orderId;
  String date;
  String description;
  String points;

  UserEvent.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    orderId = json['order_id'];
    date = json['date_display_human'];
    description = json['description'];
    points = json['points'];
  }
}
