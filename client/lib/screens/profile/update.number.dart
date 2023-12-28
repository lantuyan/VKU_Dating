import 'package:ally_4_u_client/util/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.model.dart';
import '../../util/theme.dart';
import '../auth/otp.dart';

class UpdateNumber extends StatelessWidget {
  final User currentUser;

  const UpdateNumber({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: const Padding(
              padding: EdgeInsets.only(left: 30),
              child: Text(
                "Phone number settings",
                style: TextStyle(
                  fontSize: 18,
                  // color: notifier.darkTheme ? lightText : mediumTex
                  color: Colors.white,
                ),
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: notifier.darkTheme ? lightText : mediumText,
              onPressed: () => Navigator.pop(context),
            ),
            // backgroundColor: notifier.darkTheme ? darkBackground : primaryColor,
            backgroundColor: darkPinkColor,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              color: notifier.darkTheme ? darkBackground : primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Text(
                    "Phone number",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text(
                      currentUser.phoneNumber != null
                          ? "${currentUser.phoneNumber}"
                          : "Verify Phone number",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    trailing: Icon(
                      currentUser.phoneNumber != null ? Icons.done : null,
                      color: notifier.darkTheme ? primaryColor : mediumText,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    "Verified phone number",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: secondryColor,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Center(
                    child: InkWell(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            "Update my phone number",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color:
                                  notifier.darkTheme ? lightText : mediumText,
                            ),
                          ),
                        ),
                      ),
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const OTP(true),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
