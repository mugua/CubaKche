import 'package:after_layout/after_layout.dart';
import 'package:apple_sign_in/apple_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/app.dart';
import '../../models/user/user_model.dart';
import '../../services/config.dart';
import '../../widgets/common/login_animation.dart';
import '../../widgets/common/webview.dart';
import 'forgot_password.dart';
import 'login_sms/index.dart';
import 'registration.dart';

class LoginScreen extends StatefulWidget {
  final bool fromCart;

  LoginScreen({this.fromCart = false});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen>
    with TickerProviderStateMixin, AfterLayoutMixin {
  AnimationController _loginButtonController;
  String username, password;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  var parentContext;
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;
  bool isAvailableApple = false;

  @override
  void initState() {
    super.initState();
    _loginButtonController = AnimationController(
        duration: Duration(milliseconds: 3000), vsync: this);
  }

  @override
  Future<void> afterFirstLayout(BuildContext context) async {
    try {
      isAvailableApple = await AppleSignIn.isAvailable();
      setState(() {});
    } catch (e) {
      printLog('[Login] afterFirstLayout error');
    }
  }

  @override
  void dispose() {
    _loginButtonController.dispose();
    super.dispose();
  }

  Future<Null> _playAnimation() async {
    try {
      setState(() {
        isLoading = true;
      });
      await _loginButtonController.forward();
    } on TickerCanceled {
      printLog('[_playAnimation] error');
    }
  }

  Future<Null> _stopAnimation() async {
    try {
      await _loginButtonController.reverse();
      setState(() {
        isLoading = false;
      });
    } on TickerCanceled {
      printLog('[_stopAnimation] error');
    }
  }

  void _welcomeMessage(user, context) {
    if (widget.fromCart) {
      Navigator.of(context).pop(user);
    } else {
      final snackBar = SnackBar(
        content: Text(S.of(context).welcome + ' ${user.name} !'),
      );
      Scaffold.of(context).showSnackBar(snackBar);
      if (kLayoutWeb) {
        Navigator.of(context).pushReplacementNamed('/home-screen');
      } else {
        Navigator.of(context).pushReplacementNamed('/home');
      }
    }
  }

  void _failMessage(message, context) {
    /// Showing Error messageSnackBarDemo
    /// Ability so close message
    final snackBar = SnackBar(
      content: Text(S.of(context).warning(message)),
      duration: Duration(seconds: 30),
      action: SnackBarAction(
        label: S.of(context).close,
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );

    Scaffold.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  _loginFacebook(context) async {
    //showLoading();
    await _playAnimation();
    await Provider.of<UserModel>(context, listen: false).loginFB(
      success: (user) {
        //hideLoading();
        _stopAnimation();
        _welcomeMessage(user, context);
      },
      fail: (message) {
        //hideLoading();
        _stopAnimation();
        _failMessage(message, context);
      },
    );
  }

  _loginApple(context) async {
    await _playAnimation();
    await Provider.of<UserModel>(context, listen: false).loginApple(
      success: (user) {
        _stopAnimation();
        _welcomeMessage(user, context);
      },
      fail: (message) {
        _stopAnimation();
        _failMessage(message, context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    parentContext = context;
    final appModel = Provider.of<AppModel>(context);
    final screenSize = MediaQuery.of(context).size;

    String forgetPasswordUrl = Config().forgetPassword;

    Future launchForgetPassworddWebView(String url) async {
      await Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              WebView(url: url, title: S.of(context).resetPassword),
          fullscreenDialog: true,
        ),
      );
    }

    void launchForgetPasswordURL(String url) async {
      if (url != null) {
        /// show as webview
        await launchForgetPassworddWebView(url);
      } else {
        /// show as native
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ForgotPassword()),
        );
      }
    }

    _login(context) async {
      if (username == null || password == null) {
        var snackBar = SnackBar(content: Text(S.of(context).pleaseInput));
        Scaffold.of(context).showSnackBar(snackBar);
      } else {
        await _playAnimation();
        await Provider.of<UserModel>(context, listen: false).login(
          username: username.trim(),
          password: password.trim(),
          success: (user) {
            _stopAnimation();
            _welcomeMessage(user, context);
            _auth
                .signInWithEmailAndPassword(
              email: username,
              password: password,
            )
                .catchError(
              (onError) {
                if (onError.code == 'ERROR_USER_NOT_FOUND') {
                  _auth
                      .createUserWithEmailAndPassword(
                    email: username,
                    password: password,
                  )
                      .then((_) {
                    _auth.signInWithEmailAndPassword(
                      email: username,
                      password: password,
                    );
                  });
                }
              },
            );
          },
          fail: (message) {
            _stopAnimation();
            _failMessage(message, context);
          },
        );
      }
    }

    _loginSMS(context) async {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginSMS()),
      );
    }

    _loginGoogle(context) async {
      await _playAnimation();
      await Provider.of<UserModel>(context, listen: false).loginGoogle(
        success: (user) {
          //hideLoading();
          _stopAnimation();
          _welcomeMessage(user, context);
        },
        fail: (message) {
          //hideLoading();
          _stopAnimation();
          _failMessage(message, context);
        },
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                })
            : Container(),
        backgroundColor: Theme.of(context).backgroundColor,
        elevation: 0.0,
      ),
      body: SafeArea(
        child: Builder(
          builder: (context) => GestureDetector(
            onTap: () => Utils.hideKeyboard(context),
            child: Stack(
              children: [
                ListenableProvider.value(
                  value: Provider.of<UserModel>(context),
                  child: Consumer<UserModel>(builder: (context, model, child) {
                    return SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Container(
                        alignment: Alignment.center,
                        width: screenSize.width /
                            (2 / (screenSize.height / screenSize.width)),
                        constraints: BoxConstraints(maxWidth: 700),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 80.0),
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Container(
                                        height: 40.0,
                                        child: Image.asset(
                                          kLogo,
                                        )),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 80.0),
                            TextField(
                                controller: _usernameController,
                                onChanged: (value) => username = value,
                                decoration: InputDecoration(
                                  labelText: S.of(parentContext).username,
                                )),
                            const SizedBox(height: 12.0),
                            Stack(children: <Widget>[
                              TextField(
                                onChanged: (value) => password = value,
                                obscureText: true,
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: S.of(parentContext).password,
                                ),
                              ),
                              Positioned(
                                right: appModel.locale == "ar" ? null : 4,
                                left: appModel.locale == "ar" ? 4 : null,
                                bottom: 20,
                                child: GestureDetector(
                                  child: Text(
                                    " " + S.of(context).reset,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  onTap: () {
                                    launchForgetPasswordURL(forgetPasswordUrl);
                                  },
                                ),
                              )
                            ]),
                            SizedBox(
                              height: 50.0,
                            ),
                            StaggerAnimation(
                              titleButton: S.of(context).signInWithEmail,
                              buttonController: _loginButtonController.view,
                              onTap: () {
                                if (!isLoading) {
                                  _login(context);
                                }
                              },
                            ),
                            Stack(
                              alignment: AlignmentDirectional.center,
                              children: <Widget>[
                                SizedBox(
                                    height: 50.0,
                                    width: 200.0,
                                    child:
                                        Divider(color: Colors.grey.shade300)),
                                Container(
                                    height: 30,
                                    width: 40,
                                    color: Theme.of(context).backgroundColor),
                                if (kLoginSetting['showFacebook'] ||
                                    kLoginSetting['showSMSLogin'] ||
                                    kLoginSetting['showGoogleLogin'] ||
                                    kLoginSetting['showAppleLogin'])
                                  Text(
                                    S.of(context).or,
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade400),
                                  )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                if (kLoginSetting['showAppleLogin'] &&
                                    isAvailableApple)
                                  InkWell(
                                    onTap: () => _loginApple(context),
                                    child: Container(
                                      child: Icon(
                                        FontAwesomeIcons.apple,
                                        color: Colors.white,
                                        size: 24.0,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                if (kLoginSetting['showFacebook'])
                                  InkWell(
                                    onTap: () => _loginFacebook(context),
                                    child: Container(
                                      child: Icon(
                                        FontAwesomeIcons.facebookF,
                                        color: Colors.white,
                                        size: 24.0,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Color(0xFF4267B2),
                                      ),
                                    ),
                                  ),
                                if (kLoginSetting['showGoogleLogin'])
                                  InkWell(
                                    onTap: () => _loginGoogle(context),
                                    child: Container(
                                      child: Icon(
                                        FontAwesomeIcons.google,
                                        color: Colors.white,
                                        size: 24.0,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Color(0xFFEA4336),
                                      ),
                                    ),
                                  ),
                                if (kLoginSetting['showSMSLogin'])
                                  InkWell(
                                    onTap: () => _loginSMS(context),
                                    child: Container(
                                      child: Icon(
                                        FontAwesomeIcons.sms,
                                        color: Colors.white,
                                        size: 24.0,
                                      ),
                                      padding: EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: Colors.lightBlue,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Text(S.of(context).dontHaveAccount),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                RegistrationScreen(),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        " ${S.of(context).signup}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showLoading() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
            child: Container(
          padding: EdgeInsets.all(50.0),
          child: kLoadingWidget(context),
        ));
      },
    );
  }

  void hideLoading() {
    Navigator.of(context).pop();
  }
}

class PrimaryColorOverride extends StatelessWidget {
  const PrimaryColorOverride({Key key, this.color, this.child})
      : super(key: key);

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Theme(
      child: child,
      data: Theme.of(context).copyWith(primaryColor: color),
    );
  }
}
