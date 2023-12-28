import 'package:ally_4_u_client/screens/chat/chat.page.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'call.dart';

class Incoming extends StatefulWidget {
  final Map<String, dynamic> callInfo;

  const Incoming(this.callInfo, {super.key});

  @override
  State<Incoming> createState() => _IncomingState();
}

class _IncomingState extends State<Incoming> with TickerProviderStateMixin {
  CollectionReference callRef = FirebaseFirestore.instance.collection("calls");

  bool ispickup = false;
  late AnimationController _controller;

  FlutterRingtonePlayer flutterRingtonePlayer = FlutterRingtonePlayer();

  @override
  void initState() {
    super.initState();
    flutterRingtonePlayer.play(
      android: AndroidSounds.ringtone,
      ios: IosSounds.glass,
      looping: true,
      // Android only - API >= 28
      volume: 1,
      // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() async {
    _controller.dispose();
    flutterRingtonePlayer.stop();
    ispickup = true;
    await callRef.doc(widget.callInfo['channel_id']).update({'calling': false});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        body: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: callRef.where("channel_id", isEqualTo: "${widget.callInfo['channel_id']}").snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Container();
              } else {
                try {
                  if (snapshot.data?.docs[0]['calling']) {
                    switch (snapshot.data?.docs[0]['response']) {
                      //wait for pick the call
                      case "Awaiting":
                        {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                snapshot.data?.docs[0]['callType'] == "VideoCall" ? "Incoming Video Call" : "Incoming Audio Call",
                                style: TextStyle(
                                  color: accentColor,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AnimatedBuilder(
                                  animation: CurvedAnimation(parent: _controller, curve: Curves.slowMiddle),
                                  builder: (context, child) {
                                    return SizedBox(
                                      height: MediaQuery.of(context).size.height * .3,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          _buildContainer(150 * _controller.value),
                                          _buildContainer(200 * _controller.value),
                                          _buildContainer(250 * _controller.value),
                                          _buildContainer(300 * _controller.value),
                                          CircleAvatar(
                                            backgroundColor: Colors.grey,
                                            radius: 60,
                                            child: Center(
                                              child: ClipRRect(
                                                borderRadius: BorderRadius.circular(
                                                  60,
                                                ),
                                                child: CachedNetworkImage(
                                                  imageUrl: widget.callInfo['senderPicture'] ?? '',
                                                  useOldImageOnUrlChange: true,
                                                  placeholder: (context, url) => const CupertinoActivityIndicator(
                                                    radius: 15,
                                                  ),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  errorWidget: (context, url, error) => const Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Icon(
                                                        Icons.error,
                                                        color: Colors.black,
                                                        size: 30,
                                                      ),
                                                      Text(
                                                        "Enable to load",
                                                        style: TextStyle(
                                                          color: Colors.black,
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${widget.callInfo['senderName']} ",
                                    style: TextStyle(
                                      color: accentColor,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Shimmer.fromColors(
                                    baseColor: Colors.white,
                                    highlightColor: Colors.black,
                                    child: const Text(
                                      "is calling you...",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    FloatingActionButton(
                                      heroTag: UniqueKey(),
                                      backgroundColor: Colors.green,
                                      child: Icon(
                                        snapshot.data?.docs[0]['callType'] == "VideoCall" ? Icons.video_call : Icons.call,
                                        color: primaryColor,
                                      ),
                                      onPressed: () async {
                                        await handleCameraAndMic(snapshot.data?.docs[0]['callType']);
                                        ispickup = true;
                                        await callRef.doc(widget.callInfo['channel_id']).update({'response': "Pickup"});
                                        await flutterRingtonePlayer.stop();
                                      },
                                    ),
                                    FloatingActionButton(
                                      heroTag: UniqueKey(),
                                      backgroundColor: Colors.red,
                                      child: Icon(
                                        Icons.clear,
                                        color: primaryColor,
                                      ),
                                      onPressed: () async {
                                        await callRef.doc(widget.callInfo['channel_id']).update({'response': 'Decline'});
                                      },
                                    )
                                  ],
                                ),
                              ),
                            ],
                          );
                        }
                      // push video page with given channel name
                      case "Pickup":
                        {
                          return CallPage(
                            channelName: widget.callInfo['channel_id'],
                            callType: snapshot.data?.docs[0]['callType'],
                            fromDial: false,
                          );
                        }
                      //call end
                      default:
                        {
                          Future.delayed(
                            const Duration(milliseconds: 500),
                            () {
                              Navigator.pop(context);
                            },
                          );
                          return const Text("Call Ended...");
                        }
                    }
                  } else {
                    Future.delayed(
                      const Duration(milliseconds: 500),
                      () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                    );
                    return const Text("Call Ended...");
                  }
                } catch (e) {
                  return Container();
                }
              }

              // return const Text("Connecting...");
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withOpacity(1 - _controller.value),
      ),
    );
  }
}
