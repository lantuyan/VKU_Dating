// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final bool? isBlocked;
  String address;
  final Map? coordinates;
  final List? sexualOrientation;
  final String? gender;
  final String? showGender;
  final int? age;
  final String? phoneNumber;
  int? maxDistance;
  Timestamp? lastmsg;
  final Map? ageRange;
  final Map? editInfo;
  List? imageUrl = [];
  var distanceBW;
  bool? isOnline;
  Timestamp? lastSeen;

  User({
    required this.id,
    required this.age,
    required this.address,
    this.isBlocked,
    this.coordinates,
    required this.name,
    required this.imageUrl,
    this.phoneNumber,
    this.lastmsg,
    this.gender,
    this.showGender,
    this.ageRange,
    this.maxDistance,
    this.editInfo,
    this.distanceBW,
    this.sexualOrientation,
    this.isOnline,
    this.lastSeen,
  });

  factory User.fromDocument(DocumentSnapshot doc) {
    // DateTime date = DateTime.parse(doc["user_DOB"]);
    if (doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      return User(
        id: data['userId'] ?? '',
        isBlocked: data['isBlocked'] ?? false,
        phoneNumber: data['phoneNumber'] ?? '',
        name: data['UserName'] ?? '',
        editInfo: data['editInfo'],
        ageRange: data['age_range'],
        showGender: data['showGender'],
        maxDistance: data['maximum_distance'],
        sexualOrientation: data['sexualOrientation']['orientation'] ?? "",
        age: ((DateTime.now().difference(DateTime.parse(data["user_DOB"])).inDays) / 365.2425).truncate(),
        address: data['location']['address'],
        coordinates: data['location'],
        // university: doc['editInfo']['university'],
        imageUrl: data['Pictures'] != null
            ? List.generate(data['Pictures'].length, (index) {
                return data['Pictures'][index];
              })
            : [],
        isOnline: data['userState'] != null ? data['userState']['online'] : null,
        lastSeen: data['userState'] != null ? data['userState']['lastSeen'] : null,
      );
    } else {
      return User(
        id: '',
        isBlocked: false,
        phoneNumber: '',
        name: '',
        editInfo: null,
        ageRange: null,
        showGender: '',
        maxDistance: 0,
        sexualOrientation: [],
        age: 0,
        address: '',
        coordinates: null,
        // university: doc['editInfo']['university'],
        imageUrl: [],
        isOnline: false,
        lastSeen: Timestamp.fromDate(DateTime.now()),
      );
    }
  }
}
