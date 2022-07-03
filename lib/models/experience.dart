import 'package:cloud_firestore/cloud_firestore.dart';

class Experience {
  String uid;
  String name;
  String imageUrl;
  String comment;
  String date;
  String reviewTime;

  Experience(
      {required this.uid,
      required this.name,
      required this.imageUrl,
      required this.comment,
      required this.date,
      required this.reviewTime});

  factory Experience.fromFirestore(DocumentSnapshot snap) {
    return Experience(
      uid: snap['uid'],
      name: snap['name'],
      imageUrl: snap['image url'],
      comment: snap['comment'],
      date: snap['date'],
      reviewTime: snap['reviewTime'],
    );
  }
}
