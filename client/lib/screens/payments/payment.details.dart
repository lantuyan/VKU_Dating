import 'package:ally_4_u_client/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

import '../../util/color.dart';

class PaymentDetails extends StatelessWidget {
  final List<PurchaseDetails> purchases;

  const PaymentDetails({super.key, required this.purchases});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: notifier.darkTheme ? darkAppbarColor : primaryColor,
          title: const Text("Subscription details"),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            color: notifier.darkTheme ? Colors.white : const Color(0xff707070),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: notifier.darkTheme ? darkBackground : primaryColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(children: [
                  Padding(
                    padding: const EdgeInsets.all(38.0),
                    child: Text(
                      "Payment Summary:",
                      style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 23),
                    ),
                  ),
                ]),
                purchases.isNotEmpty
                    ? ListView(
                        scrollDirection: Axis.vertical,
                        physics: const ScrollPhysics(),
                        shrinkWrap: true,
                        children: purchases
                            .map(
                              (index) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    columns: const [
                                      DataColumn(
                                          label: Text(
                                        "Plan",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      )),
                                      DataColumn(
                                        label: Text(
                                          "Details",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                    rows: [
                                      DataRow(
                                        cells: [
                                          const DataCell(
                                            Text(
                                              "Transaction_id",
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              "${index.purchaseID}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      DataRow(
                                        cells: [
                                          const DataCell(
                                            Text(
                                              "product_id",
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              index.productID,
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      DataRow(
                                        cells: [
                                          const DataCell(
                                            Text(
                                              "Subscribed on",
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              DateTime.fromMillisecondsSinceEpoch(
                                                int.parse(
                                                  index.transactionDate!,
                                                ),
                                              ).toLocal().toString(),
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      DataRow(
                                        cells: [
                                          const DataCell(
                                            Text(
                                              "Status",
                                              style: TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          DataCell(
                                            Text(
                                              index.status == PurchaseStatus.purchased ? "Active" : "Cancelled",
                                              style: TextStyle(
                                                color: index.status == PurchaseStatus.purchased ? Colors.green : Colors.red,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
                const SizedBox(
                  height: 50,
                ),
                SizedBox(
                  height: 60,
                  width: 250,
                  child: InkWell(
                    child: Card(
                      color: accentColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Center(
                        child: Text(
                          "Back",
                          style: TextStyle(
                            fontSize: 17,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
