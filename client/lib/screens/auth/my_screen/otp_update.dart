
import 'package:ally_4_u_client/screens/auth/login.dart';
import 'package:ally_4_u_client/screens/auth/my_screen/otp_verfication_update.dart';
import 'package:ally_4_u_client/tab.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/snackbar.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:ally_4_u_client/widget/custom_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_country_code_picker/fl_country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class OTPUpdate extends StatefulWidget {
  final bool updateNumber;

  const OTPUpdate(this.updateNumber, {super.key});

  @override
  State<OTPUpdate> createState() => _OTPState();
}

class _OTPState extends State<OTPUpdate> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool cont = false, phoneIsEmpty = true;
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
                builder: (context) => OtpVerficationUpdate(
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

  bool isFocus = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(builder: (context, notifier, _) {
      return SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          key: _scaffoldKey,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 50),
              child: Focus(
                onFocusChange: (value) {
                  isFocus = value;
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      height: 40,
                    ),
                    Image.asset(
                      "asset/trademark.png",
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Center(
                      child: Text(
                        "Welcome to VKU Dating",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text("Enter your Phone Number"),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 30),
                      height: 55,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          // color: Colors.grey.shade100,
                          color: notifier.darkTheme ? darkModeColor : textFieldColor,

                          // color: textFieldColor,
                          borderRadius: const BorderRadius.all(Radius.circular(6))),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () async {
                                final code = await countryPicker.showPicker(context: context);
                                countryCode = code?.dialCode ?? '+84';
                                setState(() {});
                              },
                              child: Container(
                                color: notifier.darkTheme ? darkModeColor : textFieldColor,
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  countryCode,
                                  style: TextStyle(
                                    // color: Colors.black,
                                    fontSize: 15,
                                    color: notifier.darkTheme ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(
                              top: 10,
                              bottom: 10,
                            ),
                            child: VerticalDivider(
                              color: Colors.grey,
                            ),
                          ),
                          Expanded(
                            flex: 7,
                            child: Container(
                              height: 55,
                              // color: Colors.red,
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(left: 10),
                              decoration: BoxDecoration(
                                // color: Colors.grey.shade300,
                                color: notifier.darkTheme ? darkModeColor : textFieldColor,
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                  color: notifier.darkTheme ? Colors.white : Colors.black,
                                ),
                                maxLines: 50,
                                controller: phoneNumController,
                                onChanged: (v) {
                                  if (v.isNotEmpty) {
                                    setState(() {
                                      phoneIsEmpty = false;
                                    });
                                  } else {
                                    setState(() {
                                      phoneIsEmpty = true;
                                    });
                                  }
                                },
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                // expands: true,
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  hintText: "Phone Number",
                                  // labelText: "Phone Number",kkmmkmks
                                  labelStyle: TextStyle(color: Colors.grey.shade800),
                                  hintStyle: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.only(
                                    bottom: 5,
                                    top: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),

                    !phoneIsEmpty
                        ? Container(
                            padding: const EdgeInsets.only(left: 28, right: 28, top: 20),
                            child: CustomButton(
                                backgroundColor: pinkThemeColor,
                                height: 55.0,
                                borderRadius: 5,
                                text: "Continue",
                                textStyle: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                onPress: () async {
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
                                }),
                          )
                        : Container(),

                    // phoneNumController.text.isNotEmpty
                    //     ? Container(
                    //         padding: const EdgeInsets.only(
                    //             left: 20, right: 20, top: 20),
                    //         child: CustomButton(
                    //             backgroundColor: ConstColors.darkBlue,
                    //             height: 55.0,
                    //             text: "verify",
                    //             textStyle: const TextStyle(
                    //               fontSize: 17,
                    //               color: Colors.white,
                    //             ),
                    //             onPress: () async {
                    //               showDialog(
                    //                 builder: (context) {
                    //                   Future.delayed(
                    //                     const Duration(seconds: 1),
                    //                     () {
                    //                       Navigator.pop(context);
                    //                     },
                    //                   );
                    //                   return const Center(
                    //                     child: CupertinoActivityIndicator(
                    //                       radius: 20,
                    //                     ),
                    //                   );
                    //                 },
                    //                 barrierDismissible: false,
                    //                 context: context,
                    //               );

                    //               await _verifyPhoneNumber(
                    //                   phoneNumController.text);
                    //             }),
                    //       )
                    //     : Container()
                  ],
                ),
              ),
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
