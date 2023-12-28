// ignore_for_file: constant_identifier_names

import 'package:ally_4_u_client/models/custom.web.view.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../tab.dart';
import '../../welcome.dart';
import 'otp.dart';

class Login extends StatelessWidget {
  const Login({super.key});
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Consumer<ThemeNotifier>(
      builder: (BuildContext context, ThemeNotifier notifier, Widget? _) =>
          Scaffold(
        body: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                child: Image.asset(
                  'asset/Logo.png',
                  width: width * .8,
                ),
              ),
              SizedBox(height: height * .02),
              const Text.rich(
                TextSpan(
                  text: 'Find Your',
                  children: [
                    TextSpan(
                      text: ' Partner',
                      style: TextStyle(
                        color: Color(0xffD4192C),
                      ),
                    ),
                    TextSpan(text: '\nWith Us'),
                  ],
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: height * .02),
              Text(
                'Join us one socialize wirn\nmillions of people',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              SizedBox(height: height * .03),
              InkWell(
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: const Color(0xff333333),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    builder: (BuildContext context) => const _BottomSheet(),
                  );
                },
                child: Container(
                  width: width * .7,
                  height: height * .05,
                  decoration: BoxDecoration(
                    color: const Color(0xffD4192C),
                    borderRadius: BorderRadius.circular(height * .05),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 25,
                        offset: const Offset(5, 5),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ]),
      ),
    );
  }
}

Future _setDataUser(User user) async {
  await FirebaseFirestore.instance.collection("Users").doc(user.uid).set(
    {
      'userId': user.uid,
      'UserName': user.displayName ?? '',
      'Pictures': FieldValue.arrayUnion([
        user.photoURL ??
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxUC64VZctJ0un9UBnbUKtj-blhw02PeDEQIMOqovc215LWYKu&s'
      ]),
      'phoneNumber': user.phoneNumber,
      'timestamp': FieldValue.serverTimestamp()
    },
    SetOptions(merge: true),
  );
}

class _BottomSheet extends StatelessWidget {
  const _BottomSheet();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: width * .15,
          height: 5,
          margin: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        InkWell(
          onTap: () async {
            showDialog(
              context: context,
              builder: (context) {
                return SizedBox(
                  height: 30,
                  width: 30,
                  child: Center(
                    child: CupertinoActivityIndicator(
                      key: UniqueKey(),
                      radius: 20,
                      animating: true,
                    ),
                  ),
                );
              },
            );
            await handleFacebookLogin(context).then(
              (user) {
                navigationCheck(user!, context);
              },
            ).then(
              (_) {
                Navigator.pop(context);
              },
            ).catchError(
              (e) {
                Navigator.pop(context);
              },
            );
          },
          child: Container(
            width: width,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            height: height * .05,
            decoration: BoxDecoration(
              color: const Color(0xff1877f2),
              borderRadius: BorderRadius.circular(height * .05),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.facebook_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  'Continue With Facebook',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: width * .2,
              height: 2,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            const Text('OR'),
            Container(
              width: width * .2,
              height: 2,
              margin: const EdgeInsets.only(left: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
        InkWell(
          onTap: () {
            bool updateNumber = false;
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => OTP(updateNumber),
              ),
            );
          },
          child: Container(
            width: width,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            height: height * .05,
            decoration: BoxDecoration(
              color: const Color(0xffD4192C),
              borderRadius: BorderRadius.circular(height * .05),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_rounded,
                  color: Colors.white,
                ),
                SizedBox(width: 10),
                Text(
                  'Continue With Phone Number',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ********************/
//handle facebook login
/* ********************/
Future<User?> handleFacebookLogin(context) async {
  User? user;
  const your_client_id = 'your_facebook_appId'; // TODO: add your facebook client id
  const your_redirect_url = 'your_redirect_url'; // TODO: add your facebook redirect url
  String result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const CustomWebView(
        selectedUrl:
            'https://www.facebook.com/dialog/oauth?client_id=$your_client_id&redirect_uri=$your_redirect_url&response_type=token&scope=email,public_profile,',
      ),
      maintainState: true,
    ),
  );
  final facebookAuthCred = FacebookAuthProvider.credential(result);
  user =
      (await FirebaseAuth.instance.signInWithCredential(facebookAuthCred)).user;
  return user;
}

Future navigationCheck(User currentUser, context) async {
  await FirebaseFirestore.instance
      .collection('Users')
      .where('userId', isEqualTo: currentUser.uid)
      .get()
      .then(
    (QuerySnapshot snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs[0].data() as Map<String, dynamic>;
        if (data.containsKey('location')) {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const Tabbar(),
            ),
          );
        } else {
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => const Welcome(),
            ),
          );
        }
      } else {
        await _setDataUser(currentUser);
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const Welcome(),
          ),
        );
      }
    },
  );
}
