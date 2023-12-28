import 'package:ally_4_u_client/user.dob.dart';
import 'package:ally_4_u_client/user.name.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Welcome extends StatefulWidget {
  const Welcome({super.key});

  @override
  State<Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 30),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * .8,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 150,
                        ),
                        Text(
                          "vkudating",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 35,
                            color: accentColor,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.normal,
                          ),
                        ),
                        const ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Welcome to VKU Dating.\nPlease follow we product.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Be yourself.",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "Make sure your photos, age, and bio are true to who you are.",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Play it cool.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Respect other and treat them as you would like to be treated",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Stay safe.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Don't be too quick to give out personal information.",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                        const ListTile(
                          contentPadding: EdgeInsets.all(8),
                          title: Text(
                            "Be proactive.",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            "Always report bad behavior.",
                            style: TextStyle(
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, top: 50),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [accentColor.withOpacity(.5), accentColor.withOpacity(.8), accentColor, accentColor],
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * .065,
                      width: MediaQuery.of(context).size.width * .75,
                      child: Center(
                        child: Text(
                          "GOT IT",
                          style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    onTap: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        if (user.displayName != null) {
                          if (user.displayName!.isNotEmpty) {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => UserDOB(
                                  {'UserName': user.displayName},
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) => const UserName(),
                              ),
                            );
                          }
                        } else {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => const UserName(),
                            ),
                          );
                        }
                      }
                    },
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
