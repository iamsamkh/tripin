import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/blog.dart';
import '../models/place.dart';

class BookmarkBloc extends ChangeNotifier {
  Future<List> getPlaceData() async {
    String collectionName = 'placesN';
    String type = 'bookmarked places';
    List<Place> data = [];
    List<DocumentSnapshot> _snap = [];

    SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');

    final DocumentReference ref =
        FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = snap[type];

    if (d.isNotEmpty) {
      QuerySnapshot rawData = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('placeId', whereIn: d)
          .get();
      _snap.addAll(rawData.docs);
      data = _snap.map((e) => Place.fromFirestore(e)).toList();
    }

    return data;
  }

  Future<List> getBlogData() async {
    String collectionName = 'blogs';
    String type = 'bookmarked blogs';
    List<Blog> data = [];
    List<DocumentSnapshot> _snap = [];
    SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');

    final DocumentReference ref =
        FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = snap[type];

    if (d.isNotEmpty) {
      QuerySnapshot rawData = await FirebaseFirestore.instance
          .collection(collectionName)
          .where('timestamp', whereIn: d)
          .get();
      _snap.addAll(rawData.docs);
      data = _snap.map((e) => Blog.fromFirestore(e)).toList();
    }
    return data;
  }

  Future onBookmarkIconClick(String collectionName, String placeId) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');
    String _type =
        collectionName == 'placesN' ? 'bookmarked places' : 'bookmarked blogs';

    final DocumentReference ref =
        FirebaseFirestore.instance.collection('users').doc(_uid);
    DocumentSnapshot snap = await ref.get();
    List d = snap[_type];

    if (d.contains(placeId)) {
      List a = [placeId];
      await ref.update({_type: FieldValue.arrayRemove(a)});
    } else {
      d.add(placeId);
      await ref.update({_type: FieldValue.arrayUnion(d)});
    }

    notifyListeners();
  }

  Future onLoveIconClick(String collectionName, String id) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    String? _uid = sp.getString('uid');
    String _type = collectionName == 'placesN' ? 'loved places' : 'loved blogs';

    final DocumentReference ref =
        FirebaseFirestore.instance.collection('users').doc(_uid);
    final DocumentReference ref1 =
        FirebaseFirestore.instance.collection(collectionName).doc(id);

    DocumentSnapshot snap = await ref.get();
    DocumentSnapshot snap1 = await ref1.get();
    List d = snap[_type];
    int _loves = snap1['loveCount'];

    if (d.contains(id)) {
      List a = [id];
      await ref.update({_type: FieldValue.arrayRemove(a)});
      ref1.update({'loveCount': _loves - 1});
    } else {
      d.add(id);
      await ref.update({_type: FieldValue.arrayUnion(d)});
      ref1.update({'loveCount': _loves + 1});
    }
  }
}
