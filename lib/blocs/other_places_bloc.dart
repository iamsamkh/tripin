import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/place.dart';

class OtherPlacesBloc extends ChangeNotifier{
  
  List<Place> _data = [];
  List<Place> get data => _data;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;
 

  Future getData(String categoryId, String placeId) async {
    QuerySnapshot rawData;
      rawData = await firestore
          .collection('placesN')
          .where('category', isEqualTo: categoryId)
          .orderBy('loveCount', descending: true)
          .limit(6)
          .get();
      
      List<DocumentSnapshot> _snap = [];
      _snap.addAll(rawData.docs.skipWhile((value) => value['placeId'] == placeId));
      _data = _snap.map((e) => Place.fromFirestore(e)).toList();
      notifyListeners();
  }

  onRefresh(mounted, String stateName, String timestamp) {
    _data.clear();
    getData(stateName, timestamp);
    notifyListeners();
  }

}