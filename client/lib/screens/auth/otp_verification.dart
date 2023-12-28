import 'package:ally_4_u_client/util/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../tab.dart';
import '../../util/color.dart';
import '../../util/theme.dart';
import 'login.dart';
import 'otp.dart';

class Verification extends StatefulWidget {
  final bool updateNumber;
  final String phoneNumber;
  final String smsVerificationCode;

  const Verification(this.phoneNumber, this.smsVerificationCode, this.updateNumber, {super.key});

  @override
  State<Verification> createState() => _VerificationState();
}

// ignore: prefer_typing_uninitialized_variables
var onTapRecognizer;

class _VerificationState extends State<Verification> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future updateNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance.collection("Users").doc(user?.uid).set({'phoneNumber': user?.phoneNumber}, SetOptions(merge: true)).then(
      (_) {
        showDialog(
          barrierDismissible: false,
          context: context,
          builder: (_) {
            Future.delayed(
              const Duration(seconds: 2),
              () async {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const Tabbar(),
                  ),
                );
              },
            );
            return Consumer<ThemeNotifier>(
              builder: (context, ThemeNotifier notifier, child) => Center(
                child: Container(
                  width: 180.0,
                  height: 200.0,
                  decoration: BoxDecoration(
                    color: notifier.darkTheme ? darkAppbarColor : Colors.white,
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Image.asset(
                        "asset/auth/verified.png",
                        height: 100,
                      ),
                      Text(
                        "Phone Number\nChanged\nSuccessfully",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                          color: notifier.darkTheme ? lightText : darkText,
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
      },
    );
  }

  String? code;

  @override
  void initState() {
    super.initState();
    onTapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        Navigator.pop(context);
      };
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: SvgPicture.asset(
                    "asset/verify.svg",
                    height: MediaQuery.of(context).size.height * .2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 50),
                child: RichText(
                  text: TextSpan(
                    text: "Enter the code sent to ",
                    children: [
                      TextSpan(
                        text: widget.phoneNumber,
                        style: TextStyle(
                          color: accentColor,
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.bold,
                          textBaseline: TextBaseline.alphabetic,
                          fontSize: 15,
                        ),
                      ),
                    ],
                    style: TextStyle(
                      color: notifier.darkTheme ? lightText : darkText,
                      fontSize: 15,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50),
                child: PinCodeTextField(
                  textStyle: TextStyle(
                    color: notifier.darkTheme ? lightText : darkText,
                  ),
                  backgroundColor: notifier.darkTheme ? darkBackground : primaryColor,
                  length: 6,
                  animationType: AnimationType.fade,
                  animationDuration: const Duration(milliseconds: 300),
                  onChanged: (value) {
                    code = value;
                  },
                  appContext: context,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: "Didn't receive the code? ",
                  style: TextStyle(
                    color: notifier.darkTheme ? lightText : darkText,
                    fontSize: 15,
                  ),
                  children: [
                    TextSpan(
                      text: " RESEND",
                      recognizer: onTapRecognizer,
                      style: const TextStyle(
                        color: Color(0xFF91D3B3),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(25),
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [
                        accentColor.withOpacity(.5),
                        accentColor.withOpacity(.8),
                        accentColor,
                        accentColor,
                      ],
                    ),
                  ),
                  height: MediaQuery.of(context).size.height * .065,
                  width: MediaQuery.of(context).size.width * .75,
                  child: Center(
                    child: Text(
                      "VERIFY",
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                onTap: () async {
                  showDialog(
                    builder: (context) {
                      Future.delayed(
                        const Duration(seconds: 2),
                        () {
                          Navigator.pop(context);
                        },
                      );
                      return const Center(
                        child: CupertinoActivityIndicator(
                          radius: 20,
                        ),
                      );
                    },
                    barrierDismissible: false,
                    context: context,
                  );
                  PhoneAuthCredential phoneAuth = PhoneAuthProvider.credential(verificationId: widget.smsVerificationCode, smsCode: code!);
                  if (widget.updateNumber) {
                    User? user = FirebaseAuth.instance.currentUser;
                    user?.updatePhoneNumber(phoneAuth).then((_) => updateNumber()).catchError(
                      (e) {
                        CustomSnackbar.snackbar("$e", context);
                      },
                    );
                  } else {
                    FirebaseAuth.instance.signInWithCredential(phoneAuth).then(
                      (authResult) {
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (_) {
                            Future.delayed(
                              const Duration(seconds: 2),
                              () async {
                                Navigator.pop(context);
                                await navigationCheck(authResult.user!, context);
                              },
                            );
                            return Consumer<ThemeNotifier>(
                              builder: (context, ThemeNotifier notifier, child) => Center(
                                child: Container(
                                  width: 180.0,
                                  height: 200.0,
                                  decoration: BoxDecoration(
                                    color: notifier.darkTheme ? darkText : primaryColor,
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    children: [
                                      Image.asset(
                                        "asset/auth/verified.png",
                                        height: 100,
                                      ),
                                      Text(
                                        "Verified\n Successfully",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          decoration: TextDecoration.none,
                                          color: notifier.darkTheme ? lightText : darkText,
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
                        FirebaseFirestore.instance.collection('Users').where('userId', isEqualTo: authResult.user?.uid).get().then(
                          (QuerySnapshot snapshot) async {
                            if (snapshot.docs.isEmpty) {
                              await setDataUser(authResult.user!);
                            }
                          },
                        );
                      },
                    ).catchError(
                      (onError) {
                        CustomSnackbar.snackbar("$onError", context);
                      },
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
