//import 'package:onesignal_flutter/onesignal_flutter.dart';
//
//import '../../models/notification.dart';
//import '../../common/config.dart';
//
//
//class OneSignalWapper {
//  init() {
//    OneSignal.shared
//        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
//      print(result.notification.jsonRepresentation().replaceAll("\\n", "\n"));
//    });
//    OneSignal.shared.init(
//      kOneSignalKey['appID'],
//      iOSSettings: {
//        OSiOSSettings.autoPrompt: false,
//        OSiOSSettings.inAppLaunchUrl: true
//      },
//    );
//    OneSignal.shared
//        .setInFocusDisplayType(OSNotificationDisplayType.notification);
//
//    OneSignal.shared
//        .setNotificationReceivedHandler((OSNotification osNotification) {
//      // print(osNotification.payload.body.toString());
//      // print(osNotification.payload.notificationId);
//      FStoreNotification a = FStoreNotification.fromOneSignal(osNotification);
//      a.saveToLocal(
//        osNotification.payload.notificationId != null
//            ? osNotification.payload.notificationId
//            : DateTime.now().toString(),
//      );
//    });
//  }
//}
