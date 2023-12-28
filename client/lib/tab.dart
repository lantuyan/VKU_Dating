import 'dart:async';
import 'dart:io';
import 'dart:math' hide log;

import 'package:ally_4_u_client/models/user.model.dart' as u;
import 'package:ally_4_u_client/screens/chat/home.screen.dart';
import 'package:ally_4_u_client/screens/profile/profile.dart';
import 'package:ally_4_u_client/splash.dart';
import 'package:ally_4_u_client/util/snackbar.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'block.user.by.admin.dart';
import 'home.dart';
import 'notifications.dart';
import 'screens/calling/incoming.call.dart';

List likedByList = [];

class Tabbar extends StatefulWidget {
  final bool? isPaymentSuccess;
  final String? plan;

  const Tabbar({super.key, this.isPaymentSuccess, this.plan});

  @override
  TabbarState createState() => TabbarState();
}

//_
class TabbarState extends State<Tabbar> with WidgetsBindingObserver {
  CollectionReference docRef = FirebaseFirestore.instance.collection('Users');
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  u.User? currentUser;
  List<u.User> matches = [];
  List<u.User> newmatches = [];

  List<u.User> users = [];

  int activeIndex = 0;

  final InAppPurchase _iap = InAppPurchase.instance;

  /// Past purchases
  List<PurchaseDetails> purchases = [];
  bool isPuchased = false;

