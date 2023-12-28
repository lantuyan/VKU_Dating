// ignore_for_file: prefer_typing_uninitialized_variables, empty_catches

import 'dart:io';

import 'package:ally_4_u_client/models/user.model.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  final User currentUser;

  const EditProfile({super.key, required this.currentUser});

  @override
  EditProfileState createState() => EditProfileState();
}

class EditProfileState extends State<EditProfile> {
  final TextEditingController aboutCtlr = TextEditingController();
  final TextEditingController companyCtlr = TextEditingController();
  final TextEditingController livingCtlr = TextEditingController();
  final TextEditingController jobCtlr = TextEditingController();
  final TextEditingController universityCtlr = TextEditingController();
  bool visibleAge = false;
  bool visibleDistance = true;

  var showMe;
  Map editInfo = {};

  @override
  void initState() {
    super.initState();
    aboutCtlr.text = widget.currentUser.editInfo?['about'] ?? '';
    companyCtlr.text = widget.currentUser.editInfo?['company'] ?? '';
    livingCtlr.text = widget.currentUser.editInfo?['living_in'] ?? '';
    universityCtlr.text = widget.currentUser.editInfo?['university'] ?? '';
    jobCtlr.text = widget.currentUser.editInfo?['job_title'] ?? '';
    setState(() {
      showMe = widget.currentUser.editInfo?['userGender'] ?? '';
      visibleAge = widget.currentUser.editInfo?['showMyAge'] ?? false;
      visibleDistance = widget.currentUser.editInfo?['DistanceVisible'] ?? true;
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if (editInfo.isNotEmpty) {
      updateData();
    }
  }

  Future updateData() async {
    FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.currentUser.id)
        .set({
      'editInfo': editInfo,
      'age': widget.currentUser.age,
    }, SetOptions(merge: true));
  }

  Future source(
      BuildContext context, currentUser, bool isProfilePicture) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Consumer<ThemeNotifier>(
          builder: (context, ThemeNotifier notifier, child) =>
              CupertinoAlertDialog(
            title: Text(
              isProfilePicture ? "Update profile picture" : "Add pictures",
            ),
            content: const Text(
              "Select source",
            ),
            insetAnimationCurve: Curves.decelerate,
            actions: currentUser.imageUrl.length < 9
                ? [
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.photo_camera,
                              size: 28,
                            ),
                            Text(
                              " Camera",
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    notifier.darkTheme ? lightText : darkText,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) {
                              getImage(
                                ImageSource.camera,
                                context,
                                currentUser,
                                isProfilePicture,
                              );
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: GestureDetector(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.photo_library,
                              size: 28,
                            ),
                            Text(
                              " Gallery",
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    notifier.darkTheme ? lightText : darkText,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              getImage(
                                ImageSource.gallery,
                                context,
                                currentUser,
                                isProfilePicture,
                              );
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    primaryColor,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ]
                : [
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.error),
                            Text(
                              "Can't upload more than 9 pictures",
                              style: TextStyle(
                                fontSize: 15,
                                color: darkText,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
          ),
        );
      },
    );
  }

  Future getImage(
      ImageSource imageSource, context, currentUser, isProfilePicture) async {
    // ignore: deprecated_member_use
    final picker = ImagePicker();
    // final cropper = ImageCropper();
    var image = await picker.pickImage(source: imageSource);
    if (image != null) {
      // CroppedFile? croppedFile = await cropper.cropImage(
      //   sourcePath: image.path,
      //   cropStyle: CropStyle.circle,
      //   aspectRatioPresets: [CropAspectRatioPreset.square],
      // );
      await uploadFile(
        File(image.path),
        currentUser,
        isProfilePicture,
      );
      // if (croppedFile != null) {
      //   await uploadFile(
      //     croppedFile as File,
      //     currentUser,
      //     isProfilePicture,
      //   );
      // }
    }
    Navigator.pop(context);
  }

  Future uploadFile(File image, User currentUser, isProfilePicture) async {
    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('users/${currentUser.id}/${image.hashCode}.jpg');
    UploadTask uploadTask = storageReference.putFile(image);
    uploadTask.whenComplete(
      () => storageReference.getDownloadURL().then(
        (fileURL) async {
          Map<String, dynamic> updateObject = {
            "Pictures": FieldValue.arrayUnion(
              [
                fileURL,
              ],
            )
          };
          try {
            if (isProfilePicture) {
              currentUser.imageUrl?.insert(0, fileURL);
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(currentUser.id)
                  .set(
                      {"Pictures": currentUser.imageUrl},
                      SetOptions(
                        merge: true,
                      ));
            } else {
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(currentUser.id)
                  .set(updateObject, SetOptions(merge: true));
              widget.currentUser.imageUrl?.add(fileURL);
            }
            if (mounted) setState(() {});
          } catch (err) {}
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Profile _profile = new Profile(widget.currentUser);
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => SafeArea(
        child: Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: Text(
              "Edit Profile",
              style: TextStyle(
                color: notifier.darkTheme ? lightText : mediumText,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              color: notifier.darkTheme ? lightText : mediumText,
              onPressed: () => Navigator.pop(context),
            ),
            backgroundColor: notifier.darkTheme ? darkBackground : primaryColor,
          ),
          body: Scaffold(
            body: Container(
              decoration: BoxDecoration(
                color: notifier.darkTheme ? darkBackground : primaryColor,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height * .65,
                      width: MediaQuery.of(context).size.width,
                      child: GridView.count(
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 3,
                        childAspectRatio:
                            MediaQuery.of(context).size.aspectRatio * 1.5,
                        crossAxisSpacing: 4,
                        padding: const EdgeInsets.all(10),
                        children: List.generate(
                          9,
                          (index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  decoration:
                                      widget.currentUser.imageUrl!.length >
                                              index
                                          ? BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            )
                                          : BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                style: BorderStyle.solid,
                                                width: 1,
                                                color: secondryColor,
                                              ),
                                            ),
                                  child: Stack(
                                    children: [
                                      widget.currentUser.imageUrl!.length >
                                              index
                                          ? CachedNetworkImage(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  .2,
                                              fit: BoxFit.cover,
                                              imageUrl: widget.currentUser
                                                      .imageUrl![index] ??
                                                  '',
                                              placeholder: (context, url) =>
                                                  const Center(
                                                child:
                                                    CupertinoActivityIndicator(
                                                  radius: 10,
                                                ),
                                              ),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      const Center(
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons.error,
                                                      color: Colors.black,
                                                      size: 25,
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
                                            )
                                          : Container(),
                                      // Center(
                                      //     child:
                                      //         widget.currentUser.imageUrl.length >
                                      //                 index
                                      //             ? CupertinoActivityIndicator(
                                      //                 radius: 10,
                                      //               )
                                      //             : Container()),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Container(
                                          // width: 12,
                                          // height: 16,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: widget.currentUser.imageUrl!
                                                        .length >
                                                    index
                                                ? primaryColor
                                                : accentColor,
                                          ),
                                          child: widget.currentUser.imageUrl!
                                                      .length >
                                                  index
                                              ? InkWell(
                                                  child: Icon(
                                                    Icons.cancel,
                                                    color: accentColor,
                                                    size: 22,
                                                  ),
                                                  onTap: () async {
                                                    if (widget.currentUser
                                                            .imageUrl!.length >
                                                        1) {
                                                      _deletePicture(index);
                                                    } else {
                                                      source(
                                                        context,
                                                        widget.currentUser,
                                                        true,
                                                      );
                                                    }
                                                  },
                                                )
                                              : InkWell(
                                                  child: const Icon(
                                                    Icons.add_circle_outline,
                                                    size: 22,
                                                    color: Colors.white,
                                                  ),
                                                  onTap: () => source(
                                                    context,
                                                    widget.currentUser,
                                                    false,
                                                  ),
                                                ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [
                              accentColor.withOpacity(.5),
                              accentColor.withOpacity(.8),
                              accentColor,
                              accentColor,
                            ],
                          ),
                        ),
                        height: 50,
                        width: 340,
                        child: Center(
                          child: Text(
                            "Add media",
                            style: TextStyle(
                              fontSize: 15,
                              color: notifier.darkTheme ? lightText : textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        await source(
                          context,
                          widget.currentUser,
                          false,
                        );
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListBody(
                        mainAxis: Axis.vertical,
                        children: [
                          ListTile(
                            title: Text(
                              "About ${widget.currentUser.name}",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: notifier.darkTheme
                                    ? lightText
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: CupertinoTextField(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: notifier.darkTheme
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                              ),
                              controller: aboutCtlr,
                              cursorColor: accentColor,
                              style: TextStyle(
                                color: notifier.darkTheme
                                    ? Colors.white
                                    : darkText,
                              ),
                              placeholderStyle: TextStyle(
                                color:
                                    notifier.darkTheme ? lightText : darkText,
                              ),
                              maxLines: 10,
                              minLines: 3,
                              placeholder: "About you",
                              padding: const EdgeInsets.all(10),
                              onChanged: (text) {
                                editInfo.addAll({'about': text});
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              "Job title",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: notifier.darkTheme
                                    ? lightText
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: CupertinoTextField(
                              controller: jobCtlr,
                              cursorColor: accentColor,
                              style: TextStyle(
                                color: notifier.darkTheme
                                    ? Colors.white
                                    : darkText,
                              ),
                              placeholderStyle: TextStyle(
                                color:
                                    notifier.darkTheme ? lightText : darkText,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: notifier.darkTheme
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                              ),
                              placeholder: "Add job title",
                              padding: const EdgeInsets.all(10),
                              onChanged: (text) {
                                editInfo.addAll({'job_title': text});
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              "Company",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: notifier.darkTheme
                                    ? lightText
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: CupertinoTextField(
                              controller: companyCtlr,
                              cursorColor: accentColor,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: notifier.darkTheme
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                              ),
                              style: TextStyle(
                                color: notifier.darkTheme
                                    ? Colors.white
                                    : darkText,
                              ),
                              placeholderStyle: TextStyle(
                                color:
                                    notifier.darkTheme ? lightText : darkText,
                              ),
                              placeholder: "Add company",
                              padding: const EdgeInsets.all(10),
                              onChanged: (text) {
                                editInfo.addAll({'company': text});
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              "University",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: notifier.darkTheme
                                    ? lightText
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: CupertinoTextField(
                              controller: universityCtlr,
                              cursorColor: accentColor,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: notifier.darkTheme
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                              ),
                              style: TextStyle(
                                color: notifier.darkTheme
                                    ? Colors.white
                                    : darkText,
                              ),
                              placeholderStyle: TextStyle(
                                color:
                                    notifier.darkTheme ? lightText : darkText,
                              ),
                              placeholder: "Add university",
                              padding: const EdgeInsets.all(10),
                              onChanged: (text) {
                                editInfo.addAll({'university': text});
                              },
                            ),
                          ),
                          ListTile(
                            title: Text(
                              "Living in",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: notifier.darkTheme
                                    ? lightText
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: CupertinoTextField(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: notifier.darkTheme
                                      ? Colors.white
                                      : Colors.grey.shade500,
                                ),
                              ),
                              controller: livingCtlr,
                              cursorColor: accentColor,
                              style: TextStyle(
                                color: notifier.darkTheme
                                    ? Colors.white
                                    : darkText,
                              ),
                              placeholderStyle: TextStyle(
                                color:
                                    notifier.darkTheme ? lightText : darkText,
                              ),
                              placeholder: "Add city",
                              padding: const EdgeInsets.all(10),
                              onChanged: (text) {
                                editInfo.addAll({'living_in': text});
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ListTile(
                              title: Text(
                                "I am",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: notifier.darkTheme
                                      ? lightText
                                      : Colors.black87,
                                ),
                              ),
                              subtitle: DropdownButton(
                                iconEnabledColor: accentColor,
                                iconDisabledColor: secondryColor,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: "man",
                                    child: Text("Man"),
                                  ),
                                  DropdownMenuItem(
                                      value: "woman", child: Text("Woman")),
                                  DropdownMenuItem(
                                      value: "other", child: Text("Other")),
                                ],
                                onChanged: (val) {
                                  editInfo.addAll({'userGender': val});
                                  setState(() {
                                    showMe = val;
                                  });
                                },
                                value: showMe,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            title: Text(
                              "Control your profile",
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: notifier.darkTheme
                                    ? lightText
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: Card(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Don't Show My Age"),
                                      ),
                                      Switch(
                                        activeColor: accentColor,
                                        value: visibleAge,
                                        onChanged: (value) {
                                          editInfo.addAll({'showMyAge': value});
                                          setState(
                                            () {
                                              visibleAge = value;
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Text("Make My Distance Visible"),
                                      ),
                                      Switch(
                                        activeColor: accentColor,
                                        value: visibleDistance,
                                        onChanged: (value) {
                                          editInfo.addAll(
                                              {'DistanceVisible': value});
                                          setState(
                                            () {
                                              visibleDistance = value;
                                            },
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 100,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deletePicture(index) async {
    if (widget.currentUser.imageUrl![index] != null) {
      try {
        Reference ref = FirebaseStorage.instance
            .refFromURL(widget.currentUser.imageUrl![index]);
        await ref.delete(); 
      } catch (e) {}
    }
    setState(
      () {
        widget.currentUser.imageUrl?.removeAt(index);
      },
    );
    var temp = [];
    temp.add(widget.currentUser.imageUrl);
    await FirebaseFirestore.instance
        .collection("Users")
        .doc(widget.currentUser.id)
        .set({"Pictures": temp[0]}, SetOptions(merge: true));
  }
}
