
import 'package:cloud_firestore/cloud_firestore.dart';

class Guide {

  String startpointName;
  String endpointName;
  double startpointLat;
  double startpointLng;
  double endpointLat;
  double endpointLng;
  String price;
  List paths;
  

  Guide({
    required this.startpointName,
    required this.endpointName,
    required this.startpointLat,
    required this.startpointLng,
    required this.endpointLat,
    required this.endpointLng,
    required this.price,
    required this.paths
    
    
  });


  factory Guide.fromFirestore(DocumentSnapshot snap){
    return Guide(
       startpointName: snap['startpoint name'],
       endpointName: snap['endpoint name'],
       startpointLat: snap['startpoint lat'],
       startpointLng: snap['startpoint lng'],
       endpointLat: snap['endpoint lat'],
       endpointLng: snap['endpoint lng'],
       price: snap['price'],
       paths: snap['paths']


    );
  }
}