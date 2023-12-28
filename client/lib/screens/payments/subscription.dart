// ignore_for_file: import_of_legacy_library_into_null_safe, prefer_typing_uninitialized_variables

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:math' hide log;

import 'package:ally_4_u_client/models/user.model.dart';
import 'package:ally_4_u_client/screens/profile/profile.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../tab.dart';
import '../../util/snackbar.dart';

class Subscription extends StatefulWidget {
  final bool? isPaymentSuccess;
  final User? currentUser;
  final Map<String, dynamic> items;

  const Subscription({
    super.key,
    this.currentUser,
    this.isPaymentSuccess,
    required this.items,
  });

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  /// if the api is available or not.
  bool isAvailable = true;

  /// products for sale
  List<ProductDetails> products = [];

  /// Past purchases
  List<PurchaseDetails> purchases = [];

  /// Update to purchases
  StreamSubscription? _streamSubscription;
  late ProductDetails selectedPlan;
  ProductDetails? selectedProduct;
  var response;
  bool _isLoading = true;
  final InAppPurchase _iap = InAppPurchase.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initialize();
    log(widget.items.toString());
    // Show payment failure alert.
    if (widget.isPaymentSuccess != null && !widget.isPaymentSuccess!) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await Alert(
          context: context,
          type: AlertType.error,
          title: "Failed",
          desc: "Oops !! something went wrong. Try Again",
          buttons: [
            DialogButton(
              onPressed: () => Navigator.pop(context),
              width: 120,
              child: Text(
                "Retry",
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 20,
                ),
              ),
            )
          ],
        ).show();
      });
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  Future<List<String>> _fetchPackageIds() async {
    List<String> packageId = [];

    await FirebaseFirestore.instance.collection("Packages").where('status', isEqualTo: true).get().then((value) {
      packageId.addAll(value.docs.map((e) => e['id']));
    });

    return packageId;
  }

  void _initialize() async {
    isAvailable = await _iap.isAvailable();
    log(isAvailable.toString());
    if (isAvailable) {
      List<Future> futures = [
        _getProducts(await _fetchPackageIds()),
        //_getpastPurchases(false),
      ];
      await Future.wait(futures);

      /// removing all the pending puchases.
      // if (Platform.isIOS) {
      //   var paymentWrapper = SKPaymentQueueWrapper();
      //   var transactions = await paymentWrapper.transactions();
      //   transactions.forEach((transaction) async {
      //     await paymentWrapper.finishTransaction(transaction).catchError((onError) {});
      //   });
      // }

      _streamSubscription = _iap.purchaseStream.listen((data) async {
        setState(
          () {
            purchases.addAll(data);

            for (var purchase in purchases) {
              _verifyPuchase(purchase.productID);
            }
          },
        );
      });
      _streamSubscription?.onError(
        (error) {
          // ignore: deprecated_member_use
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: error != null ? Text('$error') : const Text("Oops !! something went wrong. Try Again"),
            ),
          );
        },
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 20, right: 20),
                alignment: Alignment.topRight,
                child: IconButton(
                  alignment: Alignment.topRight,
                  color: notifier.darkTheme ? lightText : darkText,
                  icon: const Icon(
                    Icons.cancel,
                    size: 25,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(
                          "Get our premium plans",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const ListTile(
                        dense: true,
                        leading: Icon(
                          Icons.star,
                          color: Colors.blue,
                        ),
                        title: Text(
                          "Unlimited swipe.",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.star,
                          color: Colors.green,
                        ),
                        title: Text(
                          "Search users around ${widget.items['paid_radius'] ?? ""} kms.",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: 150,
                            width: MediaQuery.of(context).size.width * .85,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CardSwiper(
                                key: UniqueKey(),
                                // curve: Curves.linear,
                                // autoplay: true,
                                // physics: const ScrollPhysics(),
                                cardBuilder: (BuildContext context, int index2, int i, int i2) {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            adds[index2]["icon"],
                                            color: adds[index2]["color"],
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            adds[index2]["title"],
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Text(
                                        adds[index2]["subtitle"],
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  );
                                },
                                cardsCount: adds.length,
                                // pagination: SwiperPagination(
                                //   alignment: Alignment.bottomCenter,
                                //   builder: DotSwiperPaginationBuilder(
                                //     activeSize: 10,
                                //     color: secondryColor,
                                //     activeColor: accentColor,
                                //   ),
                                // ),
                                // control: SwiperControl(
                                //   size: 20,
                                //   color: accentColor,
                                //   disableColor: secondryColor,
                                // ),
                                // loop: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                      _isLoading
                          ? SizedBox(
                              height: MediaQuery.of(context).size.width * .8,
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    accentColor,
                                  ),
                                ),
                              ),
                            )
                          : products.isNotEmpty
                              ? Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    Align(
                                      alignment: Alignment.center,
                                      child: Transform.rotate(
                                        angle: -pi / 2,
                                        child: Container(
                                          width: MediaQuery.of(context).size.height * .16,
                                          height: MediaQuery.of(context).size.width * .8,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 2,
                                              color: primaryColor,
                                            ),
                                          ),
                                          child: Center(
                                            child: (CupertinoPicker(
                                              squeeze: 1.4,
                                              looping: true,
                                              magnification: 1.08,
                                              offAxisFraction: -.2,
                                              backgroundColor: primaryColor,
                                              scrollController: FixedExtentScrollController(initialItem: 0),
                                              itemExtent: 100,
                                              onSelectedItemChanged: (value) {
                                                setState(
                                                  () {
                                                    selectedProduct = products[value];
                                                  },
                                                );
                                              },
                                              children: products.map(
                                                (product) {
                                                  return Transform.rotate(
                                                    angle: pi / 2,
                                                    child: Center(
                                                      child: Column(
                                                        children: [
                                                          productList(
                                                            context: context,
                                                            product: product,
                                                            interval: Platform.isIOS ? getInterval(product) : getIntervalAndroid(product),
                                                            price: product.price,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ).toList(),
                                            )),
                                          ),
                                        ),
                                      ),
                                    ),
                                    selectedProduct != null
                                        ? Center(
                                            child: ListTile(
                                              title: Text(
                                                selectedProduct?.title ?? '',
                                                textAlign: TextAlign.center,
                                              ),
                                              subtitle: Text(
                                                selectedProduct?.description ?? '',
                                                textAlign: TextAlign.center,
                                              ),
                                              trailing: Text("${products.indexOf(selectedProduct!) + 1}/${products.length}"),
                                            ),
                                          )
                                        : Container()
                                  ],
                                )
                              : SizedBox(
                                  height: MediaQuery.of(context).size.width * .8,
                                  child: const Center(
                                    child: Text("No active product found!!"),
                                  ),
                                )
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(25),
                        gradient: LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: [accentColor.withOpacity(.5), accentColor.withOpacity(.8), accentColor, accentColor],
                        ),
                      ),
                      height: MediaQuery.of(context).size.height * .055,
                      width: MediaQuery.of(context).size.width * .55,
                      child: Center(
                        child: Text(
                          "CONTINUE",
                          style: TextStyle(
                            fontSize: 15,
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    onTap: () async {
                      if (selectedProduct != null) {
                        _buyProduct(selectedProduct!);
                      } else {
                        CustomSnackbar.snackbar(
                          "You must choose a subscription to continue.",
                          context,
                        );
                      }
                    },
                  ),
                ),
              ),
              // SizedBox(
              //   height: 15,
              // ),
              Platform.isIOS
                  ? InkWell(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(25),
                          gradient: LinearGradient(
                            begin: Alignment.topRight,
                            end: Alignment.bottomLeft,
                            colors: [accentColor.withOpacity(.5), accentColor.withOpacity(.8), accentColor, accentColor],
                          ),
                        ),
                        height: MediaQuery.of(context).size.height * .055,
                        width: MediaQuery.of(context).size.width * .55,
                        child: Center(
                          child: Text(
                            "RESTORE PURCHASE",
                            style: TextStyle(
                              fontSize: 15,
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      onTap: () async {
                        var result = await _getpastPurchases();
                        if (result.length == 0) {
                          if (!mounted) return;
                          showDialog(
                            context: context,
                            builder: (ctx) {
                              return const AlertDialog(
                                content: Text("No purchase found"),
                                title: Text("Past Purchases"),
                              );
                            },
                          );
                        }
                      },
                    )
                  : Container(),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      child: const Text(
                        "Privacy Policy",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () => canLaunchUrl(Uri.parse("yourprivacyurl")),
                    ),
                    GestureDetector(
                      child: const Text(
                        "Terms & Conditions",
                        style: TextStyle(color: Colors.blue),
                      ),
                      onTap: () => canLaunchUrl(Uri.parse("yourtermsurl")),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget productList({
    BuildContext? context,
    String? intervalCount,
    String? interval,
    Function? onTap,
    ProductDetails? product,
    String? price,
  }) {
    return AnimatedContainer(
      curve: Curves.easeIn,
      height: 100,
      //setting up dimention if product get selected
      width: selectedProduct != product //setting up dimention if product get selected
          ? MediaQuery.of(context!).size.width * .19
          : MediaQuery.of(context!).size.width * .22,
      decoration: selectedProduct == product
          ? BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(width: 2, color: primaryColor),
            )
          : null,
      duration: const Duration(milliseconds: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * .02),
          Text(
            intervalCount ?? '',
            style: TextStyle(
              color: selectedProduct != product //setting up color if product get selected
                  ? Colors.black
                  : const Color(0xffff3a5a),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            interval!,
            style: TextStyle(
              color: selectedProduct != product //setting up color if product get selected
                  ? Colors.black
                  : const Color(0xffff3a5a),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          Text(
            price!,
            style: TextStyle(
              color: selectedProduct != product //setting up product if product get selected
                  ? Colors.black
                  : const Color(0xffff3a5a),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
        //      )),
      ),
    );
  }

  ///fetch products
  Future<void> _getProducts(List<String> productIds) async {
    if (productIds.isNotEmpty) {
      Set<String> ids = Set.from(productIds);
      ProductDetailsResponse response = await _iap.queryProductDetails(ids);
      log(response.productDetails.toString(), name: '_getProducts');
      setState(() {
        products = response.productDetails;
      });

      //initial selected of products

      selectedProduct = products.isNotEmpty ? products[0] : null;
    }
  }

  ///get past purchases of user
  Future _getpastPurchases() async {
    // final response = await _iap.();
    // for (PurchaseDetails purchase in response.pastPurchases) {
    //   if (Platform.isIOS) {
    //     _iap.completePurchase(purchase);
    //   }
    // }
    // setState(() {
    //   purchases = response.pastPurchases;
    // });
    // if (purchases.length > 0) {
    //   for (var purchase in purchases) async {
    //       await _verifyPuchase(purchase.productID);
    //     }
    // } else {
    //   return purchases;
    // }
  }

  /// check if user has pruchased
  PurchaseDetails _hasPurchased(String productId) {
    return purchases.firstWhere((purchase) => purchase.productID == productId);
  }

  ///verifying opurhcase of user
  Future<void> _verifyPuchase(
    String id,
  ) async {
    PurchaseDetails purchase = _hasPurchased(id);
    if (purchase.status == PurchaseStatus.purchased) {
      // if (Platform.isIOS) {
      await _iap.completePurchase(purchase);
      //}
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) {
            return Tabbar(
              plan: purchase.productID,
              isPaymentSuccess: true,
            );
          },
        ),
      );
    } else if (purchase.status == PurchaseStatus.error) {
      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => Subscription(
            currentUser: widget.currentUser,
            isPaymentSuccess: false,
            items: widget.items,
          ),
        ),
      );
    }
    return;
  }

  ///buying a product
  void _buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  String getInterval(ProductDetails product) {
    // final periodUnit = product.skProduct.subscriptionPeriod.unit;
    // if (SKSubscriptionPeriodUnit.month == periodUnit) {
    //   return "Month(s)";
    // } else if (SKSubscriptionPeriodUnit.week == periodUnit) {
    //   return "Week(s)";
    // } else {
    //   return "Year";
    // }
    return '';
  }

  String getIntervalAndroid(ProductDetails product) {
    // String durCode = product.skuDetail.subscriptionPeriod.split("")[2];
    // if (durCode == "M") {
    //   return "Month(s)";
    // } else if (durCode == "Y") {
    //   return "Year";
    // } else {
    //   return "Week(s)";
    // }
    return '';
  }
}
