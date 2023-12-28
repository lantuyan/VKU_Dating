import 'package:ally_4_u_client/util/color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'gender.dart';
import 'util/theme.dart';

class UserDOB extends StatefulWidget {
  final Map<String, dynamic> userData;
  const UserDOB(this.userData, {super.key});

  @override
  State<UserDOB> createState() => _UserDOBState();
}

class _UserDOBState extends State<UserDOB> {
  late DateTime selecteddate;
  TextEditingController dobctlr = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        floatingActionButton: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 50),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: FloatingActionButton(
              elevation: 10,
              backgroundColor: accentColor,
              onPressed: () {
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
        body: SingleChildScrollView(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Stack(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 50, top: 120),
                      child: Text(
                        "My\nbirthday is",
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: ListTile(
                    title: CupertinoTextField(
                      readOnly: true,
                      keyboardType: TextInputType.phone,
                      prefix: IconButton(
                        icon: (Icon(
                          Icons.calendar_today,
                          color: accentColor,
                        )),
                        onPressed: () {},
                      ),
                      onTap: () => showCupertinoModalPopup(
                        context: context,
                        builder: (BuildContext context) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height * .25,
                            child: GestureDetector(
                              child: Theme(
                                data: ThemeData(colorScheme: notifier.darkTheme ? const ColorScheme.light() : const ColorScheme.dark()),
                                child: CupertinoDatePicker(
                                  backgroundColor: Colors.white,
                                  initialDateTime: DateTime(2000, 10, 12),
                                  onDateTimeChanged: (DateTime newdate) {
                                    setState(
                                      () {
                                        dobctlr.text = '${newdate.day}/${newdate.month}/${newdate.year}';
                                        selecteddate = newdate;
                                      },
                                    );
                                  },
                                  maximumYear: 2002,
                                  minimumYear: 1800,
                                  maximumDate: DateTime(2002, 03, 12),
                                  mode: CupertinoDatePickerMode.date,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          );
                        },
                      ),
                      style: TextStyle(
                        color: notifier.darkTheme ? lightText : mediumText,
                      ),
                      placeholderStyle: TextStyle(
                        color: notifier.darkTheme ? lightText : const Color(0xfff55555),
                      ),
                      placeholder: "DD/MM/YYYY",
                      controller: dobctlr,
                    ),
                    subtitle: const Text(" Your age will be public"),
                  ),
                ),
                dobctlr.text.isNotEmpty
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
                                  style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            onTap: () {
                              widget.userData.addAll(
                                {
                                  'user_DOB': "$selecteddate",
                                  'age': ((DateTime.now().difference(selecteddate).inDays) / 365.2425).truncate(),
                                },
                              );
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => Gender(widget.userData),
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
                          ),
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
