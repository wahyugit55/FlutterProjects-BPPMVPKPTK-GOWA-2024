import 'package:akademik_app/Page/app_splash.dart';
import 'package:akademik_app/Page/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Page/akun_login.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? tokenJwt = prefs.getString('tokenJwt');
    if (tokenJwt != null) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 3), () {
        return checkLoginStatus();
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const AppSplash();
        } else {
          if (snapshot.data == false) {
            return const GetMaterialApp(
              title: 'Akun Login',
              debugShowCheckedModeBanner: false,
              home: AkunLogin(),
            );
          } else {
            return const GetMaterialApp(
              title: 'Dashboard',
              debugShowCheckedModeBanner: false,
              home: DashboardScreen(),
            );
          }
        }
      },
    );
  }
}
