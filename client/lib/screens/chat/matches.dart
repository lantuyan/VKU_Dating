// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:ally_4_u_client/models/user.model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/color.dart';
import '../../util/theme.dart';
import 'chat.page.dart';

class Matches extends StatelessWidget {
  final User currentUser;
  final List<User> matches;

  const Matches({
    super.key,
    required this.currentUser,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;

    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Activities',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                // color: Colors.white,
                color: notifier.darkTheme ? Colors.white : Colors.grey.shade500,
              ),
            ),
            SizedBox(height: height * .02),
            SizedBox(
              height: height * .18,
              child: matches.isNotEmpty
                  ? ListView.builder(
                      padding: const EdgeInsets.only(left: 10.0),
                      scrollDirection: Axis.horizontal,
                      itemCount: matches.length,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => ChatPage(
                                sender: currentUser,
                                chatId: chatId(currentUser, matches[index]),
                                second: matches[index],
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  backgroundColor: secondryColor,
                                  radius: 35.0,
                                  backgroundImage: CachedNetworkImageProvider(
                                    matches[index].imageUrl![0] ?? '',
                                  ),
                                ),
                                const SizedBox(height: 6.0),
                                Text(
                                  matches[index].name,
                                  style: TextStyle(
                                    color: secondryColor,
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        "No match found",
                        style: TextStyle(color: secondryColor, fontSize: 16),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

var groupChatId;
chatId(currentUser, sender) {
  if (currentUser.id.hashCode <= sender.id.hashCode) {
    return groupChatId = '${currentUser.id}-${sender.id}';
  } else {
    return groupChatId = '${sender.id}-${currentUser.id}';
  }
}
