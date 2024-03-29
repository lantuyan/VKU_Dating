import 'package:allt_4_u_admin/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SubscriptionSettings extends StatefulWidget {
  @override
  _SubscriptionSettingsState createState() => _SubscriptionSettingsState();
}

class _SubscriptionSettingsState extends State<SubscriptionSettings> {
  TextEditingController freeRctlr = TextEditingController();
  TextEditingController paidRctlr = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController freeSwipectlr = TextEditingController();
  bool isLargeScreen = false;
  final collectionReference = FirebaseFirestore.instance.collection("Item_access");

  TextEditingController paidSwipectlr = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool isNumeric(String s) {
    return int.tryParse(s) != null;
  }

  Map<String, dynamic> data = {};
  bool edit = false;

  @override
  void initState() {
    _getAccessItems();
    super.initState();
  }

  ///Get paid or free item range
  Map items = {};

  _getAccessItems() async {
    print(items.length);
    collectionReference.snapshots().listen((doc) {
      items = doc.docs.isNotEmpty ? doc.docs[0].data() : {};
      if (mounted)
        setState(() {
          freeRctlr.text = items['free_radius'] ?? '';
          paidRctlr.text = items['paid_radius'] ?? '';
          freeSwipectlr.text = items['free_swipes'] ?? '';
        });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Subscription settings",
          style: TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 25,
            color: Colors.white,
          ),
        ),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          if (MediaQuery.of(context).size.width > 600) {
            isLargeScreen = true;
          } else {
            isLargeScreen = false;
          }
          return Stack(
            children: [
              Positioned(
                top: 10,
                right: 10,
                child: !edit
                    ? ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        icon: Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.white,
                        ),
                        label: Text(
                          "edit",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () {
                          setState(
                            () {
                              edit = true;
                            },
                          );
                        },
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Color(0xfff0f0f0),
                        ),
                        onPressed: () {
                          setState(
                            () {
                              edit = false;
                            },
                          );
                        },
                      ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: edit
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          "Save Changes",
                          style: TextStyle(color: Colors.white),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState != null && _formKey.currentState!.validate()) {
                            _formKey.currentState?.save();

                            print(data);
                            setState(
                              () {
                                edit = false;
                              },
                            );
                            await collectionReference.doc('free-paid').set(data, SetOptions(merge: true)).whenComplete(
                                  () => snackbar(
                                    "Updated Sucessfully",
                                    context,
                                  ),
                                );
                          }
                        },
                      )
                    : Container(),
              ),
              Padding(
                padding: isLargeScreen ? EdgeInsets.all(48.0) : EdgeInsets.all(5),
                child: Align(
                  alignment: Alignment.center,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: edit
                                  ? TextFormField(
                                      controller: freeRctlr,
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return 'Please enter this field';
                                        } else if (value != null && !isNumeric(value)) {
                                          return 'Enter an integar value';
                                        }
                                        return null;
                                      },
                                      autofocus: false,
                                      cursorColor: Theme.of(context).primaryColor,
                                      decoration: InputDecoration(
                                        helperText: "this is how it will appear in app",
                                        labelText: "Free Radius(Kms.)",
                                        hintText: "Free Radius(Kms.)",
                                      ),
                                      onSaved: (value) {
                                        data['free_radius'] = value;
                                      },
                                    )
                                  : Card(
                                      elevation: 5,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: ListTile(
                                        dense: !isLargeScreen,
                                        leading: Icon(
                                          Icons.location_searching,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        title: Text(
                                          "Free radius access(in kms.)",
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: Text("${freeRctlr.text.length > 0 ? freeRctlr.text : "-----"} km"),
                                      ),
                                    ),
                            ),
                            SizedBox(
                              width: isLargeScreen
                                  ? MediaQuery.of(context).size.width * .1
                                  : MediaQuery.of(context).size.width * .01,
                            ),
                            Expanded(
                              child: edit
                                  ? TextFormField(
                                      controller: paidRctlr,
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return 'Please enter this field';
                                        } else if (value != null && !isNumeric(value)) {
                                          return 'Enter an integar value';
                                        }
                                        return null;
                                      },
                                      autofocus: false,
                                      cursorColor: Theme.of(context).primaryColor,
                                      decoration: InputDecoration(
                                        helperText: "this is how it will appear in app",
                                        labelText: "Paid Radius(Kms.)",
                                        hintText: "Paid Radius(Kms.)",
                                      ),
                                      onSaved: (value) {
                                        data['paid_radius'] = value;
                                      },
                                    )
                                  : Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 5,
                                      child: ListTile(
                                        dense: !isLargeScreen,
                                        leading: Icon(
                                          Icons.location_searching,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        title: Text("Paid radius access(in kms.)", overflow: TextOverflow.ellipsis),
                                        subtitle: Text("${paidRctlr.text.length > 0 ? paidRctlr.text : "-----"} km"),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              child: edit
                                  ? TextFormField(
                                      controller: freeSwipectlr,
                                      validator: (value) {
                                        if (value != null && value.isEmpty) {
                                          return 'Please enter this field';
                                        } else if (value != null && !isNumeric(value)) {
                                          return 'Enter an integar value';
                                        }
                                        return null;
                                      },
                                      autofocus: false,
                                      cursorColor: Theme.of(context).primaryColor,
                                      decoration: InputDecoration(
                                        helperText: "this is how it will appear in app",
                                        labelText: "Free Swipes",
                                        hintText: "Free Swipes",
                                      ),
                                      onSaved: (value) {
                                        data['free_swipes'] = value;
                                      },
                                    )
                                  : Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 5,
                                      child: ListTile(
                                        dense: !isLargeScreen,
                                        leading: Icon(
                                          Icons.filter_none,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        title: Text("Free swipes(in 24hrs.)", overflow: TextOverflow.ellipsis),
                                        subtitle: Text(
                                            "${freeSwipectlr.text.length > 0 ? freeSwipectlr.text : "-----"}" +
                                                ' swipes/24hrs.'),
                                      ),
                                    ),
                            ),
                            SizedBox(
                              width: isLargeScreen
                                  ? MediaQuery.of(context).size.width * .1
                                  : MediaQuery.of(context).size.width * .01,
                            ),
                            Expanded(
                              child: edit
                                  ? Padding(
                                      padding: const EdgeInsets.only(top: 10),
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: paidSwipectlr,
                                        readOnly: true,
                                        autofocus: false,
                                        cursorColor: Theme.of(context).primaryColor,
                                        decoration: InputDecoration(
                                          helperText: "this is how it will appear in app",
                                          hintText: "Unlimited(if paid user)",
                                          hintStyle: TextStyle(
                                            color: Colors.white24,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 5,
                                      child: ListTile(
                                        dense: !isLargeScreen,
                                        leading: Icon(
                                          Icons.filter_none,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                        title: Text("Paid Swipes", overflow: TextOverflow.ellipsis),
                                        subtitle: Text("Unlimited"),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
