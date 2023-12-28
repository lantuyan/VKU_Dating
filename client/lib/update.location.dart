import 'package:ally_4_u_client/search.location.dart';
import 'package:ally_4_u_client/util/color.dart';
import 'package:ally_4_u_client/util/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mapbox_autocomplete/flutter_mapbox_autocomplete.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class UpdateLocation extends StatefulWidget {
  const UpdateLocation({super.key});

  @override
  State<UpdateLocation> createState() => _UpdateLocationState();
}

class _UpdateLocationState extends State<UpdateLocation> {
  Map? _newAddress;

  @override
  void initState() {
    getLocationCoordinates().then((updateAddress) {
      setState(() {
        _newAddress = updateAddress!;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, ThemeNotifier notifier, child) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: notifier.darkTheme ? darkAppbarColor : primaryColor,
          automaticallyImplyLeading: false,
          title: ListTile(
            title: Text(
              "Use current location",
              style: TextStyle(
                color: notifier.darkTheme ? Colors.white : lightText,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(_newAddress != null ? _newAddress!['PlaceName'] ?? 'Fetching..' : 'Fetching..'),
            leading: Icon(
              Icons.location_searching_rounded,
              color: notifier.darkTheme ? Colors.white : lightText,
            ),
            onTap: () async {
              await getLocationCoordinates().then((updateAddress) {
                setState(() {
                  _newAddress = updateAddress!;
                });
              });
            },
          ),
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height * .6,
          child: MapBoxAutoCompleteWidget(
            language: 'en',
            closeOnSelect: false,
            apiKey: mapboxApi,
            limit: 10,
            hint: 'Enter your city name',
            onSelect: (place) {
              Map obj = {};
              obj['PlaceName'] = place.placeName;
              obj['latitude'] = place.geometry?.coordinates![1];
              obj['longitude'] = place.geometry?.coordinates![0];
              Navigator.pop(context, obj);
            },
          ),
        ),
      ),
    );
  }
}

Future<Map?> getLocationCoordinates() async {
  try {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    return await coordinatesToAddress(
      latitude: position.latitude,
      longitude: position.longitude,
    );
  } catch (e) {
    return null;
  }
}

Future coordinatesToAddress({latitude, longitude}) async {
  try {
    Map<String, dynamic> obj = {};
    GeoData result = await Geocoder2.getDataFromCoordinates(
      longitude: longitude,
      latitude: latitude,
      googleMapApiKey: 'AIzaSyATuTHQKNT_zLKxb3Lpw4Ok3oSlGnI5Aqo',
    );
    String currentAddress = "${result.city} ${result.state} ${result.country}, ${result.postalCode}";

    obj['PlaceName'] = currentAddress;
    obj['latitude'] = latitude;
    obj['longitude'] = longitude;

    return obj;
  } catch (_) {
    return null;
  }
}