  @override
  void initState() {
    super.initState();
    // Show payment success alert.
    // set  online
    _setUserOnline();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isPaymentSuccess != null && widget.isPaymentSuccess!) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Alert(
          context: context,
          type: AlertType.success,
          title: "Confirmation",
          desc: "You have successfully subscribed to our ${widget.plan} plan.",
          buttons: [
            DialogButton(
              onPressed: () => Navigator.pop(context),
              width: 120,
              child: const Text(
                "Ok",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )
          ],
        ).show();
      });
    }
    _getAccessItems();
    _getCurrentUser();
    _getMatches();
    _getpastPurchases();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        _setUserOnline();
        break;
      case AppLifecycleState.inactive:
        _setUserOfline();
        break;
      case AppLifecycleState.paused:
        _setUserOfline();
        break;
      case AppLifecycleState.detached:
        _setUserOfline();
        break;
      case AppLifecycleState.hidden:
        _setUserOfline();
        break;
    }
  }

  _setUserOnline() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      docRef.doc(user.uid).get().then((value) {
        final data = value.data() as Map<String, dynamic>;
        if (data.containsKey('userState')) {
          docRef.doc(user.uid).update(
            {
              "userState": {
                "online": true,
                "lastSeen": FieldValue.serverTimestamp(),
              },
            },
          ).then((_) {});
        } else {
          docRef.doc(user.uid).update(
            {
              "userState": {
                "online": true,
                "lastSeen": FieldValue.serverTimestamp(),
              },
            },
          ).then((_) {});
        }
      });
    }
  }

  _setUserOfline() async {
    User? user = _firebaseAuth.currentUser;
    if (user != null) {
      docRef.doc(user.uid).get().then((value) {
        if (value.get('userState') != null) {
          docRef.doc(user.uid).update(
            {
              "userState": {
                "online": false,
                "lastSeen": FieldValue.serverTimestamp(),
              },
            },
          ).then((_) {});
        } else {
          docRef.doc(user.uid).update(
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
  }

  Map<String, dynamic> items = {};

  _getAccessItems() async {
    FirebaseFirestore.instance.collection("Packages").snapshots().listen((doc) {
      // log(doc.docs.toString(), name: 'Packages_log');
      if (doc.docs.isNotEmpty) {
        items = doc.docs[0].data();
      }

      if (mounted) setState(() {});
    });
  }

  Future<void> _getpastPurchases() async {
    Stream<List<PurchaseDetails>> response = _iap.purchaseStream;
    response.listen((details) async {
      for (PurchaseDetails purchase in details) {
        await _iap.completePurchase(purchase);
        purchases.add(purchase);
        if (mounted) setState(() {});
      }
    });
    for (var purchase in purchases) {
      await _verifyPuchase(purchase.productID);
    }
  }

  PurchaseDetails? _hasPurchased(String productId) {
    if (purchases.any((purchase) => purchase.productID == productId)) {
      return purchases.firstWhere((purchase) => purchase.productID == productId);
    }
    return null;
  }

  ///verifying pourchase of user
  Future _verifyPuchase(String id) async {
    PurchaseDetails? purchase = _hasPurchased(id);

    if (purchase != null && purchase.status == PurchaseStatus.purchased) {
      if (Platform.isIOS) {
        await _iap.completePurchase(purchase);
        isPuchased = true;
      }
      isPuchased = true;
    } else {
      isPuchased = false;
    }
  }

  int swipecount = 0;

  _getSwipedcount() {
    FirebaseFirestore.instance
        .collection('/Users/${currentUser?.id}/CheckedUser')
        .where(
          'timestamp',
          isGreaterThan: Timestamp.now().toDate().subtract(const Duration(days: 1)),
        )
        .snapshots()
        .listen((event) {
      setState(() {
        swipecount = event.docs.length;
      });
    });
  }

  configurePushNotification(u.User userModel) async {
    await _firebaseMessaging.requestPermission(
      alert: true,
      sound: true,
      provisional: true,
      badge: true,
    );

    _firebaseMessaging.getToken().then(
      (token) {
        docRef.doc(userModel.id).update(
          {
            'push_token': token,
          },
        );
      },
    );

    FirebaseMessaging.onMessage.listen(
      (RemoteMessage message) async {
        debugPrint(message.data.toString());
        if (Platform.isIOS && message.data['type'] == 'Call') {
          Map callInfo = {};
          callInfo['channel_id'] = message.data['channel_id'];
          callInfo['senderName'] = message.data['senderName'];
          callInfo['senderPicture'] = message.data['senderPicture'];
          List<bool> isCalling = await _checkCallState(message.data['channel_id']);
          if (isCalling.where((element) => element != false).isNotEmpty) {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Incoming(message.data),
              ),
            );
          }
        } else if (Platform.isAndroid && message.data['type'] == 'Call') {
          List<bool> isCalling = await _checkCallState(message.data['channel_id']);
          if (isCalling.where((element) => element != false).isNotEmpty) {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Incoming(message.data),
              ),
            );
          }
        }
      },
    );

    FirebaseMessaging.onMessageOpenedApp.listen(
      (RemoteMessage message) async {
        if (Platform.isIOS && message.data['type'] == 'Call') {
          Map callInfo = {};
          callInfo['channel_id'] = message.data['channel_id'];
          callInfo['senderName'] = message.data['senderName'];
          callInfo['senderPicture'] = message.data['senderPicture'];
          List<bool> isCalling = await _checkCallState(message.data['channel_id']);
          if (isCalling.where((element) => element != false).isNotEmpty) {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Incoming(message.data),
              ),
            );
          }
        } else if (Platform.isAndroid && message.data['type'] == 'Call') {
          List<bool> isCalling = await _checkCallState(message.data['channel_id']);
          if (isCalling.where((element) => element != false).isNotEmpty) {
            if (!mounted) return;
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Incoming(message.data),
              ),
            );
          }
        }
      },
    );
  }

  Future<List<bool>> _checkCallState(channelId) async {
    List<bool> values = await FirebaseFirestore.instance.collection("calls").doc(channelId).get().then((value) {
      List<bool> list = [];
      list.add(value.get("calling") ?? false);
      list.add(value.get("response") == 'Awaiting');
      return list;
    });
    return values;
  }

  _getMatches() async {
    User? user = _firebaseAuth.currentUser;
    return FirebaseFirestore.instance.collection('/Users/${user?.uid}/Matches').orderBy('timestamp', descending: true).snapshots().listen(
      (ondata) async {
        matches.clear();
        newmatches.clear();
        if (ondata.docs.isNotEmpty) {
          for (var f in ondata.docs) {
            DocumentSnapshot doc = await docRef.doc(f.get('Matches')).get();
            if (doc.exists) {
              u.User tempuser = u.User.fromDocument(doc);
              tempuser.distanceBW = calculateDistance(currentUser?.coordinates!['latitude'], currentUser?.coordinates!['longitude'],
                      tempuser.coordinates!['latitude'], tempuser.coordinates!['longitude'])
                  .round();

              matches.add(tempuser);
              newmatches.add(tempuser);
              if (mounted) setState(() {});
            }
          }
        }
      },
    );
  }

  _getCurrentUser() async {
    User? user = _firebaseAuth.currentUser;
    return docRef.doc("${user?.uid}").snapshots().listen(
      (data) async {
        currentUser = u.User.fromDocument(data);
        if (mounted) setState(() {});
        users.clear();
        userRemoved.clear();
        getUserList();
        getLikedByList();
        configurePushNotification(currentUser!);
        if (!isPuchased) {
          _getSwipedcount();
        }
      },
    );
  }

  query() {
    if (currentUser?.showGender == 'everyone') {
      return docRef
          .where(
            'age',
            isGreaterThanOrEqualTo: int.parse(currentUser?.ageRange!['min']),
          )
          .where('age', isLessThanOrEqualTo: int.parse(currentUser?.ageRange!['max']))
          .orderBy(
            'age',
            descending: false,
          );
    } else {
      return docRef
          .where('editInfo.userGender', isEqualTo: currentUser?.showGender)
          .where(
            'age',
            isGreaterThanOrEqualTo: int.parse(
              currentUser?.ageRange!['min'],
            ),
          )
          .where(
            'age',
            isLessThanOrEqualTo: int.parse(
              currentUser?.ageRange!['max'],
            ),
          )
          .where(
            'sexualOrientation.orientation',
            arrayContainsAny: currentUser?.sexualOrientation,
          )
          .orderBy(
            'age',
            descending: false,
          );
    }
  }

  Future getUserList() async {
    List checkedUser = [];
    FirebaseFirestore.instance.collection('/Users/${currentUser?.id}/CheckedUser').get().then((data) {
      checkedUser.addAll(data.docs.map((f) => f.data().toString().contains('DislikedUser') ? f.get('DislikedUser') : ''));
      checkedUser.addAll(data.docs.map((f) => f.data().toString().contains('LikedUser') ? f.get('LikedUser') : ''));
    }).then((_) {
      query().get().then((data) async {
        // log(data.docs.length.toString(), name: 'user_length_log');
        if (data.docs.length < 1) {
          return;
        }
        users.clear();
        userRemoved.clear();
        for (var doc in data.docs) {
          u.User temp = u.User.fromDocument(doc);
          var distance = calculateDistance(
              currentUser?.coordinates!['latitude'], currentUser?.coordinates!['longitude'], temp.coordinates!['latitude'], temp.coordinates!['longitude']);
          temp.distanceBW = distance.round();
          if (checkedUser.any(
            (value) => value == temp.id,
          )) {
          } else {
            if (distance <= currentUser!.maxDistance! && temp.id != currentUser?.id && !temp.isBlocked!) {
              users.add(temp);
            }
          }
        }
        if (mounted) setState(() {});
      });
    });
  }

  getLikedByList() {
    docRef.doc(currentUser?.id).collection("LikedBy").snapshots().listen((data) async {
      likedByList.addAll(
        data.docs.map((f) => f['LikedBy']),
      );
    });
  }

  // back to exit scope

  GlobalKey<ScaffoldState> scaffoldState = GlobalKey();
  DateTime? current;

  Future<bool> popped(bool v) {
    DateTime now = DateTime.now();
    if (current == null || now.difference(current!) > const Duration(seconds: 2)) {
      current = now;

      CustomSnackbar.snackbar("Press again to exit", context);
      return Future.value(false);
    } else {
      SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      return Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => PopScope(
        onPopInvoked: (v) => popped(v),
        child: Scaffold(
          key: scaffoldState,
          body: currentUser == null
              ? const Center(
                  child: Splash(),
                )
              : currentUser!.isBlocked!
                  ? const BlockUser()
                  : Scaffold(
                      body: IndexedStack(
                        index: activeIndex,
                        children: [
                          CardPictures(
                            currentUser!,
                            users,
                            swipecount,
                            items,
                          ),
                          Notifications(
                            currentUser!,
                          ),
                          HomeScreen(
                            currentUser: currentUser!,
                            matches: matches,
                            newmatches: newmatches,
                          ),
                          Profile(
                            currentUser: currentUser!,
                            isPuchased: isPuchased,
                            purchases: purchases,
                            items: items,
                          ),
                        ],
                      ),
                      bottomNavigationBar: Container(
                        color: Colors.grey.shade900,
                        width: width,
                        height: height * .07,
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(
                                  () {
                                    activeIndex = 0;
                                  },
                                ),
                                splashFactory: NoSplash.splashFactory,
                                highlightColor: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'asset/home.svg',
                                      colorFilter: ColorFilter.mode(activeIndex == 0 ? const Color(0xffBC1B34) : Colors.white, BlendMode.srcIn),
                                    ),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      margin: const EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        color: activeIndex == 0 ? const Color(0xffBC1B34) : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(
                                  () {
                                    activeIndex = 1;
                                  },
                                ),
                                splashFactory: NoSplash.splashFactory,
                                highlightColor: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'asset/heart.svg',
                                      colorFilter: ColorFilter.mode(activeIndex == 1 ? const Color(0xffBC1B34) : Colors.white, BlendMode.srcIn),
                                    ),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      margin: const EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        color: activeIndex == 1 ? const Color(0xffBC1B34) : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(
                                  () {
                                    activeIndex = 2;
                                  },
                                ),
                                splashFactory: NoSplash.splashFactory,
                                highlightColor: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'asset/chat.svg',
                                      colorFilter: ColorFilter.mode(activeIndex == 2 ? const Color(0xffBC1B34) : Colors.white, BlendMode.srcIn),
                                    ),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      margin: const EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        color: activeIndex == 2 ? const Color(0xffBC1B34) : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => setState(
                                  () {
                                    activeIndex = 3;
                                  },
                                ),
                                splashFactory: NoSplash.splashFactory,
                                highlightColor: Colors.transparent,
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'asset/profile.svg',
                                      colorFilter: ColorFilter.mode(activeIndex == 3 ? const Color(0xffBC1B34) : Colors.white, BlendMode.srcIn),
                                    ),
                                    Container(
                                      width: 3,
                                      height: 3,
                                      margin: const EdgeInsets.only(top: 5),
                                      decoration: BoxDecoration(
                                        color: activeIndex == 3 ? const Color(0xffBC1B34) : Colors.transparent,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
    );
  }
}

double calculateDistance(lat1, lon1, lat2, lon2) {
  var p = 0.017453292519943295;
  var c = cos;
  var a = 0.5 - c((lat2 - lat1) * p) / 2 + c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
  return 12742 * asin(sqrt(a));
}
