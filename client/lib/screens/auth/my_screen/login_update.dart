import 'package:ally_4_u_client/screens/auth/login.dart';
import 'package:ally_4_u_client/screens/auth/my_screen/otp_update.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginUpdate extends StatelessWidget {
  const LoginUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    return Consumer<ThemeNotifier>(
      builder: (context, value, child) {
        return SafeArea(
          child: Scaffold(
            body: Container(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    height: 20,
                  ),
                  SizedBox(
                    height: h * 0.45,
                    child: Image.asset("asset/Logo.png"),
                  ),
                  SizedBox(
                    height: h * 0.03,
                  ),
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
                      fontSize: 30,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Join us one socialize wirn\nmillions of people',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  phoneLoginButton(
                      title: "Login with Phone Number",
                      icon: Icons.phone,
                      iconColor: Colors.black,
                      onTap: () async {
                        bool updateNumber = false;
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => OTPUpdate(updateNumber),
                          ),
                        );
                      }),
                  const SizedBox(
                    height: 15,
                  ),
                  phoneLoginButton(
                      title: "Login with Facebook",
                      icon: Icons.facebook,
                      iconColor: Colors.blue.shade600,
                      onTap: () async {
                        await handleFacebookLogin(context).then(
                          (user) {
                            navigationCheck(user!, context);
                          },
                        );
                      }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget phoneLoginButton({
    required String title,
    required IconData icon,
    required Function onTap,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        height: 50,
        decoration: const BoxDecoration(
          color: Color(0xFF4B164C),
          borderRadius: BorderRadius.all(
            Radius.circular(
              30,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: CircleAvatar(
                backgroundColor: Colors.white,
                radius: 15,
                child: Icon(
                  icon,
                  color: iconColor,
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              width: 10,
            )
          ],
        ),
      ),
    );
  }
}
