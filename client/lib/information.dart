// ignore_for_file: import_of_legacy_library_into_null_safe

import 'package:ally_4_u_client/report.user.dart';
import 'package:ally_4_u_client/screens/chat/chat.page.dart';
import 'package:ally_4_u_client/screens/chat/matches.dart';
import 'package:ally_4_u_client/screens/profile/edit.profile.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:provider/provider.dart';
import 'package:swipe_stack_null_safe/swipe_stack_null_safe.dart';

import 'models/user.model.dart';

class Info extends StatelessWidget {
  final User currentUser;
  final User user;
  final bool? isNotification;
  final GlobalKey<SwipeStackState>? swipeKey;

  const Info({
    super.key,
    required this.user,
    required this.currentUser,
    this.isNotification,
    this.swipeKey,
  });

  @override
  Widget build(BuildContext context) {
    bool isMe = user.id == currentUser.id;
    bool isMatched = swipeKey == null;
    bool? notification = isNotification;

    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        body: Container(
          decoration: BoxDecoration(
            color: notifier.darkTheme ? darkBackground : primaryColor,
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 500,
                      width: MediaQuery.of(context).size.width,
                      child: user.imageUrl != null && user.imageUrl!.isNotEmpty
                          ? CardSwiper(
                              key: UniqueKey(),
                              cardBuilder: (BuildContext context, int index2, int i, int i2) {
                                return Hero(
                                  tag: "abc",
                                  child: CachedNetworkImage(
                                    imageUrl: user.imageUrl![0] ?? '',
                                    fit: BoxFit.cover,
                                    useOldImageOnUrlChange: false,
                                    placeholder: (context, url) => const CupertinoActivityIndicator(
                                      radius: 20,
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                  ),
                                );
                              },
                              cardsCount: user.imageUrl?.length ?? 0,
                              numberOfCardsDisplayed: 1,
                              // pagination: SwiperPagination(
                              //   alignment: Alignment.bottomCenter,
                              //   builder: DotSwiperPaginationBuilder(
                              //     activeSize: 13,
                              //     color: secondryColor,
                              //     activeColor: accentColor,
                              //   ),
                              // ),
                              // control: SwiperControl(
                              //   color: accentColor,
                              //   disableColor: secondryColor,
                              // ),
                              // loop: false,
                            )
                          : const SizedBox.shrink(),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        color: notifier.darkTheme ? darkBackground : primaryColor,
                        child: Column(
                          children: [
                            ListTile(
                              subtitle: Text(user.address),
                              title: Text(
                                "${user.name}, ${user.editInfo!['showMyAge'] != null ? !user.editInfo!['showMyAge'] ? user.age : "" : user.age}",
                                style: TextStyle(
                                  color: notifier.darkTheme ? lightText : Colors.black,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              trailing: FloatingActionButton(
                                backgroundColor: notifier.darkTheme ? darkText : primaryColor,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Icon(
                                  Icons.arrow_downward,
                                  color: accentColor,
                                ),
                              ),
                            ),
                            user.editInfo!['job_title'] != null
                                ? ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.work,
                                      color: accentColor,
                                    ),
                                    title: Text(
                                      "${user.editInfo!['job_title']}${user.editInfo!['company'] != null ? ' at ${user.editInfo!['company']}' : ''}",
                                      style: TextStyle(
                                        color: secondryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : Container(),
                            user.editInfo!['university'] != null
                                ? ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.stars,
                                      color: accentColor,
                                    ),
                                    title: Text(
                                      "${user.editInfo!['university']}",
                                      style: TextStyle(
                                        color: secondryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : Container(),
                            user.editInfo!['living_in'] != null
                                ? ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.home,
                                      color: accentColor,
                                    ),
                                    title: Text(
                                      "Living in ${user.editInfo!['living_in']}",
                                      style: TextStyle(
                                        color: secondryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : Container(),
                            !isMe
                                ? ListTile(
                                    dense: true,
                                    leading: Icon(
                                      Icons.location_on,
                                      color: accentColor,
                                    ),
                                    title: Text(
                                      user.editInfo!['DistanceVisible'] != null
                                          ? user.editInfo!['DistanceVisible']
                                              ? 'Less than ${user.distanceBW} KM away'
                                              : 'Distance not visible'
                                          : 'Less than ${user.distanceBW} KM away',
                                      style: TextStyle(
                                        color: secondryColor,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                : Container(),
                            const Divider(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    user.editInfo!['about'] != null
                        ? Text(
                            "${user.editInfo!['about']}",
                            style: TextStyle(
                              color: secondryColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          )
                        : Container(),
                    const SizedBox(
                      height: 20,
                    ),
                    user.editInfo!['about'] != null ? const Divider() : Container(),
                    !isMe
                        ? InkWell(
                            onTap: () => showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (context) => ReportUser(
                                currentUser: currentUser,
                                seconduser: user,
                              ),
                            ),
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: Center(
                                child: Text(
                                  "REPORT ${user.name}".toUpperCase(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: secondryColor,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    !isMe ? const Divider() : Container(),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              ),
              !isMatched
                  ? Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            FloatingActionButton(
                              heroTag: UniqueKey(),
                              backgroundColor: notifier.darkTheme ? darkText : primaryColor,
                              child: const Icon(
                                Icons.clear,
                                color: Colors.red,
                                size: 30,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                // swipeKey.currentState.swipeLeft();
                              },
                            ),
                            FloatingActionButton(
                              heroTag: UniqueKey(),
                              backgroundColor: notifier.darkTheme ? darkText : primaryColor,
                              child: const Icon(
                                Icons.favorite,
                                color: Colors.lightBlueAccent,
                                size: 30,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                // swipeKey.currentState.swipeRight();
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : notification != null && notification
                      ? Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                FloatingActionButton(
                                  heroTag: UniqueKey(),
                                  backgroundColor: notifier.darkTheme ? darkText : primaryColor,
                                  child: const Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await FirebaseFirestore.instance.collection("Users").doc(currentUser.id).collection("CheckedUser").doc(user.id).set(
                                      {
                                        'DislikedUser': user.id,
                                        'timestamp': DateTime.now(),
                                      },
                                    );
                                  },
                                ),
                                FloatingActionButton(
                                  heroTag: UniqueKey(),
                                  backgroundColor: notifier.darkTheme ? darkText : primaryColor,
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.lightBlueAccent,
                                    size: 30,
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
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
                                                    "It's a match\n With ${user.name}",
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
                                    await FirebaseFirestore.instance.collection("Users").doc(currentUser.id).collection("Matches").doc(user.id).set(
                                      {
                                        'Matches': user.id,
                                        'isRead': false,
                                        'userName': user.name,
                                        'pictureUrl': user.imageUrl![0],
                                        'timestamp': FieldValue.serverTimestamp()
                                      },
                                    );
                                    await FirebaseFirestore.instance.collection("Users").doc(user.id).collection("Matches").doc(currentUser.id).set(
                                      {
                                        'Matches': currentUser.id,
                                        'userName': currentUser.name,
                                        'pictureUrl': currentUser.imageUrl![0],
                                        'isRead': false,
                                        'timestamp': FieldValue.serverTimestamp()
                                      },
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        )
                      : isMe
                          ? Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FloatingActionButton(
                                  backgroundColor: notifier.darkTheme ? darkText : primaryColor,
                                  child: Icon(
                                    Icons.edit,
                                    color: accentColor,
                                  ),
                                  onPressed: () => Navigator.pushReplacement(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => EditProfile(
                                        currentUser: user,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: FloatingActionButton(
                                  backgroundColor: notifier.darkTheme ? darkText : primaryColor,
                                  child: Icon(
                                    Icons.message,
                                    color: accentColor,
                                  ),
                                  onPressed: () => Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => ChatPage(
                                        sender: currentUser,
                                        second: user,
                                        chatId: chatId(
                                          user,
                                          currentUser,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
            ],
          ),
        ),
      ),
    );
  }
}
