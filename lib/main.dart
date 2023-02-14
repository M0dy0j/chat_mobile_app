import 'package:chat_mobile_app_0/screens/chat_screen.dart';
import 'package:chat_mobile_app_0/screens/registration_screen.dart';
import 'package:chat_mobile_app_0/screens/signin_screen.dart';
import 'package:chat_mobile_app_0/screens/welcome_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//firebase
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void getFCM() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print('FCM token $fcmToken');
  }

  @override
  Widget build(BuildContext context) {
    getFCM();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MessageMe app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        Welcome_Screen.screenRoute : (context) => Welcome_Screen(),
        Signin_Screen.screenRoute : (context) => Signin_Screen(),
        Registration_Screen.screenRoute : (context) => Registration_Screen(),
        Chat_Screen.screenRoute : (context) => Chat_Screen(),
      },
      initialRoute: Welcome_Screen.screenRoute,
    );
  }
}
