
import 'package:cloud_firestore/cloud_firestore.dart';

class Blog {

  String title;
  String description;
  String thumbnailImagelUrl;
  int loves;
  String sourceUrl;
  String date;
  String timestamp;

  Blog({

    required this.title,
    required this.description,
    required this.thumbnailImagelUrl,
    required this.loves,
    required this.sourceUrl,
    required this.date,
    required this.timestamp
    
  });


  factory Blog.fromFirestore(DocumentSnapshot snap){
    return Blog(
      title: snap['title'],
      description: snap['description'],
      thumbnailImagelUrl: snap['image url'],
      loves: snap['loves'],
      sourceUrl: snap['source'],
      date: snap['date'],
      timestamp: snap['timestamp'], 


    );
  }
}