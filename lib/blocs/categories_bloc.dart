import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/category.dart';

class CategoriesBloc extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<CategoriesModel> _data = [];
  List<CategoriesModel> get data => _data;

  List<DocumentSnapshot> _snap = [];
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  bool _hasData = false;
  bool get hasData => _hasData;

  Future<void> getData(mounted) async {
    if (!_hasData) {
      _hasData = true;
      QuerySnapshot rawData;
      rawData = await firestore
          .collection('categories')
          .orderBy('id', descending: false)
          .get();

      if (rawData.docs.isNotEmpty) {
        if (mounted) {
          _isLoading = false;
          _snap.clear();
          _snap.addAll(rawData.docs);
          _data = _snap.map((e) => CategoriesModel.fromFirestore(e)).toList();
        }
      }
    }

    notifyListeners();
  }

  setLoading(bool isloading) {
    _isLoading = isloading;
    notifyListeners();
  }

  onRefresh(mounted) {
    _isLoading = true;
    _hasData = false;
    _snap.clear();
    _data.clear();
    getData(mounted);
    notifyListeners();
  }

  onReload(mounted) {
    _isLoading = true;
    _hasData = false;
    _snap.clear();
    _data.clear();
    getData(mounted);
    notifyListeners();
  }
}
