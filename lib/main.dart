import 'package:dogre/screens/login_signup/login.dart';
import 'package:dogre/screens/login_signup/splash.dart';
import 'package:dogre/service/constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AwesomeNotifications().initialize(
      'assets/images/logo_notification.png',
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic channel',
            channelDescription: 'channelDescription')
      ],
      debug: true);
  await Supabase.initialize(
    url: API_URL,
    anonKey: API_KEY,
  );
  runApp(MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          appBarTheme: AppBarTheme(
              titleTextStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 25,
                  fontWeight: FontWeight.w500)),
          cardTheme: CardTheme(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)))),
      home: SplashScreen(),
    );
  }
}
