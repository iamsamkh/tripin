import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  String uid;
  String name;
  String imageUrl;
  String comment;
  String date;
  String reviewTime;

  Comment(
      {required this.uid,
      required this.name,
      required this.imageUrl,
      required this.comment,
      required this.date,
      required this.reviewTime});

  factory Comment.fromFirestore(DocumentSnapshot snap) {
    return Comment(
      uid: snap['uid'],
      name: snap['name'],
      imageUrl: snap['image url'],
      comment: snap['comment'],
      date: snap['date'],
      reviewTime: snap['reviewTime'],
    );
  }
}
