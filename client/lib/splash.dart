import 'package:ally_4_u_client/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        body: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
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
              const Spacer(),
              const Text(
                'VKU Dating',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: height * .02),
            ],
          ),
        ),
      ),
    );
  }
}
