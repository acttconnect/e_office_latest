import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'Auth/splash_screen.dart';
import 'Screens/dummmy.dart';
import 'Screens/notification_screen.dart';
import 'firebase_api.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Flutter Local Notifications Plugin
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
  InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) async {
      if (response.payload != null) {
        navigatorKey.currentState?.pushNamed(
          NotificationScreen.route,
          arguments: {
            'data': response.payload,  // Pass the payload as data
          },
        );
      }
    },
  );

  await FirebaseApi().initNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home:  SplashScreen(),
      navigatorKey: navigatorKey,
      routes: {
        NotificationScreen.route: (context) => const NotificationScreen(),
      },
    );
  }
}
