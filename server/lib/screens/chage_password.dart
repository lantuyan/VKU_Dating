import 'package:allt_4_u_admin/model/custom.alert.dart';
import 'package:allt_4_u_admin/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChangeIdPassword extends StatefulWidget {
  @override
  _ChangeIdPasswordState createState() => _ChangeIdPasswordState();
}

class _ChangeIdPasswordState extends State<ChangeIdPassword> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController newId = new TextEditingController();
  TextEditingController newPasswd = new TextEditingController();
  bool isLoading = false;
  bool showPass = false;
  bool isLargeScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Change Id or Password"),
      ),
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
                children: [
                  Text(
                    "Change id or password",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22.0,
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
                      controller: newId,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.white24,
                        ),
                        suffixIcon: Icon(
                          Icons.check_circle,
                          color: Colors.white24,
                        ),
                        hintText: "Enter new user-id",
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
                      controller: newPasswd,
                      obscureText: !showPass,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.white24,
                        ),
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
                        hintText: "Enter new password",
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
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(30.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        "Change",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return BeautifulAlertDialog(
                              text: "Do you want to change the id/password ?",
                              onYesTap: () async {
                                await FirebaseFirestore.instance
                                    .collection("Admin")
                                    .doc("id_password")
                                    .set(
                                      {"id": newId.text, "password": newPasswd.text},
                                    )
                                    .whenComplete(
                                      () => snackbar("changed successfully!!", context),
                                    )
                                    .catchError(
                                      (onError) => snackbar(onError, context),
                                    );
                                Navigator.pop(context);
                              },
                              onNoTap: () => Navigator.pop(context),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
