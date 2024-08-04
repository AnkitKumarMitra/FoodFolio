import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:foodfolio/homepage.dart';
import 'package:foodfolio/loginpage.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late SharedPreferences ? logindata;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initial();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white30,
        body: Center(
            child: Lottie.asset(
          'assets/lottie/splash.json',
        )));
  }

  Future<void> initial() async {
    logindata = await SharedPreferences.getInstance();
    bool isLogin = logindata!.getBool('isLogin') ?? false;
    Timer(
      const Duration(seconds: 3),
      () {
        if (isLogin) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const HomePage(),
              ));
        } else {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ));
        }
      },
    );
  }
}
