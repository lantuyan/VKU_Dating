// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:math' hide log;
import 'dart:ui';

import 'package:ally_4_u_client/screens/payments/subscription.dart';
import 'package:ally_4_u_client/tab.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:appinio_swiper/appinio_swiper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'information.dart';
import 'models/user.model.dart';

List userRemoved = [];
int countswipe = 1;

class CardPictures extends StatefulWidget {
  final List<User> users;
  final User currentUser;
  final int swipedcount;
  final Map<String, dynamic> items;

  const CardPictures(this.currentUser, this.users, this.swipedcount, this.items, {super.key});

  @override
  State<CardPictures> createState() => _CardPicturesState();
}

class _CardPicturesState extends State<CardPictures> with AutomaticKeepAliveClientMixin {
  // TabbarState state = TabbarState();
  bool onEnd = false;

  // GlobalKey<SwipeStackState> swipeKey = GlobalKey<SwipeStackState>();
  final AppinioSwiperController _swiperController = AppinioSwiperController();

  AppinioSwiperDirection? direction;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    int freeSwipe = widget.items['free_swipes'] != null ? int.parse(widget.items['free_swipes']) : 20;
    bool exceedSwipes = widget.swipedcount >= freeSwipe;
    final width = MediaQuery.of(context).size.width;
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        body: Container(
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: notifier.darkTheme ? darkBackground : primaryColor,
          ),
          child: onEnd || widget.users.isEmpty
              ? Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: secondryColor,
                          radius: 40,
                        ),
                      ),
                      Text(
                        "There's no one new around you.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondryColor,
                          decoration: TextDecoration.none,
                          fontSize: 18,
                        ),
                      )
                    ],
                  ),
                )
              : AbsorbPointer(
                  absorbing: exceedSwipes,
                  child: Stack(
                    children: [
                      AppinioSwiper(
                        controller: _swiperController,
                        cardsCount: widget.users.length,
                        onSwiping: (AppinioSwiperDirection d) {
                          setState(() {
                            direction = d;
                          });
                        },
                        onSwipe: (int index, AppinioSwiperDirection direction) async {
                          int i = (index - 1);
                          CollectionReference docRef = FirebaseFirestore.instance.collection("Users");
                          if (direction == AppinioSwiperDirection.left) {
                            await docRef.doc(widget.currentUser.id).collection("CheckedUser").doc(widget.users[i].id).set(
                              {
                                'DislikedUser': widget.users[i].id,
                                'timestamp': DateTime.now(),
                              },
                            );

                            if (i < widget.users.length) {
                              userRemoved.clear();
                              setState(
                                () {
                                  userRemoved.add(widget.users[i]);
                                  widget.users.removeAt(i);
                                },
                              );
                            }
                          } else if (direction == AppinioSwiperDirection.right) {
                            if (likedByList.contains(widget.users[i].id)) {
                              showDialog(
                                context: context,
                                builder: (ctx) {
                                  Future.delayed(
                                    const Duration(milliseconds: 1700),
                                    () {
                                      Navigator.pop(ctx);
                                    },
                                  );
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 80),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Card(
                                        child: SizedBox(
                                          height: 100,
                                          width: 300,
                                          child: Center(
                                            child: Text(
                                              "It's a match\n With ${widget.users[i].name}",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 30,
                                                decoration: TextDecoration.none,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                              await docRef.doc(widget.currentUser.id).collection("Matches").doc(widget.users[i].id).set(
                                {
                                  'Matches': widget.users[i].id,
                                  'isRead': false,
                                  'userName': widget.users[i].name,
                                  'pictureUrl': widget.users[i].imageUrl![0],
                                  'timestamp': FieldValue.serverTimestamp()
                                },
                              );
                              await docRef.doc(widget.users[i].id).collection("Matches").doc(widget.currentUser.id).set(
                                {
                                  'Matches': widget.currentUser.id,
                                  'userName': widget.currentUser.name,
                                  'pictureUrl': widget.currentUser.imageUrl![0],
                                  'isRead': false,
                                  'timestamp': FieldValue.serverTimestamp()
                                },
                              );
                            }

                            await docRef.doc(widget.currentUser.id).collection("CheckedUser").doc(widget.users[i].id).set(
                              {
                                'LikedUser': widget.users[i].id,
                                'timestamp': FieldValue.serverTimestamp(),
                              },
                            );
                            await docRef.doc(widget.users[i].id).collection("LikedBy").doc(widget.currentUser.id).set(
                              {
                                'LikedBy': widget.currentUser.id,
                                'userName': widget.currentUser.name,
                                'pictureUrl': widget.currentUser.imageUrl![0],
                                'isRead': false,
                                'timestamp': FieldValue.serverTimestamp()
                              },
                            );
                            if (i < widget.users.length) {
                              userRemoved.clear();
                              setState(
                                () {
                                  userRemoved.add(widget.users[i]);
                                  widget.users.removeAt(i);
                                },
                              );
                            }
                          }
                        },
                        backgroundCardsCount: 0,
                        cardsBuilder: (BuildContext context, int index) {
                          User u = widget.users[index];
                          return InkWell(
                            onTap: () {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  return Info(
                                    user: u,
                                    currentUser: widget.currentUser,
                                  );
                                },
                              );
                            },
                            child: Stack(
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 20,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                    color: const Color(0xff333333),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 9,
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white,
                                            image: DecorationImage(
                                              image: NetworkImage(u.imageUrl?.first ?? ''),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    '${u.name}, ${u.age}',
                                                    style: const TextStyle(
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 7),
                                                  const Icon(Icons.verified_rounded),
                                                ],
                                              ),
                                              const SizedBox(height: 5),
                                              Row(
                                                mainAxisSize: MainAxisSize.max,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.place_rounded,
                                                    size: 12,
                                                    color: Colors.white.withOpacity(0.8),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    '${calculateDistance(widget.currentUser.coordinates?['latitude'], widget.currentUser.coordinates?['longitude'], u.coordinates?['latitude'], u.coordinates?['longitude']).toInt()} km away',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.white.withOpacity(0.8),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: 0,
                                  child: Align(
                                    child: InkWell(
                                      onTap: () {
                                        _swiperController.swipeRight();
                                      },
                                      child: Container(
                                        width: width * .15,
                                        height: width * .15,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: const BorderRadius.horizontal(
                                            right: Radius.circular(20),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: const Color(0xff333333).withOpacity(0.7),
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  right: 0,
                                  child: Align(
                                    child: InkWell(
                                      onTap: () {
                                        _swiperController.swipeLeft();
                                      },
                                      child: Container(
                                        width: width * .15,
                                        height: width * .15,
                                        decoration: BoxDecoration(
                                          color: const Color(0xffD4192C),
                                          borderRadius: const BorderRadius.horizontal(
                                            left: Radius.circular(20),
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.1),
                                              blurRadius: 20,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        alignment: Alignment.center,
                                        child: const Icon(
                                          Icons.favorite_rounded,
                                          color: Colors.white,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(48.0),
                                  child: direction != null && direction == AppinioSwiperDirection.left
                                      ? Align(
                                          alignment: Alignment.topRight,
                                          child: Transform.rotate(
                                            angle: pi / 8,
                                            child: Container(
                                              height: 40,
                                              width: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                border: Border.all(
                                                  width: 2,
                                                  color: Colors.red,
                                                ),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  "NOPE",
                                                  style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 32,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      : direction != null && direction == AppinioSwiperDirection.right
                                          ? Align(
                                              alignment: Alignment.topLeft,
                                              child: Transform.rotate(
                                                angle: -pi / 8,
                                                child: Container(
                                                  height: 40,
                                                  width: 100,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.rectangle,
                                                    border: Border.all(
                                                      width: 2,
                                                      color: Colors.lightBlueAccent,
                                                    ),
                                                  ),
                                                  child: const Center(
                                                    child: Text(
                                                      "LIKE",
                                                      style: TextStyle(
                                                        color: Colors.lightBlueAccent,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 32,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      exceedSwipes
                          ? Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.2),
                                    child: Dialog(
                                      insetAnimationCurve: Curves.bounceInOut,
                                      insetAnimationDuration: const Duration(seconds: 2),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      backgroundColor: Colors.white,
                                      child: SizedBox(
                                        height: MediaQuery.of(context).size.height * .55,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              size: 50,
                                              color: accentColor,
                                            ),
                                            const Text(
                                              "you have already used the maximum number of free available swipes for 24 hrs.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey,
                                                fontSize: 20,
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Icon(
                                                Icons.lock_outline,
                                                size: 120,
                                                color: accentColor,
                                              ),
                                            ),
                                            Text(
                                              "For swipe more users just subscribe our premium plans.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: accentColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Subscription(
                                      items: widget.items,
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
