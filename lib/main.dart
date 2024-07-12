import 'package:farm_orchard_management_dashboard/pages/home_page.dart';
import 'package:farm_orchard_management_dashboard/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main(List<String> args) async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> getLoggedInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool("logged") ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getLoggedInfo(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            bool isLoggedIn = snapshot.data as bool;
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              initialRoute: isLoggedIn ? HomePage.id : LoginPage.id,
              routes: {
                HomePage.id: (context) => HomePage(),
                LoginPage.id: (context) => LoginPage()
              },
            );
          } else {
            return CircularProgressIndicator();
          }
        });
  }
}
