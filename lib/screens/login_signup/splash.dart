import 'dart:async';

import 'package:dogre/main.dart';
import 'package:dogre/screens/home_screens/home.dart';
import 'package:dogre/screens/login_signup/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  startTimer() {
    var duration = const Duration(seconds: 3);
    return Timer(duration, route);
  }

  route() {
    final session = supabase.auth.currentSession;
    if (session != null) {
      Get.offAll(HomeScreen());
    } else {
      Get.offAll(LoginScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: Center(child: Lottie.asset('lib/assets/images/splash.json')),
    );
  }
}
