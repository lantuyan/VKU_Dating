import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/snackbar.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:provider/provider.dart';

import 'allow.location.dart';

class SearchLocation extends StatefulWidget {
  final Map<String, dynamic> userData;

  const SearchLocation(this.userData, {super.key});

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

//Add here your mapbox token under ""
String mapboxApi = "pk.eyJ1Ijoic2F5YW4xNTkiLCJhIjoiY2tscWM5eHBvMWJraDJ1bjM3YmhudmdiOCJ9.aL5Brzvpf3_-btH0sbNPHA"; // TODO: mapbox api key

class _SearchLocationState extends State<SearchLocation> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late MapBoxPlace _mapBoxPlace;
  final TextEditingController _city = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        key: _scaffoldKey,
        floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
        floatingActionButton: AnimatedOpacity(
          opacity: 1.0,
          duration: const Duration(milliseconds: 50),
          child: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: FloatingActionButton(
              elevation: 10,
              backgroundColor: accentColor,
              onPressed: () {
                Navigator.pop(context);
              },
              child: IconButton(
                color: Colors.white,
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 50,
                      top: 120,
                    ),
                    child: Text(
                      "Select\nyour city",
                      style: TextStyle(fontSize: 40),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: TextField(
                          autofocus: false,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: "Enter your city name",
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: accentColor,
                              ),
                            ),
                            helperText: "This is how it will appear in App.",
                            helperStyle: TextStyle(
                              color: secondryColor,
                              fontSize: 15,
                            ),
                          ),
                          controller: _city,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapBoxAutoCompleteWidget(
                                language: 'en',
                                closeOnSelect: true,
                                apiKey: mapboxApi,
                                limit: 10,
                                hint: 'Enter your city name',
                                onSelect: (place) {
                                  setState(
                                    () {
                                      _mapBoxPlace = place;
                                      _city.text = _mapBoxPlace.placeName!;
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  _city.text.isNotEmpty
                      ? Padding(
                          padding: const EdgeInsets.only(bottom: 40.0),
                          child: Align(
                            alignment: Alignment.bottomCenter,
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
                                height: MediaQuery.of(context).size.height * .065,
                                width: MediaQuery.of(context).size.width * .75,
                                child: Center(
                                  child: Text(
                                    "Continue",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              onTap: () async {
                                widget.userData.addAll(
                                  {
                                    'location': {
                                      'latitude': _mapBoxPlace.geometry?.coordinates![1],
                                      'longitude': _mapBoxPlace.geometry?.coordinates![0],
                                      'address': "${_mapBoxPlace.placeName}"
                                    },
                                    'maximum_distance': 20,
                                    'age_range': {
                                      'min': "20",
                                      'max': "50",
                                    },
                                  },
                                );

                                showWelcomDialog(context);
                                setUserData(widget.userData);
                              },
                            ),
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 40),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: InkWell(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                height: MediaQuery.of(context).size.height * .065,
                                width: MediaQuery.of(context).size.width * .75,
                                child: Center(
                                  child: Text(
                                    "CONTINUE",
                                    style: TextStyle(fontSize: 15, color: secondryColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              onTap: () {
                                CustomSnackbar.snackbar(
                                  "Select a location !",
                                  context,
                                );
                              },
                            ),
                          ),
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
