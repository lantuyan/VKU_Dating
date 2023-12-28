import 'package:ally_4_u_client/assets_images/assets_image.dart';
import 'package:ally_4_u_client/cons_colors/cons_colors.dart';
import 'package:ally_4_u_client/screens/auth/login.dart';
import 'package:ally_4_u_client/screens/auth/my_screen/otp_update.dart';
import 'package:ally_4_u_client/tab.dart';
import 'package:ally_4_u_client/util/snackbar.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:ally_4_u_client/utils/utils.dart';
import 'package:ally_4_u_client/widget/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';

import '../../../util/color.dart';
 
class OtpVerficationUpdate extends StatefulWidget {
  final bool updateNumber;
  final String phoneNumber;
  final String smsVerificationCode;

  const OtpVerficationUpdate(
      this.phoneNumber, this.smsVerificationCode, this.updateNumber,
      {super.key});

  @override
  State<OtpVerficationUpdate> createState() => _OtpVerficationState();
}

// ignore: prefer_typing_uninitialized_variables
var onTapRecognizer;

class _OtpVerficationState extends State<OtpVerficationUpdate> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  Future updateNumber() async {
    User? user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(user?.uid)
        .set({'phoneNumber': user?.phoneNumber}, SetOptions(merge: true)).then(
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
      builder: (context, ThemeNotifier notifier, child) => SafeArea(
        child: Scaffold(
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 30,
                ),
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(
                      top: 10,
                    ),
                    // margin: const EdgeInsets.only(top: 100),

                    height: Utils.responsiveHeight(
                      context: context,
                      height: 10,
                    ),

                    child: Image.asset(
                      fit: BoxFit.fill,
                      AssetsImages.tradeMark,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.only(
                    top: 30,
                  ),
                  child: Text(
                    "OTP Verification ",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      // color: Colors.grey.shade500,
                      color: notifier.darkTheme ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 30),
                  child: RichText(
                    text: TextSpan(
                      text: "Please Enter the code sent to ",
                      children: [
                        TextSpan(
                          text: widget.phoneNumber,
                          style: TextStyle(
                            // color: accentColor,?
                            color: Colors.grey.shade300,

                            // fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            textBaseline: TextBaseline.alphabetic,
                            fontSize: 18,
                          ),
                        ),
                      ],
                      style: TextStyle(
                        // color: notifier.darkTheme ? lightText : darkText,
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: PinCodeTextField(
                    pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        fieldHeight: 50,
                        selectedColor: darkPinkColor,
                        // disabledColor: ConstColors.darkBlue,
                        disabledColor: darkPinkColor,
                        inactiveColor: darkPinkColor,
                        fieldWidth: 50,
                        borderWidth: 0.1,
                        // activeColor: Colors.blue.shade200,
                        activeColor: darkPinkColor,
                        activeFillColor: darkPinkColor),
                    textStyle: TextStyle(
                      color: notifier.darkTheme ? lightText : darkText,
                    ),
                    backgroundColor:
                        notifier.darkTheme ? darkBackground : primaryColor,
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
                        style: TextStyle(
                          // color: Color(0xFF91D3B3),
                          color: notifier.darkTheme
                              ? blueOtpFieldColor
                              : ConstColors.darkBlue,
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
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                  ),
                  child: CustomButton(
                    text: "VERIFY",
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    height: 55.0,
                    borderRadius: 5,
                    // backgroundColor: ConstColors.darkBlue,
                    backgroundColor: darkPinkColor,
                    onPress: () async {
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
                      PhoneAuthCredential phoneAuth =
                          PhoneAuthProvider.credential(
                              verificationId: widget.smsVerificationCode,
                              smsCode: code!);
                      if (widget.updateNumber) {
                        User? user = FirebaseAuth.instance.currentUser;
                        user
                            ?.updatePhoneNumber(phoneAuth)
                            .then((_) => updateNumber())
                            .catchError(
                          (e) {
                            CustomSnackbar.snackbar("$e", context);
                          },
                        );
                      } else {
                        FirebaseAuth.instance
                            .signInWithCredential(phoneAuth)
                            .then(
                          (authResult) {
                            showDialog(
                              barrierDismissible: false,
                              context: context,
                              builder: (_) {
                                Future.delayed(
                                  const Duration(seconds: 2),
                                  () async {
                                    Navigator.pop(context);
                                    await navigationCheck(
                                        authResult.user!, context);
                                  },
                                );
                                return Consumer<ThemeNotifier>(
                                  builder: (context, ThemeNotifier notifier,
                                          child) =>
                                      Center(
                                    child: Container(
                                      width: 180.0,
                                      height: 200.0,
                                      decoration: BoxDecoration(
                                        color: notifier.darkTheme
                                            ? darkText
                                            : primaryColor,
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
                                              color: notifier.darkTheme
                                                  ? lightText
                                                  : darkText,
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
                            FirebaseFirestore.instance
                                .collection('Users')
                                .where('userId',
                                    isEqualTo: authResult.user?.uid)
                                .get()
                                .then(
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
