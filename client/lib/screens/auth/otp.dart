
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/snackbar.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../tab.dart';
import 'login.dart';
import 'otp_verification.dart';

class OTP extends StatefulWidget {
  final bool updateNumber;

  const OTP(this.updateNumber, {super.key});

  @override
  State<OTP> createState() => _OTPState();
}

class _OTPState extends State<OTP> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool cont = false;
  String? _smsVerificationCode;
  String countryCode = '+84';
  TextEditingController phoneNumController = TextEditingController();

  /// Default.
  final countryPicker = FlCountryCodePicker(
    countryTextStyle: const TextStyle(
      color: Color(0xff333333),
    ),
    dialCodeTextStyle: const TextStyle(
      color: Color(0xff333333),
    ),
    searchBarDecoration: InputDecoration(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(
          color: Color(0xff333333),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(
          color: Color(0xff333333),
        ),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(100),
        borderSide: const BorderSide(
          color: Color(0xff333333),
        ),
      ),
      hintStyle: const TextStyle(
        color: Color(0xff333333),
      ),
      hintText: 'Search Countries',
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    ),
  );

  @override
  void dispose() {
    super.dispose();
    cont = false;
  }

  /// method to verify phone number and handle phone auth
  Future _verifyPhoneNumber(String phoneNumber) async {
    phoneNumber = countryCode + phoneNumber.toString();
    final FirebaseAuth auth = FirebaseAuth.instance;
    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: const Duration(seconds: 30),
      verificationCompleted: (authCredential) => _verificationComplete(authCredential, context),
      verificationFailed: (authException) => _verificationFailed(authException, context),
      codeAutoRetrievalTimeout: (verificationId) => _codeAutoRetrievalTimeout(verificationId),
      // called when the SMS code is sent
      codeSent: (verificationId, [code]) {
        _smsCodeSent(verificationId, [code]);
      },
    );
  }

  Future updatePhoneNumber() async {
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

  /// will get an AuthCredential object that will help with logging into Firebase.
  _verificationComplete(PhoneAuthCredential authCredential, BuildContext context) async {
    if (widget.updateNumber) {
      User? user = FirebaseAuth.instance.currentUser;
      user?.updatePhoneNumber(authCredential).then((_) => updatePhoneNumber()).catchError(
        (e) {
          // log('error $e');
          CustomSnackbar.snackbar("$e", context);
        },
      );
    } else {
      FirebaseAuth.instance.signInWithCredential(authCredential).then(
        (authResult) async {
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
                    width: 150.0,
                    height: 160.0,
                    decoration: BoxDecoration(
                      color: notifier.darkTheme ? darkAppbarColor : primaryColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Image.asset(
                          "asset/auth/verified.png",
                          height: 60,
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
          await FirebaseFirestore.instance.collection('Users').where('userId', isEqualTo: authResult.user?.uid).get().then(
            (QuerySnapshot snapshot) async {
              if (snapshot.docs.isEmpty) {
                await setDataUser(authResult.user!);
              }
            },
          );
        },
      );
    }
  }

  _smsCodeSent(String verificationId, List<int?> code) async {
    // set the verification code so that we can use it to log the user in
    _smsVerificationCode = verificationId;
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (_) {
        Future.delayed(
          const Duration(seconds: 2),
          () {
            Navigator.pop(context);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => Verification(
                  countryCode + phoneNumController.text,
                  _smsVerificationCode!,
                  widget.updateNumber,
                ),
              ),
            );
          },
        );
        return Center(
          // Aligns the container to center
          child: Consumer<ThemeNotifier>(
            builder: (context, ThemeNotifier notifier, child) => Container(
              // A simplified version of dialog.
              width: 100.0,
              height: 120.0,
              decoration: BoxDecoration(
                color: notifier.darkTheme ? darkAppbarColor : primaryColor,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Image.asset(
                    "asset/auth/verified.png",
                    height: 60,
                  ),
                  Text(
                    "OTP\nSent",
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
  }

  _verificationFailed(FirebaseAuthException authException, BuildContext context) {
    // log(authException.message.toString());
    CustomSnackbar.snackbar("Exception!! message:${authException.message}", context);
  }

  _codeAutoRetrievalTimeout(String verificationId) {
    _smsVerificationCode = verificationId;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, _) {
      return Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SvgPicture.asset(
                    "asset/login.svg",
                    width: MediaQuery.of(context).size.width,
                  ),
                ),
                const ListTile(
                  title: Text(
                    "Verify Your Number",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    r"""Please enter Your mobile Number to
receive a verification code. Message and data 
rates may apply.""",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 50,
                    horizontal: 50,
                  ),
                  child: ListTile(
                    title: TextFormField(
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(fontSize: 14),
                      cursorColor: accentColor,
                      controller: phoneNumController,
                      onChanged: (value) {
                        setState(
                          () {
                            cont = true;
                          },
                        );
                      },
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Enter your number",
                        hintStyle: const TextStyle(fontSize: 14),
                        focusColor: accentColor,
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        prefixIcon: InkWell(
                          onTap: () async {
                            final code = await countryPicker.showPicker(context: context);
                            countryCode = code?.dialCode ?? '+84';
                            setState(() {});
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(countryCode),
                          ),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: accentColor,
                          ),
                        ),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                            color: accentColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                cont
                    ? InkWell(
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
                              "CONTINUE",
                              style: TextStyle(
                                fontSize: 15,
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
                                const Duration(seconds: 1),
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

                          await _verifyPhoneNumber(phoneNumController.text);
                        },
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(25),
                        ),
                        height: MediaQuery.of(context).size.height * .065,
                        width: MediaQuery.of(context).size.width * .75,
                        child: Center(
                          child: Text(
                            "CONTINUE",
                            style: TextStyle(
                              fontSize: 15,
                              color: darkPrimaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

Future setDataUser(User user) async {
  await FirebaseFirestore.instance.collection("Users").doc(user.uid).set({
    'userId': user.uid,
    'phoneNumber': user.phoneNumber,
    'timestamp': FieldValue.serverTimestamp(),
    'Pictures': FieldValue.arrayUnion(["https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxUC64VZctJ0un9UBnbUKtj-blhw02PeDEQIMOqovc215LWYKu&s"])

    // 'name': user.displayName,
    // 'pictureUrl': user.photoUrl,
  }, SetOptions(merge: true));
}
