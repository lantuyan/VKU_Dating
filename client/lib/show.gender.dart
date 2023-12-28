import 'package:ally_4_u_client/univercity.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/snackbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'util/theme.dart';

class ShowGender extends StatefulWidget {
  final Map<String, dynamic> userData;
  const ShowGender(this.userData, {super.key});

  @override
  State<ShowGender> createState() => _ShowGenderState();
}

class _ShowGenderState extends State<ShowGender> {
  bool man = false;
  bool woman = false;
  bool eyeryone = false;
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
              padding: EdgeInsets.only(left: 50, top: 120),
              child: Text(
                "Show me",
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      side: BorderSide(
                        width: 1,
                        color: man ? accentColor : secondryColor,
                      ),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                        child: Text(
                          "MEN",
                          style: TextStyle(fontSize: 20, color: man ? accentColor : secondryColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(
                        () {
                          woman = false;
                          man = true;
                          eyeryone = false;
                        },
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        side: BorderSide(
                          width: 1,
                          color: woman ? accentColor : secondryColor,
                        ),
                      ),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * .065,
                        width: MediaQuery.of(context).size.width * .75,
                        child: Center(
                          child: Text(
                            "WOMEN",
                            style: TextStyle(fontSize: 20, color: woman ? accentColor : secondryColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(
                          () {
                            woman = true;
                            man = false;
                            eyeryone = false;
                          },
                        );
                        // Navigator.push(
                        //     context, CupertinoPageRoute(builder: (context) => OTP()));
                      },
                    ),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      side: BorderSide(
                        width: 1,
                        color: eyeryone ? accentColor : secondryColor,
                      ),
                    ),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                        child: Text(
                          "EVERYONE",
                          style: TextStyle(
                            fontSize: 20,
                            color: eyeryone ? accentColor : secondryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    onPressed: () {
                      setState(
                        () {
                          woman = false;
                          man = false;
                          eyeryone = true;
                        },
                      );
                      // Navigator.push(
                      //     context, CupertinoPageRoute(builder: (context) => OTP()));
                    },
                  ),
                ],
              ),
            ),
            man || woman || eyeryone
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
                          if (man) {
                            widget.userData.addAll({'showGender': "man"});
                          } else if (woman) {
                            widget.userData.addAll({'showGender': "woman"});
                          } else {
                            widget.userData.addAll({'showGender': "everyone"});
                          }
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => University(widget.userData),
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
                          CustomSnackbar.snackbar(
                            "Please select one",
                            context,
                          );
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
