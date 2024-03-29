import 'package:allt_4_u_admin/model/custom.alert.dart';
import 'package:allt_4_u_admin/model/user.dart';
import 'package:allt_4_u_admin/screens/user_info.dart';
import 'package:allt_4_u_admin/subscriptios/package.dart';
import 'package:allt_4_u_admin/subscriptios/settings.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chage_password.dart';
import 'login.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  CollectionReference collectionReference = FirebaseFirestore.instance.collection("Users");

  @override
  void initState() {
    _getuserList();
    super.initState();
  }

  TextEditingController searchctrlr = TextEditingController();
  bool isLargeScreen = false;

  int? totalDoc;
  DocumentSnapshot? lastVisible;
  int documentLimit = 25;
  List<User> user = [];
  bool sort = true;

  // int start = 0;
  // int end = 25;
  Future _getuserList() async {
    collectionReference.orderBy("user_DOB", descending: true).get().then(
      (value) {
        totalDoc = value.docs.length;
      },
    );
    if (lastVisible != null) {
      await collectionReference
          .orderBy("user_DOB", descending: true)
          .startAfterDocument(lastVisible!)
          .limit(documentLimit)
          .get()
          .then(
        (value) {
          if (value.docs.length < 1) {
            snackbar('No more data available', context);
            print("no more data");
            return;
          }
          lastVisible = value.docs[value.docs.length - 1];
          for (var doc in value.docs) {
            if (doc.exists) {
              User temp = User.fromDocument(doc);
              user.add(temp);
            }
          }
        },
      );
      if (mounted) setState(() {});
    } else {
      await collectionReference
          //.where('userId', isGreaterThan: '')
          .limit(documentLimit)
          .orderBy('user_DOB', descending: true)
          .get()
          .then(
        (value) {
          lastVisible = value.docs[value.docs.length - 1];
          for (var doc in value.docs) {
            if (doc.exists) {
              User temp = User.fromDocument(doc);
              user.add(temp);
            }
          }
        },
      );
      if (mounted) setState(() {});
    }
  }

  Widget userlists(List<User> list) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortAscending: sort,
                sortColumnIndex: 2,
                columnSpacing: MediaQuery.of(context).size.width * .085,
                columns: [
                  DataColumn(
                    label: Text("Images"),
                  ),
                  DataColumn(
                    label: Text("Name"),
                  ),
                  DataColumn(
                    label: Text("Gender"),
                    onSort: (columnIndex, ascending) {
                      setState(
                        () {
                          sort = !sort;
                        },
                      );
                      onSortColum(columnIndex, ascending);
                    },
                  ),
                  DataColumn(
                    label: Text("Phone Number"),
                  ),
                  DataColumn(
                    label: Text("User_id"),
                  ),
                  DataColumn(
                    label: Text("view"),
                  ),
                ],
                rows: list
                    .getRange(list.length >= documentLimit ? list.length - documentLimit : 0, list.length)
                    .map(
                      (index) => DataRow(
                        cells: [
                          DataCell(
                            ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: CircleAvatar(
                                child: index.imageUrl != null && index.imageUrl!.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: index.imageUrl![0],
                                        fit: BoxFit.fill,
                                        useOldImageOnUrlChange: true,
                                        placeholder: (context, url) => CupertinoActivityIndicator(
                                          radius: 15,
                                        ),
                                        errorWidget: (context, url, error) => Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.error,
                                              size: 30,
                                            ),
                                          ],
                                        ),
                                      )
                                    : Container(),
                                backgroundColor: Colors.grey,
                                radius: 18,
                              ),
                            ),
                            // onTap: () {
                            //   // write your code..
                            // },
                          ),
                          DataCell(
                            Text(index.name),
                          ),
                          DataCell(
                            Text(index.gender ?? ''),
                          ),
                          DataCell(
                            Text(index.phoneNumber ?? ''),
                          ),
                          DataCell(
                            Row(
                              children: [
                                Container(
                                  width: 150,
                                  child: Text(
                                    index.id,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.content_copy,
                                    size: 20,
                                  ),
                                  tooltip: "copy",
                                  onPressed: () {
                                    Clipboard.setData(
                                      ClipboardData(
                                        text: index.id,
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(Icons.fullscreen),
                              tooltip: "open profile",
                              onPressed: () async {
                                var _isdelete = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Info(index),
                                  ),
                                );
                                if (_isdelete != null && _isdelete) {
                                  snackbar('Deleted', context);

                                  setState(
                                    () {
                                      searchctrlr.clear();
                                      searchReasultfuture = null;
                                      user.removeWhere((element) => element.id == index.id);
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          searchReasultfuture != null
              ? Container()
              : Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 12,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              if (list.length > documentLimit) {
                                list.removeRange(
                                  list.length - documentLimit,
                                  list.length,
                                );
                              }
                            },
                          );
                        },
                      ),
                      Text(
                          "${list.length >= documentLimit ? list.length - documentLimit : 0}-${list.length - 1} of $totalDoc  "),
                      IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                        ),
                        onPressed: () {
                          showDialog(
                            barrierDismissible: false,
                            context: context,
                            builder: (context) {
                              _getuserList().then(
                                (value) => Navigator.pop(context),
                              );
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    ],
                  ),
                )
        ],
      ),
    );
  }

  List<User> results = [];
  Future<QuerySnapshot>? searchReasultfuture;

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  searchuser(String query) {
    if (query.trim().length > 0) {
      Future<QuerySnapshot> users = collectionReference
          .where(
            isNumeric(query) ? 'phoneNumber' : 'UserName',
            isEqualTo: query,
          )
          .get();

      setState(() {
        searchReasultfuture = users;
      });
    }
  }

  Widget buildSearchresults() {
    return FutureBuilder(
      future: searchReasultfuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text("Searching......"),
            ],
          );
          //
        }
        if (snapshot.data!.docs.length > 0) {
          results.clear();
          snapshot.data!.docs.forEach(
            (DocumentSnapshot doc) {
              if (doc.exists) {
                User usert2 = User.fromDocument(doc);
                results.add(usert2);
              }
            },
          );
          return userlists(results);
        }
        return Center(
          child: Text("no data found"),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        if (MediaQuery.of(context).size.width > 600) {
          isLargeScreen = true;
        } else {
          isLargeScreen = false;
        }
        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Admin Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                ListTile(
                  trailing: Icon(
                    Icons.format_list_numbered,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('PACKAGES'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Package(),
                      ),
                    );
                  },
                ),
                Divider(
                  thickness: .5,
                  color: Colors.black,
                ),
                ListTile(
                  trailing: Icon(
                    Icons.storage,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('ITEM ACCESS'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubscriptionSettings(),
                      ),
                    );
                  },
                ),
                Divider(
                  thickness: .5,
                  color: Colors.black,
                ),
                ListTile(
                  trailing: Icon(
                    Icons.lock_open,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('CHANGE ID/PASSWORD'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeIdPassword(),
                      ),
                    );
                  },
                ),
                Divider(
                  thickness: .5,
                  color: Colors.black,
                ),
                ListTile(
                  trailing: Icon(
                    Icons.power_settings_new,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text('LOGOUT'),
                  onTap: () async {
                    _alertDialog(context);
                  },
                ),
              ],
            ),
          ),
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "Users",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Container(
                  // decoration:
                  //     BoxDecoration(border: Border.all(color: Colors.white)),
                  height: 4,
                  width:
                      isLargeScreen ? MediaQuery.of(context).size.width * .3 : MediaQuery.of(context).size.width * .5,
                  child: Card(
                    child: TextFormField(
                      cursorColor: Theme.of(context).primaryColor,
                      controller: searchctrlr,
                      decoration: InputDecoration(
                        hintText: "Search by name or phone number",
                        filled: true,
                        prefixIcon: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () => searchuser(searchctrlr.text),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            searchctrlr.clear();
                            setState(
                              () {
                                searchReasultfuture = null;
                              },
                            );
                          },
                        ),
                      ),
                      onFieldSubmitted: searchuser,
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: searchReasultfuture == null
              ? user.length > 0
                  ? userlists(user)
                  : Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    )
              : buildSearchresults(),
        );
      },
    );
  }

  void logout() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    sharedPrefs.setBool('isAuth', false);
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  _alertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BeautifulAlertDialog(
            text: "Do you want to logout ?", onYesTap: logout, onNoTap: () => Navigator.pop(context));
      },
    );
  }

  onSortColum(int columnIndex, bool ascending) {
    if (columnIndex == 2) {
      if (ascending) {
        user.sort((a, b) => a.gender!.compareTo(b.gender!));
      } else {
        user.sort((a, b) => b.gender!.compareTo(a.gender!));
      }
    }
  }
}
