// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:developer';

import 'package:ally_4_u_client/models/user.model.dart' as u;
import 'package:ally_4_u_client/screens/profile/update.number.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../update.location.dart';
import '../auth/login.dart';

class Settings extends StatefulWidget {
  final u.User currentUser;
  final bool isPurchased;
  final Map items;

  const Settings({
    super.key,
    required this.currentUser,
    required this.isPurchased,
    required this.items,
  });

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  Map<String, dynamic> changeValues = {};

  RangeValues? ageRange;
  var _showMe;
  int? distance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void dispose() {
    super.dispose();

    if (changeValues.isNotEmpty) {
      updateData();
    }
  }

  Future updateData() async {
    FirebaseFirestore.instance.collection("Users").doc(widget.currentUser.id).set(changeValues, SetOptions(merge: true));
  }

  int? freeR;
  int? paidR;

  @override
  void initState() {
    super.initState();
    freeR = widget.items['free_radius'] != null ? int.parse(widget.items['free_radius']) : 400;
    paidR = widget.items['paid_radius'] != null ? int.parse(widget.items['paid_radius']) : 400;
    setState(
      () {
        if (!widget.isPurchased && widget.currentUser.maxDistance! > freeR!) {
          widget.currentUser.maxDistance = freeR?.round();
          changeValues.addAll({'maximum_distance': freeR?.round()});
        } else if (widget.isPurchased && widget.currentUser.maxDistance! >= paidR!) {
          widget.currentUser.maxDistance = paidR?.round();
          changeValues.addAll({'maximum_distance': paidR?.round()});
        }
        _showMe = widget.currentUser.showGender;
        distance = widget.currentUser.maxDistance?.round();
        ageRange = RangeValues(double.parse(widget.currentUser.ageRange!['min']), (double.parse(widget.currentUser.ageRange!['max'])));
        log(ageRange.toString());
      },
    );
  }

