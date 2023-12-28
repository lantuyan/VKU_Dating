// ignore_for_file: prefer_typing_uninitialized_variables

import 'dart:developer';

import 'package:ally_4_u_client/models/user.model.dart' as u;
import 'package:ally_4_u_client/screens/auth/login.dart';
import 'package:ally_4_u_client/screens/auth/my_screen/login_update.dart';
import 'package:ally_4_u_client/screens/profile/update.number.dart';
import 'package:ally_4_u_client/update.location.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:ally_4_u_client/utils/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class SettingsUpdate extends StatefulWidget {
  final u.User currentUser;
  final bool isPurchased;
  final Map items;

  const SettingsUpdate({
    super.key,
    required this.currentUser,
    required this.isPurchased,
    required this.items,
  });

  @override
  State<SettingsUpdate> createState() => _SettingsState();
}

class _SettingsState extends State<SettingsUpdate> {
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
      builder: (context, ThemeNotifier notifier, child) => SafeArea(
        child: Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: notifier.darkTheme ? darkBackground : Colors.grey.shade200,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  appBar(notifier: notifier),
                  Container(
                    height: 10,
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 18),
                    child: Text(
                      "Account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: notifier.darkTheme ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  phoneNumberListTile(
                    notifier: notifier,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      "Discovery settings",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: notifier.darkTheme ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        // color: darkModeColor,
                        color: notifier.darkTheme ? darkModeColor : Colors.white,
                        borderRadius: const BorderRadius.all(
                          Radius.circular(
                            15,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          locationTile(
                            notifier: notifier,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          distanceListTile(
                            themeNotifier: notifier,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          listtileAge(notifier: notifier),
                          listTileShowMe(notifier: notifier),
                          listTileNotification(notifier: notifier),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  returnThemeModeListTile(notifier: notifier),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: InkWell(
                      child: Card(
                        color: blueOtpFieldColor,
                        child: const Padding(
                          padding: EdgeInsets.all(18.0),
                          child: Center(
                            child: Text(
                              "Invite your friends",
                              style: TextStyle(
                                // color: accentColor,
                                color: Colors.white,
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
                  const SizedBox(
                    height: 10,
                  ),
                  Padding(
                    // padding: const EdgeInsets.all(8.0),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: InkWell(
                      child: Card(
                        color: darkPinkColor,
                        child: const Center(
                          child: Padding(
                            padding: EdgeInsets.all(18.0),
                            child: Text(
                              "Logout",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.white,
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
                                            builder: (context) => const LoginUpdate(),
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

  /* ********************/
  // APP BAR
  /* ********************/

  Widget appBar({required ThemeNotifier notifier}) {
    return Container(
      height: 70,
      alignment: Alignment.center,
      width: double.infinity,
      color: darkPinkColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                  alignment: Alignment.centerLeft,
                  // color: Colors.green,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    color: notifier.darkTheme ? lightText : mediumText,
                    onPressed: () => Navigator.pop(context),
                  )),
              const Text(
                "Settings",
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              Container(),
              Container(),
            ],
          ),
        ],
      ),
    );
  }

  /* ********************/
  // PHONE NUMBER LIST TILE
  /* ********************/
  Widget phoneNumberListTile({
    required ThemeNotifier notifier,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        height: Utils.responsiveHeight(context: context, height: 12),
        decoration: BoxDecoration(
          color: notifier.darkTheme ? darkModeColor : Colors.white,
          borderRadius: const BorderRadius.all(
            Radius.circular(
              15,
            ),
          ),
        ),
        child: Center(
          child: ListTile(
            leading: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.green,
              child: CircleAvatar(
                backgroundColor: secondryColor,
                radius: 20.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(90),
                  child: CachedNetworkImage(
                    imageUrl: widget.currentUser.imageUrl![0] ?? '',
                    useOldImageOnUrlChange: true,
                    placeholder: (context, url) => const CupertinoActivityIndicator(
                      radius: 15,
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            title: Text(
              widget.currentUser.name,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              widget.currentUser.phoneNumber != null ? "${widget.currentUser.phoneNumber}" : "Verify Now",
              style: TextStyle(color: secondryColor),
            ),
            trailing: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => UpdateNumber(currentUser: widget.currentUser),
                  ),
                );
              },
              child: Icon(
                Icons.arrow_forward_ios,
                color: secondryColor,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget locationTile({
    required ThemeNotifier notifier,
  }) {
    return ExpansionTile(
      shape: const Border(),
      leading: const Icon(
        Icons.location_on,
        size: 30,
      ),
      title: const Row(
        children: [
          Text(
            "Current location  ",
            style: TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
      subtitle: Text(
        widget.currentUser.address,
        style: TextStyle(
          // color: Colors.blue,
          color: secondryColor,

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
      ],
    );
  }

  Widget listTileShowMe({
    required ThemeNotifier notifier,
  }) {
    return ListTile(
      leading: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: Icon(
            Icons.person,
            size: 25,
            color: notifier.darkTheme ? Colors.grey.shade200 : Colors.black,
          )),
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
    );
  }

  /* ********************/
  // Distance List tile
  /* ********************/
  Widget distanceListTile({
    required ThemeNotifier themeNotifier,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            // flex: 1,

            child: Image.asset(
              "asset/distance.png",
              height: 25,
              color: themeNotifier.darkTheme ? Colors.grey.shade200 : Colors.black,
            ),
          ),
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 0,
                  child: Container(
                    padding: const EdgeInsets.only(left: 15),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Maximum distance",
                      style: TextStyle(
                        fontSize: 14,
                        color: themeNotifier.darkTheme ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Container(
                    // width: ,
                    padding: const EdgeInsets.only(top: 8, left: 8),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        overlayShape: SliderComponentShape.noThumb,
                      ),
                      child: Slider(
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
                )
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "$distance Km.",
              style: const TextStyle(fontSize: 14),
            ),
          )
        ],
      ),
    );
  }

  Widget listtileAge({
    required ThemeNotifier notifier,
  }) {
    return Container(
      padding: const EdgeInsets.only(left: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            // flex: 1,

            child: Image.asset(
              "asset/growth.png",
              height: 25,
              color: notifier.darkTheme ? Colors.grey.shade200 : Colors.black,
            ),
          ),
          Expanded(
            flex: 9,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  flex: 0,
                  child: Container(
                    padding: const EdgeInsets.only(left: 15),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Age between",
                      style: TextStyle(
                        fontSize: 14,
                        color: notifier.darkTheme ? Colors.white : Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 3,
                  child: Container(
                    // width: ,
                    padding: const EdgeInsets.only(top: 0, left: 0),
                    child: RangeSlider(
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
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              "${ageRange!.start.round()}-${ageRange!.end.round()}",
              style: const TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
    );
  }

  // Widget customDivider({
  //   required ThemeNotifier notifier,
  // }) {
  //   return Divider(
  //     thickness: 0.8,
  //     color: notifier.darkTheme ? Colors.white : Colors.grey.shade700,
  //   );
  // }

  Widget listTileNotification({required ThemeNotifier notifier}) {
    return ListTile(
      leading: const Padding(
        padding: EdgeInsets.only(left: 5),
        child: Icon(
          Icons.notification_add_rounded,
          size: 25,
        ),
      ),
      title: Text(
        "Notifications",
        style: TextStyle(
          fontSize: 14,

          color: notifier.darkTheme ? Colors.white : Colors.grey.shade700,
          // color: Colors.grey,

          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text("Push notifications"),
    );
  }

  Widget returnThemeModeListTile({
    required ThemeNotifier notifier,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.symmetric(),
        decoration: BoxDecoration(
          color: notifier.darkTheme ? darkModeColor : Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          leading: Text(
            notifier.darkTheme ? "Dark Mode" : "Light Mode",
            style: TextStyle(
              fontSize: 15,
              color: notifier.darkTheme ? Colors.white : Colors.grey.shade700,
            ),
          ),
          trailing: Switch(
            activeColor: accentColor,
            value: notifier.darkTheme,
            onChanged: (val) {
              notifier.toggleTheme();
            },
          ),
        ),
      ),
    );
  }
}
