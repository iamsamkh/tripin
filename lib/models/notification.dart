import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  String title;
  String description;
  var createdAt;
  String timestamp;

  NotificationModel({
    required this.title,
    required this.description,
    required this.createdAt,
    required this.timestamp
  });


  factory NotificationModel.fromFirestore(DocumentSnapshot snap){
    return NotificationModel(
      title: snap['title'],
      description: snap['description'],
      createdAt: DateFormat('d MMM, y').format(DateTime.parse(snap['created_at'].toDate().toString())),
      timestamp: snap['timestamp'],
    );
  }
}