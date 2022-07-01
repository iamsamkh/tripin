import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/Place.dart';

class ManagePlacesBloc extends ChangeNotifier {
  DocumentSnapshot? _lastVisible;
  DocumentSnapshot? get lastVisible => _lastVisible;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Place> _data = [];
  List<Place> get data => _data;

  String _popSelection = '';
  String get popupSelection => _popSelection;

  List<DocumentSnapshot> _snap = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = FirebaseAuth.instance.currentUser;


  bool _hasData = false;
  bool get hasData => _hasData;

  Future<void> getData(mounted, String filterBy) async {
    _hasData = true;
    QuerySnapshot rawData;

    if (_lastVisible == null) {
      rawData = filterBy == ''
          ? await firestore.collection('newplaceRequests').where('uploaderId', isEqualTo: user!.uid)
              .orderBy('dateAdded').limit(5).get()
          : await firestore
              .collection('newplaceRequests')
              .where('status', isEqualTo: filterBy)
              .where('uploaderId', isEqualTo: user!.uid)
              .orderBy('dateAdded')
              .limit(5)
              .get();
    } else {
      rawData = filterBy == ''
          ? await firestore.collection('newplaceRequests').where('uploaderId', isEqualTo: user!.uid)
              .orderBy('dateAdded').limit(5).get()
          : await firestore
              .collection('newplaceRequests')
              .where('status', isEqualTo: filterBy)
              .where('uploaderId', isEqualTo: user!.uid)
              .orderBy('dateAdded')
              .startAfter([_lastVisible![filterBy]])
              .limit(5)
              .get();
    }
    if (rawData.docs.isNotEmpty) {
      _lastVisible = rawData.docs[rawData.docs.length - 1];
      if (mounted) {
        _isLoading = false;
        _snap.clear();
        _snap.addAll(rawData.docs);
        _data = _snap.map((e) => Place.fromFirestore(e)).toList();
      }
    } else {
      if (_lastVisible == null) {
        _isLoading = false;
        _hasData = false;
      } else {
        _isLoading = false;
        _hasData = true;
      }
    }

    notifyListeners();
  }

  afterPopSelection(value, mounted, filterBy) {
    _popSelection = value;
    onRefresh(mounted, filterBy);
    notifyListeners();
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  onRefresh(mounted, filterBy) {
    _isLoading = true;
    _snap.clear();
    _data.clear();
    _lastVisible = null;
    getData(mounted, filterBy);
    notifyListeners();
  }
}
