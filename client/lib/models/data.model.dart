import 'package:ally_4_u_client/models/user.model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Notify {
  final User sender;
  final Timestamp time;
  final bool isRead;

  Notify({
    required this.sender,
    required this.time,
    required this.isRead,
  });
}
