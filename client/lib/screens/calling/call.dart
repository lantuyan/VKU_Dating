import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:ally_4_u_client/screens/calling/util/settings.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CallPage extends StatefulWidget {
  final String channelName;
  final String callType;
  final bool fromDial;

  const CallPage({
    super.key,
    required this.channelName,
    required this.callType,
    required this.fromDial,
  });

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  late RtcEngine _engine;
  bool isJoined = false, remoteUserJoined = false, openMicrophone = true, enableSpeakerphone = true, playEffect = false, muted = false;
  int? remoteUserId;

  List tokens = [];

  CollectionReference callRef = FirebaseFirestore.instance.collection("calls");

  bool disable = true;

  RtcEngineEventHandler? _rtcEngineEventHandler;

  _initEngine() async {
    callRef.doc(widget.channelName).get().then(
      (DocumentSnapshot snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          log(data['tokens'].toString(), name: 'tokens_log');
          if (data.containsKey('tokens')) {
            tokens.addAll(data['tokens']);
          }
          if (mounted) setState(() {});
        }
      },
    );
    _engine = createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: appId,
      channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
    ));

    _rtcEngineEventHandler = RtcEngineEventHandler(
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint('joinChannelSuccess ${widget.channelName} ${connection.localUid} $elapsed');
        setState(() {
          isJoined = true;
        });
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) {
        log(rUid.toString(), name: 'on_user_log');
        setState(() {
          remoteUserJoined = true;
        });
      },
      onUserOffline: (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
        setState(() {
          remoteUserJoined = false;
          remoteUserId = rUid;
        });
        _leaveChannel();
        _onCallEnd(context);
      },
      onError: (ErrorCodeType e, String r) {
        log(e.name, name: 'agora_error_log');
        log(r, name: 'agora_error_log');
      },
      onLeaveChannel: (_, s) async {
        debugPrint('leaveChannel ${s.toJson()}');
        if (mounted) {
          setState(() {
            isJoined = false;
            remoteUserJoined = false;
          });
        }
      },
    );
    if (widget.callType == 'VideoCall') {
      await _engine.enableVideo();
    } else {
      await _engine.enableAudio();
    }
    await _engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await _engine.startPreview();
    if (_rtcEngineEventHandler != null) _engine.registerEventHandler(_rtcEngineEventHandler!);
    if (tokens.isNotEmpty) {
      await _engine
          .joinChannel(
        token: widget.fromDial ? tokens.first : tokens.last,
        channelId: widget.channelName,
        uid: widget.fromDial ? 1 : 2,
        options: const ChannelMediaOptions(
          channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      )
          .catchError((onError) {
        debugPrint('error ${onError.toString()}');
      }).then(
        (_) async {
          await _engine.enableAudio();
        },
      );
    }
  }

  _leaveChannel() async {
    try {
      if (_rtcEngineEventHandler != null) _engine.unregisterEventHandler(_rtcEngineEventHandler!);
      await _engine.leaveChannel();
      await _engine.release();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    _engine.muteLocalAudioStream(muted);
  }

  _disVideo() {
    setState(() {
      disable = !disable;
    });
    _engine.enableLocalVideo(disable);
  }

  @override
  void initState() {
    _initEngine();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _leaveChannel();
  }

  void _onSwitchCamera() {
    _engine.switchCamera();
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  Widget _audioToolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: _onToggleMute,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? accentColor : primaryColor,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? primaryColor : accentColor,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.call_end,
              color: primaryColor,
              size: 35.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _videoToolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RawMaterialButton(
            onPressed: _onToggleMute,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? accentColor : primaryColor,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? primaryColor : accentColor,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
            child: Icon(
              Icons.call_end,
              color: primaryColor,
              size: 35.0,
            ),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: primaryColor,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.switch_camera,
              color: accentColor,
              size: 20.0,
            ),
          ),
          RawMaterialButton(
            onPressed: _disVideo,
            shape: const CircleBorder(),
            elevation: 2.0,
            fillColor: !disable ? accentColor : primaryColor,
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              disable ? Icons.videocam : Icons.videocam_off,
              color: disable ? accentColor : primaryColor,
              size: 20.0,
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: Center(
        child: Stack(
          children: [
            if (widget.callType == "VideoCall") _remoteVideo(),
            if (widget.callType == "VideoCall")
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  width: 100,
                  height: 150,
                  margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 10),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(4, 0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: isJoined
                        ? AgoraVideoView(
                            controller: VideoViewController(
                              rtcEngine: _engine,
                              canvas: VideoCanvas(uid: widget.fromDial ? 1 : 2),
                            ),
                          )
                        : const CircularProgressIndicator(),
                  ),
                ),
              )
            else
              Container(
                alignment: Alignment.center,
                child: Icon(
                  Icons.person,
                  size: 60,
                  color: accentColor,
                ),
              ),
            widget.callType == "VideoCall" ? _videoToolbar() : _audioToolbar(),
          ],
        ),
      ),
    );
  }

  // Display remote user's video
  Widget _remoteVideo() {
    if (remoteUserJoined) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: widget.fromDial ? 2 : 1),
          connection: RtcConnection(channelId: widget.channelName),
        ),
      );
    } else {
      return const Center(
        child: Text(
          'Please wait for remote user to join',
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}
