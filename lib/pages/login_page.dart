import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../componenets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  static const String id = "login-page";
  bool? checked = false;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  GlobalKey<FormState> formKey = new GlobalKey();
  String? username;
  String? password;

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    TextEditingController userNameController = new TextEditingController();
    TextEditingController passwordController = new TextEditingController();

    return Form(
      key: formKey,
      child: Scaffold(
        body: Row(
          children: [
            SizedBox(
                width: width * 0.4,
                height: height,
                child: Image.asset(
                  "assets/images/login_background.jpg",
                  fit: BoxFit.fill,
                )),
            Container(
              width: width * 0.6,
              height: height,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(15.0),
                      child: Text(
                        "Welcome back! Please login to your account.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.15, vertical: 15),
                      child: CustomTextField(
                        hint: "Username",
                        onClick: (value) {
                          username = value as String;
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: width * 0.15, vertical: 15),
                      child: CustomTextField(
                        hint: "Password",
                        onClick: (value) {
                          password = value as String;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(25),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                  checkColor: Colors.white,
                                  activeColor: Colors.black,
                                  value: widget.checked,
                                  onChanged: (value) {
                                    setState(() {
                                      widget.checked = value;
                                    });
                                  }),
                              Text("Remember me")
                            ],
                          ),
                          Text("Forget Password")
                        ],
                      ),
                    ),
                    Container(
                        width: width * 0.29,
                        height: height * 0.08,
                        child: ElevatedButton(
                          onPressed: () {
                            _validate(context);
                          },
                          child: Text("Login"),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromARGB(255, 67, 66, 93)),
                        ))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String _hashPassword(String password) {
    var bytes = utf8.encode(password); // encode the password as UTF-8
    var digest = sha256.convert(bytes); // hash the bytes using SHA-256
    return digest.toString();
  }

  _validate(BuildContext context) async {
    if (formKey.currentState?.validate() ?? true) {
      formKey.currentState?.save();
      final conn = await Connection.open(
        Endpoint(
          host: 'localhost',
          database: 'farm_orchard_management_dashboard',
          username: 'postgres',
          password: '12345678',
        ),
        settings: ConnectionSettings(sslMode: SslMode.disable),
      );
      final result = await conn.execute(
        'SELECT username,password,id FROM users where username = \'$username\'',
      );
      String encPassword = _hashPassword(password as String);
      if (result.isNotEmpty) {
        if (encPassword != result[0][1]) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Wrong password")));
        } else {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          var id = result[0][2];
          prefs.setString("user", id.toString());
          prefs.setString("username", username.toString());
          if (widget.checked == true) {
            prefs.setBool("logged", true);
          }
          Navigator.of(context).pushReplacementNamed('home-page');
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Username not found")));
      }
    }
  }
}
