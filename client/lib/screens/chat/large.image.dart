import 'package:ally_4_u_client/util/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../util/color.dart';

class LargeImage extends StatelessWidget {
  // ignore: prefer_typing_uninitialized_variables
  final largeImage;

  const LargeImage(this.largeImage, {super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: notifier.darkTheme ? lightText : mediumText,
          ),
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: notifier.darkTheme ? darkBackground : primaryColor,
        ),
        body: Container(
          decoration: BoxDecoration(
            color: notifier.darkTheme ? darkBackground : primaryColor,
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CachedNetworkImage(
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CupertinoActivityIndicator(
                        radius: 20,
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                    height: MediaQuery.of(context).size.height * .75,
                    width: MediaQuery.of(context).size.width,
                    imageUrl: largeImage ?? '',
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  FloatingActionButton(
                    backgroundColor: accentColor,
                    child: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
