import 'package:ally_4_u_client/models/user.model.dart' as u;
import 'package:ally_4_u_client/screens/auth/my_screen/setting_update.dart';
import 'package:ally_4_u_client/screens/profile/edit.profile.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../../util/theme.dart';
import '../payments/payment.details.dart';
import '../payments/subscription.dart';

final List adds = [
  {
    'icon': Icons.whatshot,
    'color': Colors.indigo,
    'title': "Get matches faster",
    'subtitle': "Boost your profile once a month",
  },
  {
    'icon': Icons.favorite,
    'color': Colors.lightBlueAccent,
    'title': "more likes",
    'subtitle': "Get free rewinds",
  },
  {
    'icon': Icons.star_half,
    'color': Colors.amber,
    'title': "Increase your chances",
    'subtitle': "Get unlimited free likes",
  },
  {
    'icon': Icons.location_on,
    'color': Colors.purple,
    'title': "Swipe around the world",
    'subtitle': "Passport to anywhere with VKU Dating",
  },
  {
    'icon': Icons.vpn_key,
    'color': Colors.orange,
    'title': "Control your profile",
    'subtitle': "highly secured",
  }
];

class Profile extends StatefulWidget {
  final u.User currentUser;
  final bool isPuchased;
  final Map<String, dynamic> items;
  final List<PurchaseDetails> purchases;

  const Profile({
    super.key,
    required this.currentUser,
    required this.isPuchased,
    required this.purchases,
    required this.items,
  });

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final EditProfileState _editProfileState = EditProfileState();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Consumer<ThemeNotifier>(
      builder: (context, notifier, _) => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: SizedBox(
          height: height,
          child: Stack(
            children: [
              Container(
                width: width,
                height: height * .65,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(widget.currentUser.imageUrl?[0] ?? ''),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  width: width,
                  height: height * .45,
                  decoration: BoxDecoration(
                    color: const Color(0xff333333),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(4, 5),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: height * .05),
                        Text(
                          '${widget.currentUser.name}, ${widget.currentUser.age}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 22,
                          ),
                        ),
                        SizedBox(height: height * .02),
                        const Text(
                          'Location',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: height * .01),
                        Text(
                          widget.currentUser.address,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: height * .02),
                        const Text(
                          'About',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: height * .01),
                        Text(
                          widget.currentUser.editInfo?['about'] ?? '',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: height * .02),
                        const Text(
                          'Gallery',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: height * .01),
                        if (widget.currentUser.imageUrl != null)
                          GridView.count(
                            crossAxisCount: 3,
                            mainAxisSpacing: 20,
                            crossAxisSpacing: 20,
                            shrinkWrap: true,
                            primary: false,
                            padding: EdgeInsets.zero,
                            childAspectRatio: 0.7,
                            children: widget.currentUser.imageUrl!
                                .asMap()
                                .map(
                                  (i, img) {
                                    return MapEntry(
                                      i,
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(5),
                                        child: Image.network(
                                          img,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                )
                                .values
                                .toList(),
                          ),
                        SizedBox(height: height * .02),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.white.withOpacity(0.1),
                          ),
                          height: height * .1,
                          width: MediaQuery.of(context).size.width * .85,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: CardSwiper(
                              key: UniqueKey(),
                              padding: EdgeInsets.zero,
                              numberOfCardsDisplayed: 1,
                              backCardOffset: const Offset(0, 0),
                              threshold: 1,
                              cardBuilder: (BuildContext context, int index2,
                                  int i, int i2) {
                                return Column(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          adds[index2]["icon"],
                                          color: adds[index2]["color"],
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                        Text(
                                          adds[index2]["title"],
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      adds[index2]["subtitle"],
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                );
                              },
                              cardsCount: adds.length,
                            ),
                          ),
                        ),
                        SizedBox(height: height * .02),
                        Align(
                          child: InkWell(
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                boxShadow: [
                                  BoxShadow(
                                    color: accentColor,
                                    spreadRadius: 3,
                                    blurRadius: 1,
                                  )
                                ],
                                borderRadius: BorderRadius.circular(25),
                                gradient: LinearGradient(
                                  begin: Alignment.topRight,
                                  end: Alignment.bottomLeft,
                                  colors: [
                                    accentColor.withOpacity(.5),
                                    accentColor.withOpacity(.8),
                                    accentColor,
                                    accentColor
                                  ],
                                ),
                              ),
                              height: MediaQuery.of(context).size.height * .065,
                              width: MediaQuery.of(context).size.width * .75,
                              child: Center(
                                child: Text(
                                  widget.isPuchased
                                      ? "Check Payment Details"
                                      : "Subscribe Plan",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () async {
                              if (widget.isPuchased) {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => PaymentDetails(
                                      purchases: widget.purchases,
                                    ),
                                  ),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (context) => Subscription(
                                      currentUser: widget.currentUser,
                                      items: widget.items,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        SizedBox(height: height * .02),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: height * .43,
                left: width * .15,
                right: width * .15,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            maintainState: true,
                            builder: (context) => SettingsUpdate(
                              currentUser: widget.currentUser,
                              isPurchased: widget.isPuchased,
                              items: widget.items,
                            ),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.settings_rounded,
                          color: Color(0xff333333),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _editProfileState.source(
                          context,
                          widget.currentUser,
                          false,
                        );
                      },
                      child: const CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xffE94057),
                        child: Icon(
                          Icons.add_a_photo_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => EditProfile(
                              currentUser: widget.currentUser,
                            ),
                          ),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.edit_rounded,
                          color: Color(0xff333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();

    paint.color = secondryColor.withOpacity(.4);
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;

    var startPoint = Offset(0, -size.height / 2);
    var controlPoint1 = Offset(size.width / 4, size.height / 3);
    var controlPoint2 = Offset(3 * size.width / 4, size.height / 3);
    var endPoint = Offset(size.width, -size.height / 2);

    var path = Path();
    path.moveTo(startPoint.dx, startPoint.dy);
    path.cubicTo(controlPoint1.dx, controlPoint1.dy, controlPoint2.dx,
        controlPoint2.dy, endPoint.dx, endPoint.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
