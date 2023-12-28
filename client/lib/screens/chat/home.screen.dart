import 'package:ally_4_u_client/screens/chat/recent.chat.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.model.dart';
import '../../util/theme.dart';
import 'matches.dart';

class HomeScreen extends StatefulWidget {
  final User currentUser;
  final List<User> matches;
  final List<User> newmatches;

  const HomeScreen({
    super.key,
    required this.currentUser,
    required this.matches,
    required this.newmatches,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.matches.isNotEmpty && widget.matches[0].lastmsg != null) {
        widget.matches.sort((a, b) {
          var adate = a.lastmsg; //before -> var adate = a.expiry;
          var bdate = b.lastmsg; //before -> var bdate = b.expiry;
          return bdate!.compareTo(adate!); //to get the order other way just switch `adate & bdate`
        });
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => SafeArea(
        child: Scaffold(
          // resizeToAvoidBottomInset: ,
          body: Container(
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
                // color: Colors.red,
                // color: notifier.darkTheme ? darkBackground : primaryColor,
                ),
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Messages',
                          style: TextStyle(
                            fontSize: 16,
                            color: notifier.darkTheme ? Colors.white : Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                            // color: Colors.white,
                          ),
                        ),
                        Container(
                          width: width * .11,
                          height: width * .11,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              // color: Colors.white.withOpacity(0.5),
                              color: notifier.darkTheme ? Colors.white : Colors.grey.shade500,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.filter_alt_rounded,
                            color: Color(0xffE94057),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * .02),
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: notifier.darkTheme ? const Color(0xff333333) : Colors.white,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xff333333),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xff333333),
                          ),
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.search_rounded),
                        ),
                        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      ),
                    ),
                    SizedBox(height: height * .02),
                    Matches(currentUser: widget.currentUser, matches: widget.newmatches),
                    SizedBox(height: height * .02),
                    Text(
                      'Messages',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        // color: Colors.white,
                        color: notifier.darkTheme ? Colors.white : Colors.grey.shade500,
                      ),
                    ),
                    SizedBox(height: height * .02),
                    RecentChats(currentUser: widget.currentUser, matches: widget.matches),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
