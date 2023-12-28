import 'package:ally_4_u_client/show.gender.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/snackbar.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SexualOrientation extends StatefulWidget {
  final Map<String, dynamic> userData;
  const SexualOrientation(this.userData, {super.key});

  @override
  State<SexualOrientation> createState() => _SexualOrientationState();
}

class _SexualOrientationState extends State<SexualOrientation> {
  List<Map<String, dynamic>> orientationlist = [
    {'name': 'Straight', 'ontap': false},
    {'name': 'Gay', 'ontap': false},
    {'name': 'Asexual', 'ontap': false},
    {'name': 'Lesbian', 'ontap': false},
    {'name': 'Bisexual', 'ontap': false},
    {'name': 'Demisexual', 'ontap': false},
  ];
  List selected = [];
  bool select = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        key: _scaffoldKey,
        floatingActionButton: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 50),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: FloatingActionButton(
              elevation: 10,
              backgroundColor: accentColor,
              onPressed: () {
                dispose();
                Navigator.pop(context);
              },
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    left: 50,
                    top: 100,
                  ),
                  child: Text(
                    "My sexual\norientation is",
                    style: TextStyle(fontSize: 40),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 50),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: orientationlist.length,
                    itemBuilder: (BuildContext context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(width: 1, style: BorderStyle.solid, color: orientationlist[index]["ontap"] ? accentColor : secondryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: () {
                            setState(
                              () {
                                if (selected.length < 3) {
                                  orientationlist[index]["ontap"] = !orientationlist[index]["ontap"];
                                  if (orientationlist[index]["ontap"]) {
                                    selected.add(orientationlist[index]["name"]);
                                  } else {
                                    selected.remove(orientationlist[index]["name"]);
                                  }
                                } else {
                                  if (orientationlist[index]["ontap"]) {
                                    orientationlist[index]["ontap"] = !orientationlist[index]["ontap"];
                                    selected.remove(orientationlist[index]["name"]);
                                  } else {
                                    CustomSnackbar.snackbar("select upto 3", context);
                                  }
                                }
                              },
                            );
                          },
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * .055,
                            width: MediaQuery.of(context).size.width * .65,
                            child: Center(
                              child: Text(
                                "${orientationlist[index]["name"]}",
                                style: TextStyle(
                                  fontSize: 20,
                                  color: orientationlist[index]["ontap"] ? accentColor : secondryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  children: [
                    ListTile(
                      leading: Checkbox(
                        activeColor: accentColor,
                        value: select,
                        onChanged: (bool? newValue) {
                          setState(() {
                            select = newValue!;
                          });
                        },
                      ),
                      title: const Text("Show my orientation on my profile"),
                    ),
                    selected.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 40),
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
                                      "CONTINUE",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  widget.userData.addAll({
                                    "sexualOrientation": {'orientation': selected, 'showOnProfile': select},
                                  });
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => ShowGender(widget.userData),
                                    ),
                                  );
                                },
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 40),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: InkWell(
                                child: Container(
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
                                        color: secondryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  CustomSnackbar.snackbar("Please select one", context);
                                },
                              ),
                            ),
                          )
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
