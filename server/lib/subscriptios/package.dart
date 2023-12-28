import 'package:allt_4_u_admin/screens/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import '../model/custom.alert.dart';
import 'create.package.dart';

class Package extends StatefulWidget {
  @override
  _PackageState createState() => _PackageState();
}

class _PackageState extends State<Package> {
  final collectionReference = FirebaseFirestore.instance.collection("Packages");
  List<Map<String, dynamic>> products = [];
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _getPackages();
    super.initState();
  }

  _getPackages() async {
    collectionReference.orderBy('timestamp', descending: false).snapshots().listen(
      (doc) {
        products.clear();
        for (var item in doc.docs) {
          products.add(item.data());
        }
        if (mounted) setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Manage Packages"),
        actions: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: OutlinedButton.icon(
                icon: Icon(
                  Icons.add,
                  color: Theme.of(context).primaryColor,
                  textDirection: TextDirection.rtl,
                ),
                label: Text(
                  "Create new",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                onPressed: () async {
                  if (products.length < 6) {
                    Map<String, dynamic> result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreatePackage(
                          productList: products,
                        ),
                      ),
                    );

                    result['timestamp'] = FieldValue.serverTimestamp();
                    await collectionReference.doc(result['id']).set(
                          result,
                          SetOptions(merge: true),
                        );
                  } else {
                    snackbar(
                      "You have created already max number of packages",
                      context,
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: products.length > 0
          ? productlist(products)
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
    );
  }

  Widget productlist(List<Map<String, dynamic>> list) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: MediaQuery.of(context).size.width * .08,
                headingRowHeight: 40,
                horizontalMargin: MediaQuery.of(context).size.width * .05,
                columns: [
                  DataColumn(
                    label: Text(
                      "Sr.No.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Product id",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Title",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Description",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Status",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Edit/Deactivate",
                      textAlign: TextAlign.center,
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Remove",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
                rows: list
                    .mapIndexed(
                      (index, i) => DataRow(
                        cells: [
                          DataCell(
                            Text(
                              (i + 1).toString(),
                              //  products.indexOf(index).toString(),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              index['id'],
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              index['title'],
                              textAlign: TextAlign.center,
                            ),
                          ),
                          DataCell(
                            Text(
                              index["description"],
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  child: Text(
                                    index['status'] ? "Active" : "Deactivated",
                                    style: TextStyle(
                                      color: index['status'] ? Colors.green : Colors.red,
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                index['status']
                                    ? Icon(
                                        Icons.done_outline,
                                        color: Colors.green,
                                        size: 13,
                                      )
                                    : Icon(
                                        Icons.cancel,
                                        color: Colors.red,
                                        size: 13,
                                      ),
                              ],
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Colors.black,
                                size: 15,
                              ),
                              onPressed: () async {
                                Map<String, dynamic> editDetails = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CreatePackage(
                                      index: index,
                                      productList: products,
                                    ),
                                  ),
                                );
                                collectionReference.doc(index['id']).update(editDetails);
                              },
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                size: 15,
                                color: Colors.red,
                              ),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return BeautifulAlertDialog(
                                      text: "Do you want to delete this package ?",
                                      onYesTap: () async {
                                        await collectionReference.doc(index['id']).delete().whenComplete(
                                          () {
                                            Navigator.pop(context);
                                          },
                                        ).catchError(
                                          (onError) {
                                            snackbar(onError, context);
                                          },
                                        ).then(
                                          (value) => snackbar("Deleted Successfully", context),
                                        );
                                      },
                                      onNoTap: () => Navigator.pop(context),
                                    );
                                  },
                                );
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
        ],
      ),
    );
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T f(E e, int i)) {
    var i = 0;
    return this.map((e) => f(e, i++));
  }
}
