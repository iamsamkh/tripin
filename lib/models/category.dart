import 'package:cloud_firestore/cloud_firestore.dart';

class CategoriesModel {
  String name;
  String thumbnailUrl;
  String id;

  CategoriesModel({
    required this.name,
    required this.thumbnailUrl,
    required this.id
  });


  factory CategoriesModel.fromFirestore(DocumentSnapshot snap){
    return CategoriesModel(
      name: snap['name'],
      thumbnailUrl: snap['thumbnail'],
      id: snap['id'],
    );
  }


  Map<String, dynamic> toJson (){
    return {
      'name' : name,
      'thumbnail' : thumbnailUrl,
      'timestamp' : id
    };
  }
}

