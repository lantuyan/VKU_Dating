import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/user.model.dart';

class ReportUser extends StatefulWidget {
  final User currentUser;
  final User seconduser;

  const ReportUser({super.key, required this.currentUser, required this.seconduser});

  @override
  State<ReportUser> createState() => _ReportUserState();
}

class _ReportUserState extends State<ReportUser> {
  TextEditingController reasonCtlr = TextEditingController();
  bool other = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => CupertinoAlertDialog(
        title: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.security,
                color: primaryColor,
                size: 35,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                "Report User",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
            Text(
              "Is this person bothering you? Tell us what they did.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: notifier.darkTheme ? lightText : Colors.black,
              ),
            ),
          ],
        ),
        actions: !other
            ? [
                Material(
                  child: ListTile(
                      title: const Text("Inappropriate Photos"),
                      leading: const Icon(
                        Icons.camera_alt,
                        color: Colors.indigo,
                      ),
                      onTap: () => _newReport(context, "Inappropriate Photos").then((value) => Navigator.pop(context))),
                ),
                Material(
                  child: ListTile(
                      title: const Text(
                        "Feels Like Spam",
                      ),
                      leading: const Icon(
                        Icons.sentiment_very_dissatisfied,
                        color: Colors.orange,
                      ),
                      onTap: () => _newReport(context, "Feels Like Spam").then((value) => Navigator.pop(context))),
                ),
                Material(
                  child: ListTile(
                      title: const Text(
                        "User is underage",
                      ),
                      leading: const Icon(
                        Icons.call_missed_outgoing,
                        color: Colors.blue,
                      ),
                      onTap: () => _newReport(context, "User is underage").then((value) => Navigator.pop(context))),
                ),
                Material(
                  child: ListTile(
                      title: const Text(
                        "Other",
                      ),
                      leading: const Icon(
                        Icons.report_problem,
                        color: Colors.green,
                      ),
                      onTap: () {
                        setState(() {
                          other = true;
                        });
                      }),
                ),
              ]
            : [
                Material(
                    child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: reasonCtlr,
                        decoration: const InputDecoration(hintText: "Additional Info(optional)"),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: ElevatedButton(
                          child: const Text(
                            "Report User",
                            style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            _newReport(context, reasonCtlr.text).then(
                              (value) => Navigator.pop(context),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ))
              ],
      ),
    );
  }

  Future _newReport(context, String reason) async {
    await FirebaseFirestore.instance
        .collection("Reports")
        .add({'reported_by': widget.currentUser.id, 'victim_id': widget.seconduser.id, 'reason': reason, 'timestamp': FieldValue.serverTimestamp()});
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        Future.delayed(const Duration(seconds: 3), () {
          Navigator.pop(context);
        });
        return Center(
          child: Consumer<ThemeNotifier>(
            builder: (context, ThemeNotifier notifier, child) => Container(
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
                    // color: primaryColor,
                    // colorBlendMode: BlendMode.color,
                  ),
                  Text(
                    "Reported",
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
}
