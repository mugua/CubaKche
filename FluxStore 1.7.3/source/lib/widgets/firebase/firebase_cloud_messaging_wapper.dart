import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

abstract class FirebaseCloudMessagagingAbs {
  init ();
  FirebaseCloudMessagingDelegate delegate; 
}

abstract class FirebaseCloudMessagingDelegate {
  onMessage (Map<String, dynamic> message);
  onResume (Map<String, dynamic> message);
  onLaunch (Map<String, dynamic> message);
}

class FirebaseCloudMessagagingWapper extends FirebaseCloudMessagagingAbs {
  FirebaseMessaging _firebaseMessaging;

  @override
  init() {
    _firebaseMessaging = FirebaseMessaging();
    firebaseCloudMessagingListeners();
  }
  void firebaseCloudMessagingListeners() {
    if (Platform.isIOS) iOSPermission();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) => delegate?.onMessage(message),
      onResume: (Map<String, dynamic> message) => delegate?.onResume(message),
      onLaunch: (Map<String, dynamic> message) => delegate?.onLaunch(message),
    );
  }

  void iOSPermission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {});
  }

}