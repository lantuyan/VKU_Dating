import 'package:allt_4_u_admin/screens/users_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController id = new TextEditingController();
  TextEditingController passwd = new TextEditingController();
  bool isLoading = false;
  bool showPass = false;
  bool isLargeScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (MediaQuery.of(context).size.width > 600) {
            isLargeScreen = true;
          } else {
            isLargeScreen = false;
          }
          return Center(
            child: Container(
              width: isLargeScreen ? MediaQuery.of(context).size.width * .5 : MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Login",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.only(
                      left: 30,
                      right: 30,
                      top: 30,
                    ),
                    elevation: 11,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(40),
                      ),
                    ),
                    child: TextField(
                      cursorColor: Theme.of(context).primaryColor,
                      controller: id,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.white24,
                        ),
                        suffixIcon: Icon(
                          Icons.check_circle,
                          color: Colors.white24,
                        ),
                        hintText: "Username",
                        hintStyle: TextStyle(
                          color: Colors.white24,
                        ),
                        filled: true,
                        fillColor: Color(0xff333333),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(
                            Radius.circular(40.0),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.only(
                      left: 30,
                      right: 30,
                      top: 20,
                    ),
                    elevation: 11,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(40),
                      ),
                    ),
                    child: TextField(
                      cursorColor: Theme.of(context).primaryColor,
                      controller: passwd,
                      obscureText: !showPass,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white24,
                        ),
                        hintText: "Password",
                        hintStyle: TextStyle(
                          color: Colors.white24,
                        ),
                        filled: true,
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye),
                          color: showPass ? Theme.of(context).primaryColor : Colors.white24,
                          onPressed: () {
                            setState(
                              () {
                                showPass = !showPass;
                              },
                            );
                          },
                        ),
                        fillColor: Color(0xff333333),
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.all(
                            Radius.circular(40.0),
                          ),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(30.0),
                    child: isLoading
                        ? CupertinoActivityIndicator(
                            radius: 16,
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () async {
                              bool isValid = await auth(id.text, passwd.text);
                              snackbar(
                                  isValid ? "Logged in Successfully..." : "Incorrect Username or Password!", context);
                              if (isValid) {
                                final sharedPrefs = await SharedPreferences.getInstance();
                                sharedPrefs.setBool('isAuth', true);
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => Users(),
                                  ),
                                );
                              }

                              setState(
                                () {
                                  isLoading = false;
                                },
                              );
                            },
                          ),
                  ),
                  // Text("Forgot your password?",
                  //     style: TextStyle(color: Theme.of(context).primaryColor))
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future auth(String id, String paswd) async {
    setState(
      () {
        isLoading = true;
      },
    );
    Map? authData = await FirebaseFirestore.instance.collection("Admin").doc("id_password").get().then(
      (value) {
        return value.data();
      },
    );

    if (authData != null && authData['id'] == id && authData['password'] == paswd) {
      return true;
    }
    return false;
  }
}

snackbar(String text, BuildContext context) {
  final snackBar = SnackBar(
    backgroundColor: Color(0xffff3a5a),
    content: Text('$text '),
    duration: Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
