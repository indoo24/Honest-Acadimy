import 'package:firebase_core/firebase_core.dart';
import 'package:honset_app/core/services/notification_service.dart';

import '../../firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool isConfigured = false;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      isConfigured = true;
      await NotificationService.instance.initialize();
    } on Object {
      isConfigured = false;
    }
  }
}
