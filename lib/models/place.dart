import 'package:cloud_firestore/cloud_firestore.dart';

class Place {
  String province;
  String city;
  String category;
  String name;
  String address;
  double latitude;
  double longitude;
  String description;
  List<dynamic> imageUrl;
  List<dynamic> facilities;
  int loves;
  int experienceCount;
  String id;
  int questions;
  int stories;
  Timestamp dateAdded;
  String status;

  Place({
    required this.id,
    required this.category,
    required this.facilities,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.address,
    required this.city,
    required this.province,
    required this.latitude,
    required this.longitude,
    required this.experienceCount,
    required this.loves,  
    required this.questions,
    required this.stories,
    required this.dateAdded,
    required this.status,
  });


  factory Place.fromFirestore(DocumentSnapshot snap){
    return Place(
      id: snap['placeId'],
      category: snap['category'],
      facilities: snap['facilities'],
      name: snap['placeName'],
      imageUrl: snap['image'],
      description: snap['description'],
      address: snap['address'],
      city: snap['city'],
      province: snap['province'],
      latitude: snap['latitude'],
      longitude: snap['longitude'],
      experienceCount: snap['experienceCount'],
      loves: snap['loveCount'],
      questions: snap['questionsCount'],
      stories: snap['storiesCount'],
      dateAdded: snap['dateAdded'],
      status: snap['status'],
    );
  }
}