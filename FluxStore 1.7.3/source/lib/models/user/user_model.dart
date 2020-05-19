import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:localstorage/localstorage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../common/constants.dart';
import '../../services/index.dart';
import 'user.dart';

export 'user.dart';

class UserModel with ChangeNotifier {
  UserModel() {
    getUser();
  }

  final Services _service = Services();
  User user;
  bool loggedIn = false;
  bool loading = false;
  final _auth = FirebaseAuth.instance;
  final _database = FirebaseDatabase.instance.reference();

  void updateUser(Map<String, dynamic> json) {
    user.name = json['display_name'];
    user.email = json['user_email'];
    user.userUrl = json['user_url'];
    user.nicename = json['user_nicename'];
    notifyListeners();
  }

  Future<String> submitForgotPassword(
      {String forgotPwLink, Map<String, dynamic> data}) async {
    return await _service.submitForgotPassword(
        forgotPwLink: forgotPwLink, data: data);
  }

  /// Login by apple
  Future<void> loginApple({Function success, Function fail}) async {
    try {
      final AuthorizationResult result = await AppleSignIn.performRequests([
        AppleIdRequest(requestedScopes: [Scope.email, Scope.fullName])
      ]);

      switch (result.status) {
        case AuthorizationStatus.authorized:
          {
            final userId = result.credential.user.replaceAll(".", "");
            if (result.credential.email != null) {
              final fullName = result.credential.fullName.givenName +
                  " " +
                  result.credential.fullName.familyName;
              user = await _service.loginApple(
                  email: result.credential.email, fullName: fullName);
              await _database.child(userId).set(
                  {"email": result.credential.email, "fullName": fullName});
            } else {
              DataSnapshot snapshot = await _database.child(userId).once();
              Map item = snapshot.value;
              user = await _service.loginApple(
                  email: item["email"], fullName: item["fullName"]);
            }
            loggedIn = true;
            await saveUser(user);
            success(user);

            notifyListeners();
          }
          break;

        case AuthorizationStatus.error:
        case AuthorizationStatus.cancelled:
      }
    } catch (err) {
      fail(
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString());
    }
  }

  /// Login by Firebase phone
  Future<void> loginFirebaseSMS({
    String phoneNumber,
    Function success,
    Function fail,
  }) async {
    try {
      user = await _service.loginSMS(token: phoneNumber);
      loggedIn = true;
      await saveUser(user);
      success(user);

      notifyListeners();
    } catch (err) {
      fail(
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString());
    }
  }

  /// Login by Facebook
  Future<void> loginFB({Function success, Function fail}) async {
    try {
      final FacebookLoginResult result =
          await FacebookLogin().logIn(['email', 'public_profile']);

      switch (result.status) {
        case FacebookLoginStatus.loggedIn:
          final FacebookAccessToken accessToken = result.accessToken;
          AuthCredential credential = FacebookAuthProvider.getCredential(
              accessToken: accessToken.token);
          await _auth.signInWithCredential(credential);
          user = await _service.loginFacebook(token: accessToken.token);

          loggedIn = true;

          await saveUser(user);

          success(user);
          break;
        case FacebookLoginStatus.cancelledByUser:
          fail('The login is cancel');
          break;
        case FacebookLoginStatus.error:
          fail('Error: ${result.errorMessage}');
          break;
      }

      notifyListeners();
    } catch (err) {
      fail(
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString());
    }
  }

  Future<void> loginGoogle({Function success, Function fail}) async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn(
        scopes: [
          'email',
        ],
      );
      GoogleSignInAccount res = await _googleSignIn.signIn();
      GoogleSignInAuthentication auth = await res.authentication;
      user = await _service.loginGoogle(token: auth.accessToken);
      loggedIn = true;
      await saveUser(user);
      success(user);
      notifyListeners();
    } catch (err) {
      fail(
          "There is an issue with the app during request the data, please contact admin for fixing the issues " +
              err.toString());
    }
  }

  Future<void> saveUser(User user) async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      // save to Preference
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('loggedIn', true);

      // save the user Info as local storage
      final ready = await storage.ready;
      if (ready) {
        await storage.setItem(kLocalKey["userInfo"], user);
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> getUser() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;

      if (ready) {
        final json = storage.getItem(kLocalKey["userInfo"]);
        if (json != null) {
          user = User.fromLocalJson(json);
          loggedIn = true;
          notifyListeners();
        }
      }
    } catch (err) {
      print(err);
    }
  }

  Future<void> createUser({
    username,
    password,
    firstName,
    lastName,
    Function success,
    Function fail,
  }) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.createUser(
        firstName: firstName,
        lastName: lastName,
        username: username,
        password: password,
      );
      loggedIn = true;
      await saveUser(user);
      success(user);

      loading = false;
      notifyListeners();
    } catch (err) {
      fail(err.toString());
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    user = null;
    loggedIn = false;
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        await storage.deleteItem(kLocalKey["userInfo"]);
        await storage.deleteItem(kLocalKey["shippingAddress"]);
        await storage.deleteItem(kLocalKey["recentSearches"]);
        await storage.deleteItem(kLocalKey["opencart_cookie"]);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('loggedIn', false);
      }
      await _service.logout();
    } catch (err) {
      print(err);
    }
    notifyListeners();
  }

  Future<void> login(
      {username, password, Function success, Function fail}) async {
    try {
      loading = true;
      notifyListeners();
      user = await _service.login(
        username: username,
        password: password,
      );

      loggedIn = true;
      await saveUser(user);
      success(user);
      loading = false;
      notifyListeners();
    } catch (err) {
      loading = false;
      fail(err.toString());
      notifyListeners();
    }
  }

  Future<bool> isLogin() async {
    final LocalStorage storage = LocalStorage("fstore");
    try {
      final ready = await storage.ready;
      if (ready) {
        final json = storage.getItem(kLocalKey["userInfo"]);
        return json != null;
      }
      return false;
    } catch (err) {
      return false;
    }
  }
}
