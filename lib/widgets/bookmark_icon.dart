import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/icon_data.dart';
import 'package:provider/provider.dart';



  class BuildBookmarkIcon extends StatelessWidget {
    final String collectionName;
    final String uid;
    final String id;

    const BuildBookmarkIcon({
      Key? key, 
      required this.collectionName, 
      required this.uid,
      required this.id
      
      }) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      final sb = context.watch<SignInBloc>();
      String _type = collectionName == 'placesN' ? 'bookmarked places' : 'bookmarked blogs';
      if(sb.isSignedIn == false) return BookmarkIcon().normal;
      return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        final data = snap.data;
        // if (uid == null) return BookmarkIcon().normal;
        if (!snap.hasData) return BookmarkIcon().normal;
        List d = data![_type];

        if (d.contains(id)) {
          return BookmarkIcon().bold;
        } else {
          return BookmarkIcon().normal;
        }
      },
    );
    }
  }