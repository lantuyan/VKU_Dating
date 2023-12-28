import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/user.model.dart';
import 'call.dart';

class DialCall extends StatefulWidget {
  final String channelName;
  final User? receiver;
  final String? callType;

  const DialCall({
    super.key,
    required this.channelName,
    this.receiver,
    this.callType,
  });

  @override
  State<DialCall> createState() => _DialCallState();
}

class _DialCallState extends State<DialCall> {
  bool ispickup = false;

  //final db = Firestore.instance;
  CollectionReference callRef = FirebaseFirestore.instance.collection("calls");

  @override
  void initState() {
    _addCallingData();
    super.initState();
  }

  _addCallingData() async {
    await callRef.doc(widget.channelName).delete();
    await callRef.doc(widget.channelName).set(
      {'callType': widget.callType, 'calling': true, 'response': "Awaiting", 'channel_id': widget.channelName, 'last_call': FieldValue.serverTimestamp()},
    );
  }

  @override
  void dispose() async {
    super.dispose();
    ispickup = true;
    await callRef.doc(widget.channelName).set({'calling': false, 'response': 'Ended'}, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        body: Center(
          child: StreamBuilder<QuerySnapshot>(
            stream: callRef.where("channel_id", isEqualTo: widget.channelName).snapshots(),
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              Future.delayed(
                const Duration(seconds: 30),
                () async {
                  if (!ispickup) {
                    await callRef.doc(widget.channelName).update({'response': 'Not-answer'});
                  }
                },
              );
              if (!snapshot.hasData) {
                return Container();
              } else {
                try {
                  switch (snapshot.data?.docs[0]['response']) {
                    case "Awaiting":
                      {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.grey,
                              radius: 60,
                              child: Center(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    60,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: widget.receiver?.imageUrl![0] ?? '',
                                    useOldImageOnUrlChange: true,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (context, url) => const CupertinoActivityIndicator(
                                      radius: 15,
                                    ),
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
                            Text(
                              "Calling to ${widget.receiver?.name}...",
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FloatingActionButton(
                              backgroundColor: accentColor,
                              onPressed: () async {
                                await callRef.doc(widget.channelName).set(
                                  {'response': "Call_Cancelled"},
                                  SetOptions(merge: true),
                                );
                                // Navigator.pop(context);
                              },
                              child: const Icon(Icons.call_end),
                            ),
                          ],
                        );
                      }
                    case "Pickup":
                      {
                        ispickup = true;
                        return CallPage(
                          channelName: widget.channelName,
                          callType: widget.callType!,
                          fromDial: true,
                        );
                      }
                    case "Decline":
                      {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${widget.receiver?.name} is Busy",
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FloatingActionButton(
                              backgroundColor: accentColor,
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back),
                            ),
                          ],
                        );
                      }
                    case "Not-answer":
                      {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "${widget.receiver?.name} is Not-answering",
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            FloatingActionButton(
                              backgroundColor: accentColor,
                              onPressed: () async {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back),
                            ),
                          ],
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
                }
                //  else if (!snapshot.data.documents[0]['calling']) {
                //   Navigator.pop(context);
                // }
                catch (e) {
                  return Container();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
