import 'dart:ui';

import 'package:ally_4_u_client/tab.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'information.dart';
import 'models/user.model.dart';
import 'util/theme.dart';

class Notifications extends StatefulWidget {
  final User currentUser;

  const Notifications(this.currentUser, {super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  final db = FirebaseFirestore.instance;
  late CollectionReference matchReference;
  late CollectionReference likedReferences;

  @override
  void initState() {
    matchReference = db.collection("Users").doc(widget.currentUser.id).collection('Matches');

    likedReferences = db.collection("Users").doc(widget.currentUser.id).collection("LikedBy");

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, _) => SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Matches',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: notifier.darkTheme ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                    Container(
                      width: width * .11,
                      height: width * .11,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: notifier.darkTheme ? Colors.white.withOpacity(0.5) : Colors.black,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.filter_alt_rounded,
                        color: Color(0xffE94057),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * .01),
                Text(
                  'This is a list of people who have liked you and your matches.',
                  style: TextStyle(
                    fontSize: 12,
                    color: notifier.darkTheme ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(height: height * .02),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Divider(
                      color: notifier.darkTheme ? Colors.white : Colors.grey.shade500,
                    )),
                    const SizedBox(width: 10),
                    const Text('Likes'),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Divider(
                      color: notifier.darkTheme ? Colors.white : Colors.grey.shade500,
                    )),
                  ],
                ),
                SizedBox(height: height * .02),
                StreamBuilder<QuerySnapshot>(
                  stream: likedReferences
                      .orderBy(
                        'timestamp',
                        descending: true,
                      )
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text(
                          "No new likes",
                          style: TextStyle(color: secondryColor, fontSize: 16),
                        ),
                      );
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No new likes",
                          style: TextStyle(color: secondryColor, fontSize: 16),
                        ),
                      );
                    }
                    return GridView.builder(
                      primary: false,
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: (snapshot.data?.docs ?? []).length,
                      itemBuilder: (context, i) {
                        final doc = (snapshot.data?.docs ?? [])[i];
                        // log(doc.data().toString());
                        return InkWell(
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                );
                              },
                            );
                            DocumentSnapshot userdoc = await db.collection("Users").doc(doc.get("LikedBy")).get();
                            if (userdoc.exists) {
                              if (!mounted) return;
                              Navigator.pop(context);
                              User tempuser = User.fromDocument(userdoc);
                              tempuser.distanceBW = calculateDistance(widget.currentUser.coordinates!['latitude'], widget.currentUser.coordinates!['longitude'],
                                      tempuser.coordinates!['latitude'], tempuser.coordinates!['longitude'])
                                  .round();

                              await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  if (!doc.get("isRead")) {
                                    FirebaseFirestore.instance
                                        .collection("/Users/${widget.currentUser.id}/LikedBy")
                                        .doc('${doc.get("LikedBy")}')
                                        .update({'isRead': true});
                                  }
                                  return Info(
                                    user: tempuser,
                                    currentUser: widget.currentUser,
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              image: DecorationImage(
                                image: NetworkImage(doc.get('pictureUrl')),
                                fit: BoxFit.cover,
                              ),
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                                  child: Text(
                                    doc.get('userName'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff333333),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        child: Container(
                                          height: 40,
                                          alignment: Alignment.center,
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                            child: Container(
                                              width: double.infinity,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                border: const Border(
                                                  right: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.clear_rounded),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                        ),
                                        child: Container(
                                          height: 40,
                                          alignment: Alignment.center,
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                            child: Container(
                                              width: double.infinity,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                border: const Border(
                                                  left: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.favorite_rounded),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                SizedBox(height: height * .02),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Divider(
                      color: notifier.darkTheme ? Colors.white : Colors.grey.shade500,
                    )),
                    const SizedBox(width: 10),
                    const Text('Matches'),
                    const SizedBox(width: 10),
                    Expanded(
                        child: Divider(
                      color: notifier.darkTheme ? Colors.white : Colors.grey.shade500,
                    )),
                  ],
                ),
                SizedBox(height: height * .02),
                StreamBuilder<QuerySnapshot>(
                  stream: matchReference
                      .orderBy(
                        'timestamp',
                        descending: true,
                      )
                      .snapshots(),
                  builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Text(
                          "No new matches",
                          style: TextStyle(color: secondryColor, fontSize: 16),
                        ),
                      );
                    } else if (snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          "No new matches",
                          style: TextStyle(color: secondryColor, fontSize: 16),
                        ),
                      );
                    }
                    return GridView.builder(
                      primary: false,
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: (snapshot.data?.docs ?? []).length,
                      itemBuilder: (context, i) {
                        final doc = (snapshot.data?.docs ?? [])[i];
                        // log(doc.data().toString());
                        return InkWell(
                          onTap: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                );
                              },
                            );
                            DocumentSnapshot userdoc = await db.collection("Users").doc(doc.get("Matches")).get();
                            if (userdoc.exists) {
                              if (!mounted) return;
                              Navigator.pop(context);
                              User tempuser = User.fromDocument(userdoc);
                              tempuser.distanceBW = calculateDistance(widget.currentUser.coordinates!['latitude'], widget.currentUser.coordinates!['longitude'],
                                      tempuser.coordinates!['latitude'], tempuser.coordinates!['longitude'])
                                  .round();

                              await showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (context) {
                                  if (!doc.get("isRead")) {
                                    FirebaseFirestore.instance
                                        .collection("/Users/${widget.currentUser.id}/Matches")
                                        .doc('${doc.get("Matches")}')
                                        .update({'isRead': true});
                                  }
                                  return Info(
                                    user: tempuser,
                                    currentUser: widget.currentUser,
                                  );
                                },
                              );
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            height: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              image: DecorationImage(
                                image: NetworkImage(doc.get('pictureUrl')),
                                fit: BoxFit.cover,
                              ),
                            ),
                            alignment: Alignment.bottomCenter,
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 10, bottom: 10),
                                  child: Text(
                                    doc.get('userName'),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xff333333),
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomLeft: Radius.circular(10),
                                        ),
                                        child: Container(
                                          height: 40,
                                          alignment: Alignment.center,
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                            child: Container(
                                              width: double.infinity,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                border: const Border(
                                                  right: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.clear_rounded),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          bottomRight: Radius.circular(10),
                                        ),
                                        child: Container(
                                          height: 40,
                                          alignment: Alignment.center,
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                                            child: Container(
                                              width: double.infinity,
                                              height: 70,
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.1),
                                                border: const Border(
                                                  left: BorderSide(
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              alignment: Alignment.center,
                                              child: const Icon(Icons.favorite_rounded),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
