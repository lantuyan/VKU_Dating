import 'package:ally_4_u_client/models/user.model.dart';
import 'package:ally_4_u_client/screens/auth/my_screen/chat_page_update.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../util/color.dart';
import 'matches.dart';

class RecentChats extends StatelessWidget {
  final db = FirebaseFirestore.instance;
  final User currentUser;
  final List<User> matches;

  RecentChats({super.key, required this.currentUser, required this.matches});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Expanded(
        child: Container(
          decoration: const BoxDecoration(
            // color: notifier.darkTheme ? darkBackground : primaryColor,
            // color: Colors.red,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0),
              topRight: Radius.circular(30.0),
            ),
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(30.0),
            ),
            child: ListView(
              physics: const ScrollPhysics(),
              children: matches
                  .map(
                    (index) => GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => ChatPageUpdate(
                            chatId: chatId(currentUser, index),
                            sender: currentUser,
                            second: index,
                          ),
                        ),
                      ),
                      child: StreamBuilder(
                        stream: db
                            .collection("chats")
                            .doc(chatId(currentUser, index))
                            .collection('messages')
                            .orderBy('time', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Padding(
                              padding: EdgeInsets.all(18.0),
                              child: CupertinoActivityIndicator(),
                            );
                          } else if (snapshot.data!.docs.isEmpty) {
                            return Container();
                          }
                          index.lastmsg = snapshot.data?.docs[0]['time'];
                          return Container(
                            margin:
                                const EdgeInsets.only(top: 5.0, bottom: 5.0),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: snapshot.data?.docs[0]['sender_id'] !=
                                          currentUser.id &&
                                      !snapshot.data?.docs[0]['isRead']
                                  ? accentColor.withOpacity(.1)
                                  : secondryColor.withOpacity(.2),
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20.0),
                                bottomRight: Radius.circular(20.0),
                              ),
                            ),
                            child: ListTile(
                              leading: Badge(
                                // borderSide: const BorderSide(
                                //   width: 2,
                                //   color: Color(0xff3333333),
                                //   style: BorderStyle.solid,
                                // ),
                                // padding: const EdgeInsets.all(7),
                                // toAnimate: true,
                                // badgeColor: index.isOnline
                                //     ? Colors.greenAccent
                                //     : Colors.orange,
                                position:
                                    BadgePosition.bottomEnd(bottom: 1, end: 5),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: CachedNetworkImage(
                                    imageUrl: index.imageUrl![0] ?? '',
                                    fit: BoxFit.cover,
                                    width: 50,
                                    height: 50,
                                    useOldImageOnUrlChange: true,
                                    placeholder: (context, url) =>
                                        const CupertinoActivityIndicator(
                                      radius: 15,
                                    ),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                ),
                              ),
                              title: Text(
                                index.name,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                snapshot.data!.docs[0]['image_url']
                                        .toString()
                                        .isNotEmpty
                                    ? "Photo"
                                    : snapshot.data?.docs[0]['text'],
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    snapshot.data?.docs[0]["time"] != null
                                        ? DateFormat.MMMd()
                                            .add_jm()
                                            .format(snapshot
                                                .data?.docs[0]["time"]
                                                .toDate())
                                            .toString()
                                        : "",
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  snapshot.data?.docs[0]['sender_id'] !=
                                              currentUser.id &&
                                          !snapshot.data?.docs[0]['isRead']
                                      ? Container(
                                          width: 40.0,
                                          height: 20.0,
                                          decoration: BoxDecoration(
                                            color: accentColor,
                                            borderRadius:
                                                BorderRadius.circular(30.0),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'NEW',
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : const Text(""),
                                  snapshot.data?.docs[0]['sender_id'] ==
                                          currentUser.id
                                      ? !snapshot.data?.docs[0]['isRead']
                                          ? Icon(
                                              Icons.done,
                                              color: secondryColor,
                                              size: 15,
                                            )
                                          : Icon(
                                              Icons.done_all,
                                              color: primaryColor,
                                              size: 15,
                                            )
                                      : const Text("")
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}
