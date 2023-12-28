import 'dart:io';
import 'dart:math';

import 'package:ally_4_u_client/models/user.model.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../information.dart';
import '../../report.user.dart';
import '../../util/color.dart';
import '../../util/snackbar.dart';
import '../../util/theme.dart';
import '../calling/dial.dart';
import 'large.image.dart';

class ChatPage extends StatefulWidget {
  final User sender;
  final String? chatId;
  final User second;

  const ChatPage({super.key, required this.sender, this.chatId, required this.second});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  bool isBlocked = false;
  final db = FirebaseFirestore.instance;
  late CollectionReference chatReference;
  final TextEditingController _textController = TextEditingController();
  bool _isWritting = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    chatReference = db.collection("chats").doc(widget.chatId).collection('messages');
    checkblock();
  }

  // ignore: prefer_typing_uninitialized_variables
  var blockedBy;

  checkblock() {
    chatReference.doc('blocked').snapshots().listen(
      (onData) {
        blockedBy = onData.data().toString().contains('blockedBy') ? onData.get('blockedBy') : '';
        if (onData.data().toString().contains('blockedBy') && onData.get('blockedBy')) {
          isBlocked = true;
        } else {
          isBlocked = false;
        }

        if (mounted) setState(() {});
      },
    );
  }

  List<Widget> generateSenderLayout(DocumentSnapshot documentSnapshot) {
    return <Widget>[
      Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                child: documentSnapshot.get('image_url') != ''
                    ? Bubble(
                        nip: BubbleNip.rightBottom,
                        style: BubbleStyle(
                          color: secondryColor.withOpacity(.5),
                          elevation: 0,
                        ),
                        child: InkWell(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                height: 150,
                                width: 150.0,
                                child: Stack(
                                  children: [
                                    CachedNetworkImage(
                                      placeholder: (context, url) => const Center(
                                        child: CupertinoActivityIndicator(
                                          radius: 10,
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => const Icon(Icons.error),
                                      height: MediaQuery.of(context).size.height * .65,
                                      width: MediaQuery.of(context).size.width * .9,
                                      imageUrl: documentSnapshot.get('image_url') ?? '',
                                      fit: BoxFit.fitWidth,
                                    ),
                                    Container(
                                      alignment: Alignment.bottomRight,
                                      child: documentSnapshot.get('isRead') == false
                                          ? Icon(
                                              Icons.done,
                                              color: secondryColor,
                                              size: 15,
                                            )
                                          : Icon(
                                              Icons.done_all,
                                              color: accentColor,
                                              size: 15,
                                            ),
                                    )
                                  ],
                                ),
                              ),
                              Text(
                                documentSnapshot.get("time") != null
                                    ? DateFormat.yMMMd().add_jm().format(documentSnapshot.get("time").toDate()).toString()
                                    : "",
                                style: TextStyle(
                                  color: secondryColor,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => LargeImage(
                                  documentSnapshot.get('image_url'),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Bubble(
                        stick: false,
                        margin: const BubbleEdges.only(
                          left: 80.0,
                          right: 2,
                        ),
                        padding: const BubbleEdges.symmetric(
                          horizontal: 15.0,
                          vertical: 10.0,
                        ),
                        nip: BubbleNip.rightBottom,
                        style: BubbleStyle(
                          color: notifier.darkTheme ? accentColor.withOpacity(.3) : accentColor.withOpacity(.1),
                          elevation: 0,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    documentSnapshot.get('text'),
                                    style: TextStyle(
                                      color: notifier.darkTheme ? lightText : darkText,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      documentSnapshot.get("time") != null
                                          ? DateFormat.MMMd().add_jm().format(documentSnapshot.get("time").toDate()).toString()
                                          : "",
                                      style: TextStyle(
                                        color: secondryColor,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    documentSnapshot.get('isRead') == false
                                        ? Icon(
                                            Icons.done,
                                            color: secondryColor,
                                            size: 15,
                                          )
                                        : Icon(
                                            Icons.done_all,
                                            color: accentColor,
                                            size: 15,
                                          )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  _messagesIsRead(documentSnapshot) {
    return <Widget>[
      Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              child: CircleAvatar(
                backgroundColor: secondryColor,
                radius: 25.0,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(90),
                  child: CachedNetworkImage(
                    imageUrl: widget.second.imageUrl![0] ?? '',
                    useOldImageOnUrlChange: true,
                    placeholder: (context, url) => const CupertinoActivityIndicator(
                      radius: 15,
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
              onTap: () => showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return Info(
                    user: widget.second,
                    currentUser: widget.sender,
                    isNotification: false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
      Consumer<ThemeNotifier>(
        builder: (context, ThemeNotifier notifier, child) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: documentSnapshot.data().toString().contains('image_url') && documentSnapshot.get('image_url') != ''
                    ? Bubble(
                        style: BubbleStyle(
                          color: notifier.darkTheme ? secondryColor : const Color.fromRGBO(0, 0, 0, 0.2),
                          elevation: 0,
                        ),
                        nip: BubbleNip.leftBottom,
                        child: InkWell(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                height: 150,
                                width: 150.0,
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => const Center(
                                    child: CupertinoActivityIndicator(
                                      radius: 10,
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                  height: MediaQuery.of(context).size.height * .65,
                                  width: MediaQuery.of(context).size.width * .9,
                                  imageUrl: documentSnapshot.data['image_url'] ?? '',
                                  fit: BoxFit.fitWidth,
                                ),
                              ),
                              Text(
                                documentSnapshot.data["time"] != null
                                    ? DateFormat.yMMMd().add_jm().format(documentSnapshot.data["time"].toDate()).toString()
                                    : "",
                                style: TextStyle(
                                  color: darkText,
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            ],
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              CupertinoPageRoute(
                                builder: (context) => LargeImage(
                                  documentSnapshot.data['image_url'],
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Bubble(
                        padding: const BubbleEdges.symmetric(
                          horizontal: 15.0,
                          vertical: 10.0,
                        ),
                        margin: const BubbleEdges.only(
                          left: 2,
                          right: 50.0,
                        ),
                        nip: BubbleNip.leftBottom,
                        style: BubbleStyle(
                          color: secondryColor.withOpacity(.3),
                          elevation: 0,
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    documentSnapshot.data().toString().contains('text') ? documentSnapshot.get('text') : '',
                                    style: TextStyle(
                                      color: notifier.darkTheme ? lightText : darkText,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      documentSnapshot.data().toString().contains("time")
                                          ? DateFormat.MMMd().add_jm().format(documentSnapshot.get("time").toDate()).toString()
                                          : "",
                                      style: TextStyle(
                                        color: secondryColor,
                                        fontSize: 13.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> generateReceiverLayout(DocumentSnapshot documentSnapshot) {
    if (!documentSnapshot.get('isRead')) {
      chatReference.doc(documentSnapshot.id).update({
        'isRead': true,
      });

      return _messagesIsRead(documentSnapshot);
    }
    return _messagesIsRead(documentSnapshot);
  }

  generateMessages(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data?.docs
        .map<Widget>(
          (doc) => Container(
            margin: const EdgeInsets.symmetric(vertical: 10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: doc.get('type') == "Call"
                  ? [
                      Bubble(
                        stick: false,
                        margin: const BubbleEdges.symmetric(horizontal: 20),
                        style: BubbleStyle(
                          color: const Color(0xff555555).withOpacity(0.3),
                          elevation: 0,
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          child: Text(
                            doc.get("time") != null
                                ? "${doc.get('text')} : ${DateFormat.yMMMd().add_jm().format(doc.get("time").toDate())} by ${doc.get('sender_id') == widget.sender.id ? "You" : widget.second.name}"
                                : "",
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                    ]
                  : doc.get('sender_id') != widget.sender.id
                      ? generateReceiverLayout(
                          doc,
                        )
                      : generateSenderLayout(
                          doc,
                        ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: notifier.darkTheme ? darkAppbarColor : primaryColor,
          centerTitle: false,
          elevation: 1,
          title: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.second.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: notifier.darkTheme ? lightText : darkText,
                ),
              ),
              widget.second.isOnline!
                  ? Text(
                      'online',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                      ),
                    )
                  : Text(
                      'last seen ${DateFormat.MMMd().add_jm().format(widget.second.lastSeen!.toDate()).toString()}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                    ),
            ],
          ),
          titleSpacing: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: notifier.darkTheme ? lightText : mediumText,
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(icon: const Icon(Icons.call), onPressed: () => onJoin("AudioCall")),
            IconButton(icon: const Icon(Icons.video_call), onPressed: () => onJoin("VideoCall")),
            PopupMenuButton(
              itemBuilder: (ct) {
                return [
                  PopupMenuItem(
                    value: 'value1',
                    child: InkWell(
                      onTap: () => showDialog(
                        barrierDismissible: true,
                        context: context,
                        builder: (context) => ReportUser(
                          currentUser: widget.sender,
                          seconduser: widget.second,
                        ),
                      ).then(
                        (value) => Navigator.pop(ct),
                      ),
                      child: const SizedBox(
                        width: 100,
                        height: 30,
                        child: Text(
                          "Report",
                        ),
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    height: 30,
                    value: 'value2',
                    child: InkWell(
                      child: Text(isBlocked ? "Unblock user" : "Block user"),
                      onTap: () {
                        Navigator.pop(ct);
                        showDialog(
                          context: context,
                          builder: (BuildContext ctx) {
                            return AlertDialog(
                              title: Text(isBlocked ? 'Unblock' : 'Block'),
                              content: Text('Do you want to ${isBlocked ? 'Unblock' : 'Block'} ${widget.second.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(false),
                                  child: const Text('No'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(ctx);
                                    if (isBlocked && blockedBy == widget.sender.id) {
                                      chatReference.doc('blocked').set(
                                        {
                                          'isBlocked': !isBlocked,
                                          'blockedBy': widget.sender.id,
                                        },
                                      );
                                    } else if (!isBlocked) {
                                      chatReference.doc('blocked').set(
                                        {
                                          'isBlocked': !isBlocked,
                                          'blockedBy': widget.sender.id,
                                        },
                                      );
                                    } else {
                                      CustomSnackbar.snackbar("You can't unblock", context);
                                    }
                                  },
                                  child: const Text('Yes'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  )
                ];
              },
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                color: notifier.darkTheme ? darkBackground : primaryColor,
              ),
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: chatReference.orderBy('time', descending: true).snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (!snapshot.hasData) {
                        return SizedBox(
                          height: 15,
                          width: 15,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(primaryColor),
                            strokeWidth: 2,
                          ),
                        );
                      }
                      return Expanded(
                        child: ListView(
                          reverse: true,
                          children: generateMessages(snapshot),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1.0),
                  Container(
                    alignment: Alignment.bottomCenter,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isBlocked ? const Text("Sorry You can't send message!") : _buildTextComposer(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget getDefaultSendButton() {
    return IconButton(
      icon: Transform.rotate(
        angle: -pi / 9,
        child: const Icon(
          Icons.send,
          size: 25,
        ),
      ),
      color: accentColor,
      onPressed: _isWritting ? () => _sendText(_textController.text.trimRight()) : null,
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: _isWritting ? accentColor : secondryColor),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: Icon(
                  Icons.photo_camera,
                  color: accentColor,
                ),
                onPressed: () async {
                  // ignore: deprecated_member_use
                  final picker = ImagePicker();
                  var image =
                      // ignore: deprecated_member_use
                      await picker.pickImage(source: ImageSource.gallery);
                  int timestamp = DateTime.now().millisecondsSinceEpoch;
                  Reference storageReference = FirebaseStorage.instance.ref().child('chats/${widget.chatId}/img_$timestamp.jpg');
                  File imageFile = File(image!.path);
                  UploadTask uploadTask = storageReference.putFile(imageFile);
                  await uploadTask;
                  print("File Uploaded");
                  String fileUrl = await storageReference.getDownloadURL();
                  _sendImage(messageText: 'Photo', imageUrl: fileUrl);
                },
              ),
            ),
            Flexible(
              child: TextField(
                controller: _textController,
                maxLines: 15,
                minLines: 1,
                autofocus: false,
                onChanged: (String messageText) {
                  setState(
                    () {
                      _isWritting = messageText.trim().isNotEmpty;
                    },
                  );
                },
                decoration: const InputDecoration.collapsed(
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  // border: OutlineInputBorder(
                  //     borderRadius: BorderRadius.circular(18)),
                  hintText: "Send a message...",
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: getDefaultSendButton(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendText(String text) async {
    _textController.clear();
    chatReference.add(
      {
        'type': 'Msg',
        'text': text,
        'sender_id': widget.sender.id,
        'receiver_id': widget.second.id,
        'isRead': false,
        'image_url': '',
        'time': FieldValue.serverTimestamp(),
      },
    ).then(
      (documentReference) {
        setState(
          () {
            _isWritting = false;
          },
        );
      },
    ).catchError((e) {});
  }

  void _sendImage({required String messageText, required String imageUrl}) {
    chatReference.add(
      {
        'type': 'Image',
        'text': messageText,
        'sender_id': widget.sender.id,
        'receiver_id': widget.second.id,
        'isRead': false,
        'image_url': imageUrl,
        'time': FieldValue.serverTimestamp(),
      },
    );
  }

  Future<void> onJoin(callType) async {
    if (!isBlocked) {
      // await for camera and mic permissions before pushing video page

      await handleCameraAndMic(callType);
      await chatReference.add(
        {
          'type': 'Call',
          'text': callType,
          'sender_id': widget.sender.id,
          'receiver_id': widget.second.id,
          'isRead': false,
          'image_url': "",
          'time': FieldValue.serverTimestamp(),
        },
      );

      // push video page with given channel name
      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DialCall(
            channelName: widget.chatId!,
            receiver: widget.second,
            callType: callType,
          ),
        ),
      );
    } else {
      CustomSnackbar.snackbar("Blocked !", context);
    }
  }
}

Future<void> handleCameraAndMic(callType) async {
  await callType == "VideoCall"
      ? [Permission.microphone, Permission.camera].request()
      : [
          Permission.microphone,
        ];
}
