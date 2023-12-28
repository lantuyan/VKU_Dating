import 'package:ally_4_u_client/screens/auth/my_screen/login_update.dart';
import 'package:ally_4_u_client/splash.dart';
import 'package:ally_4_u_client/tab.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:ally_4_u_client/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ],
  ).then(
    (_) {
      InAppPurchase.instance.getPlatformAddition();
      runApp(
        const VkuDating(),
      );
    },
  );
}

class VkuDating extends StatefulWidget {
  const VkuDating({super.key});

  @override
  State<VkuDating> createState() => _VkuDatingState();
}

class _VkuDatingState extends State<VkuDating> with WidgetsBindingObserver {
  bool isLoading = true;
  bool isAuth = false;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future _checkAuth() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final user = auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('Users').where('userId', isEqualTo: user.uid).get().then(
        (QuerySnapshot snapshot) async {
          if (snapshot.docs.isNotEmpty) {
            final data = snapshot.docs[0].data() as Map<String, dynamic>;
            if (data.containsKey('location')) {
              setState(
                () {
                  isRegistered = true;
                  isLoading = false;
                },
              );
            } else {
              setState(
                () {
                  isAuth = true;
                  isLoading = false;
                },
              );
            }
          } else {
            setState(
              () {
                isLoading = false;
              },
            );
          }
        },
      );
    } else {
      setState(
        () {
          isLoading = false;
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeNotifier>(
      create: (_) => ThemeNotifier(),
      child: Consumer<ThemeNotifier>(
        builder: (BuildContext context, ThemeNotifier notifier, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: notifier.darkTheme ? dark : light,
            home: isLoading
                ? const Splash()
                : isRegistered
                    ? const Tabbar()
                    : isAuth
                        ? const Welcome()
                        : const LoginUpdate(),
          );
        },
      ),
    );
  }
}
