// ignore_for_file: use_build_context_synchronously

import 'package:ally_4_u_client/search.location.dart';
import 'package:ally_4_u_client/tab.dart';
import 'package:ally_4_u_client/update.location.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'util/color.dart';
import 'util/theme.dart';
//import 'package:geolocator/geolocator.dart';

class AllowLocation extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AllowLocation(this.userData, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 50),
                child: FloatingActionButton(
                  heroTag: UniqueKey(),
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
              Padding(
                padding: const EdgeInsets.only(
                  top: 20,
                  right: 25,
                ),
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 5000),
                  child: SizedBox(
                    height: 42,
                    child: FloatingActionButton.extended(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 10,
                      heroTag: UniqueKey(),
                      backgroundColor: notifier.darkTheme ? darkText : Colors.white,
                      onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => SearchLocation(userData),
                        ),
                      ),
                      label: Text(
                        "Skip..",
                        style: TextStyle(
                          color: accentColor,
                        ),
                      ),
                      icon: Icon(
                        Icons.navigate_next,
                        color: accentColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: CircleAvatar(
                          backgroundColor: secondryColor.withOpacity(.2),
                          radius: 110,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 90,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 0),
                        child: RichText(
                          text: TextSpan(
                            text: "Enable location",
                            style: TextStyle(
                              color: notifier.darkTheme ? lightText : Colors.black,
                              fontSize: 40,
                            ),
                            children: [
                              TextSpan(
                                text: """\nYou'll need to provide a
location
in order to search users around you.
                              """,
                                style: TextStyle(fontWeight: FontWeight.w400, color: secondryColor, textBaseline: TextBaseline.alphabetic, fontSize: 18),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        )),
                    const Padding(
                      padding: EdgeInsets.all(50.0),
                      // child: FlatButton.icon(
                      //     onPressed: null,
                      //     icon: Icon(Icons.arrow_drop_down),
                      //     label: Text("Show more")),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 40.0),
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
                            "ALLOW LOCATION",
                            style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      onTap: () async {
                        var currentLocation = await getLocationCoordinates();
                        userData.addAll(
                          {
                            'location': {
                              'latitude': currentLocation!['latitude'],
                              'longitude': currentLocation['longitude'],
                              'address': currentLocation['PlaceName'],
                            },
                            'maximum_distance': 20,
                            'age_range': {
                              'min': "20",
                              'max': "50",
                            },
                          },
                        );
                        showWelcomDialog(context);
                        setUserData(userData);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future setUserData(Map<String, dynamic> userData) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).set(userData, SetOptions(merge: true));
  }
}

Future showWelcomDialog(context) async {
  showDialog(
    barrierDismissible: false,
    context: context,
    builder: (_) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pop(context);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const Tabbar(),
          ),
        );
      });
      return Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) => Center(
          child: Container(
            width: 150.0,
            height: 100.0,
            decoration: BoxDecoration(
              color: notifier.darkTheme ? darkText : Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Image.asset(
                  "asset/auth/verified.png",
                  height: 60,
                ),
                Text(
                  "You're in",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    decoration: TextDecoration.none,
                    color: notifier.darkTheme ? lightText : Colors.black,
                    fontSize: 20,
                  ),
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