  _setUserOfline() async {
    User? user = _auth.currentUser;
    FirebaseFirestore.instance.collection("Users").doc(user?.uid).get().then((value) {
      if (value.get('userState') != null) {
        FirebaseFirestore.instance.collection("Users").doc(user?.uid).update(
          {
            "userState": {
              "online": false,
              "lastSeen": FieldValue.serverTimestamp(),
            },
          },
        ).then((_) {});
      } else {
        FirebaseFirestore.instance.collection("Users").doc(user?.uid).update(
          {
            "userState": {
              "online": false,
              "lastSeen": FieldValue.serverTimestamp(),
            },
          },
        ).then((_) {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        appBar: AppBar(
          title: Text(
            "Settings",
            style: TextStyle(
              color: notifier.darkTheme ? lightText : mediumText,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: notifier.darkTheme ? lightText : mediumText,
            onPressed: () => Navigator.pop(context),
          ),
          elevation: 0,
          backgroundColor: notifier.darkTheme ? darkBackground : primaryColor,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: notifier.darkTheme ? darkBackground : primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    "Account settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ListTile(
                  title: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: InkWell(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Phone Number"),
                            Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                              ),
                              child: Text(
                                widget.currentUser.phoneNumber != null ? "${widget.currentUser.phoneNumber}" : "Verify Now",
                                style: TextStyle(color: secondryColor),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: secondryColor,
                              size: 15,
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => UpdateNumber(currentUser: widget.currentUser),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  subtitle: const Text("Verify a phone number to secure your account"),
                ),
                const Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    "Discovery settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Card(
                    child: ExpansionTile(
                      key: UniqueKey(),
                      leading: const Text(
                        "Current location : ",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      title: Text(
                        widget.currentUser.address,
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.blue,
                                size: 25,
                              ),
                              InkWell(
                                child: const Text(
                                  "Change location",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onTap: () async {
                                  var address = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const UpdateLocation(),
                                    ),
                                  );
                                  if (address != null) {
                                    _updateAddress(address);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    left: 15,
                  ),
                  child: Text(
                    "Change your location to see members in other city",
                    style: TextStyle(
                      color: notifier.darkTheme ? lightText : darkText,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Show me",
                            style: TextStyle(
                              fontSize: 18,
                              color: accentColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          ListTile(
                            title: DropdownButton(
                              iconEnabledColor: accentColor,
                              iconDisabledColor: secondryColor,
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  value: "man",
                                  child: Text("Man"),
                                ),
                                DropdownMenuItem(
                                  value: "woman",
                                  child: Text("Woman"),
                                ),
                                DropdownMenuItem(
                                  value: "everyone",
                                  child: Text("Everyone"),
                                ),
                              ],
                              onChanged: (val) {
                                changeValues.addAll(
                                  {
                                    'showGender': val,
                                  },
                                );
                                setState(
                                  () {
                                    _showMe = val;
                                  },
                                );
                              },
                              value: _showMe,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          "Maximum distance",
                          style: TextStyle(
                            fontSize: 18,
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Text(
                          "$distance Km.",
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: Slider(
                          value: distance!.toDouble(),
                          inactiveColor: secondryColor,
                          min: 1.0,
                          max: widget.isPurchased ? paidR!.toDouble() : freeR!.toDouble(),
                          activeColor: accentColor,
                          onChanged: (val) {
                            changeValues.addAll(
                              {'maximum_distance': val.round()},
                            );
                            setState(
                              () {
                                distance = val.round();
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(
                          "Age range",
                          style: TextStyle(
                            fontSize: 18,
                            color: accentColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        trailing: Text(
                          "${ageRange!.start.round()}-${ageRange!.end.round()}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        subtitle: RangeSlider(
                          inactiveColor: secondryColor,
                          values: ageRange!,
                          min: ageRange!.start,
                          max: 100.0,
                          divisions: 25,
                          activeColor: accentColor,
                          labels: RangeLabels('${ageRange!.start.round()}', '${ageRange!.end.round()}'),
                          onChanged: (val) {
                            changeValues.addAll(
                              {
                                'age_range': {'min': '${val.start.truncate()}', 'max': '${val.end.truncate()}'}
                              },
                            );
                            setState(
                              () {
                                ageRange = val;
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: const Text(
                    "App settings",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Notifications",
                              style: TextStyle(
                                fontSize: 18,
                                color: accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Push notifications"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                ListTile(
                  title: Text(
                    "Choose App Theme",
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: notifier.darkTheme ? lightText : Colors.black87,
                    ),
                  ),
                  subtitle: Card(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text("Dark Mode"),
                            ),
                            Switch(
                              activeColor: accentColor,
                              value: notifier.darkTheme,
                              onChanged: (val) {
                                notifier.toggleTheme();
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(
                          child: Text(
                            "Invite your friends",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Share.share(
                        'check out my website your firebase dynamic link',
                        subject: 'Look what I made!',
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: const Card(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(18.0),
                          child: Text(
                            "Logout",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content: const Text('Do you want to logout your account?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  _setUserOfline();
                                  await _auth.signOut().whenComplete(
                                    () {
                                      _firebaseMessaging.deleteToken();
                                      Navigator.pushReplacement(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => const Login(),
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Center(
                          child: Text(
                            "Delete Account",
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Account'),
                            content: const Text('Do you want to delete your account?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final user = _auth.currentUser;
                                  await _deleteUser(user!).then(
                                    (_) async {
                                      await _auth.signOut().whenComplete(
                                        () {
                                          Navigator.pushReplacement(
                                            context,
                                            CupertinoPageRoute(
                                              builder: (context) => const Login(),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: SizedBox(
                      height: 50,
                      width: 100,
                      child: notifier.darkTheme
                          ? Image.asset(
                              "asset/Logo.png",
                              fit: BoxFit.contain,
                            )
                          : Image.asset(
                              "asset/Logo.png",
                              fit: BoxFit.contain,
                            ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 80,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateAddress(Map address) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return Container(
          color: Colors.white,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * .4,
          child: Column(
            children: [
              Material(
                child: ListTile(
                  title: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'New address:',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.cancel,
                      color: Colors.black26,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  subtitle: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        address['PlaceName'] ?? '',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                child: Text(
                  "Confirm",
                  style: TextStyle(color: primaryColor),
                ),
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection("Users")
                      .doc(widget.currentUser.id)
                      .update(
                        {
                          'location': {'latitude': address['latitude'], 'longitude': address['longitude'], 'address': address['PlaceName']},
                        },
                      )
                      .whenComplete(
                        () => showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) {
                            Future.delayed(
                              const Duration(seconds: 3),
                              () {
                                setState(
                                  () {
                                    widget.currentUser.address = address['PlaceName'];
                                  },
                                );

                                Navigator.pop(context);
                              },
                            );
                            return Consumer<ThemeNotifier>(
                              builder: (context, ThemeNotifier notifier, child) => Center(
                                child: Container(
                                  width: 160.0,
                                  height: 120.0,
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
                                        // color: accentColor,
                                        // colorBlendMode: BlendMode.color,
                                      ),
                                      Text(
                                        "location\nchanged",
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
                        ),
                      )
                      .catchError(
                        (e) {},
                      );

                  // .then((_) {
                  //   Navigator.pop(context);
                  // });
                },
              )
            ],
          ),
        );
      },
    );
  }

  Future _deleteUser(User user) async {
    await FirebaseFirestore.instance.collection("Users").doc(user.uid).delete();
  }
}
