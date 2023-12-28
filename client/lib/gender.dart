import 'package:ally_4_u_client/sexual.orentation.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'util/theme.dart';

class Gender extends StatefulWidget {
  final Map<String, dynamic> userData;

  const Gender(this.userData, {super.key});

  @override
  State<Gender> createState() => _GenderState();
}

class _GenderState extends State<Gender> {
  bool man = false;
  bool woman = false;
  bool other = false;
  bool select = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        key: _scaffoldKey,
        floatingActionButton: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 50),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: FloatingActionButton(
              elevation: 10,
              backgroundColor: accentColor,
              onPressed: () {
                dispose();
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
        body: Stack(
          children: [
            const Padding(
              padding: EdgeInsets.only(
                left: 50,
                top: 120,
              ),
              child: Text(
                "I am a",
                style: TextStyle(fontSize: 40),
              ),
            ),
            Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(width: 1, style: BorderStyle.solid, color: man ? accentColor : secondryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: () {
                      setState(
                        () {
                          woman = false;
                          man = true;
                          other = false;
                        },
                      );
                    },
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                        child: Text(
                          "MAN",
                          style: TextStyle(fontSize: 20, color: man ? accentColor : secondryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: woman ? accentColor : secondryColor,
                          width: 1,
                          style: BorderStyle.solid,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      onPressed: () {
                        setState(
                          () {
                            woman = true;
                            man = false;
                            other = false;
                          },
                        );
                        // Navigator.push(
                        //     context, CupertinoPageRoute(builder: (context) => OTP()));
                      },
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .065,
                        width: MediaQuery.of(context).size.width * .75,
                        child: Center(
                          child: Text(
                            "WOMAN",
                            style: TextStyle(fontSize: 20, color: woman ? accentColor : secondryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        width: 1,
                        style: BorderStyle.solid,
                        color: other ? accentColor : secondryColor,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                        child: Text(
                          "OTHER",
                          style: TextStyle(fontSize: 20, color: other ? accentColor : secondryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(
                        () {
                          woman = false;
                          man = false;
                          other = true;
                        },
                      );
                      // Navigator.push(
                      //     context, CupertinoPageRoute(builder: (context) => OTP()));
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 100.0, left: 10),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ListTile(
                  leading: Checkbox(
                    activeColor: accentColor,
                    value: select,
                    onChanged: (bool? newValue) {
                      setState(() {
                        select = newValue!;
                      });
                    },
                  ),
                  title: const Text("Show my gender on my profile"),
                ),
              ),
            ),
            man || woman || other
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
                              colors: [accentColor.withOpacity(.5), accentColor.withOpacity(.8), accentColor, accentColor],
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
                          Map<String, Object> userGender;
                          if (man) {
                            userGender = {'userGender': "man", 'showOnProfile': select};
                          } else if (woman) {
                            userGender = {'userGender': "woman", 'showOnProfile': select};
                          } else {
                            userGender = {'userGender': "other", 'showOnProfile': select};
                          }
                          widget.userData.addAll(userGender);
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => SexualOrientation(widget.userData),
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
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        onTap: () {
                          CustomSnackbar.snackbar("Please select one", context);
                        },
                      ),
                    ),
                  )
          ],
        ),
      ),
    );
  }
}
