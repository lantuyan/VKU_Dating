import 'package:allt_4_u_admin/firebase_options.dart';
import 'package:allt_4_u_admin/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/users_list.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuthorized = false;

  @override
  void initState() {
    _checkAuth();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xff1f1f1f),
        primaryColor: Color(0xffff3a5a),
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: isAuthorized ? Users() : LoginPage(),
    );
  }

  // create default id password

  Future _setIdPass() async {
    await FirebaseFirestore.instance.collection("Admin").doc("id_password").get().then(
      (value) async {
        if (!value.exists) {
          await FirebaseFirestore.instance
              .collection("Admin")
              .doc("id_password")
              .set({"id": "admin", "password": "admin"});
        }
      },
    );
  }

// Check user logged in
  void _checkAuth() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    bool? isAuth = sharedPrefs.getBool("isAuth") != null ? sharedPrefs.getBool("isAuth") : false;

    print(isAuth);
    if (isAuth != null && isAuth) {
      setState(
        () {
          isAuthorized = true;
        },
      );
    } else {
      print('asfasfcas');
      _setIdPass();
    }
  }
}
