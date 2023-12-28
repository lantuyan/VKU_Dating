import 'package:ally_4_u_client/user.dob.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'util/color.dart';
import 'util/theme.dart';

class UserName extends StatefulWidget {
  const UserName({super.key});

  @override
  State<UserName> createState() => _UserNameState();
}

class _UserNameState extends State<UserName> {
  Map<String, dynamic> userData = {}; //user personal info
  String username = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        floatingActionButton: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 50),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: FloatingActionButton(
              elevation: 10,
              backgroundColor: accentColor,
              onPressed: () {
                Navigator.pop(context);
              },
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 50, top: 120),
                      child: Text(
                        "My first\nname is",
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 23),
                    decoration: InputDecoration(
                      hintText: "Enter your first name",
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: accentColor,
                        ),
                      ),
                      helperText: "This is how it will appear in App.",
                      helperStyle: TextStyle(
                        color: secondryColor,
                        fontSize: 15,
                      ),
                    ),
                    onChanged: (value) {
                      setState(
                        () {
                          username = value;
                        },
                      );
                    },
                  ),
                ),
                username.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    accentColor.withOpacity(.5),
                                    accentColor.withOpacity(.8),
                                    accentColor,
                                    accentColor
                                  ],
                                ),
                              ),
                              height: MediaQuery.of(context).size.height * .065,
                              width: MediaQuery.of(context).size.width * .75,
                              child: Center(
                                child: Text(
                                  "CONTINUE",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              userData.addAll({'UserName': username});
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => UserDOB(userData),
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(25),
                              ),
                              height: MediaQuery.of(context).size.height * .065,
                              width: MediaQuery.of(context).size.width * .75,
                              child: Center(
                                child: Text(
                                  "CONTINUE",
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: secondryColor,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onTap: () {},
                          ),
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
