import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/icon_data.dart';
import 'package:provider/provider.dart';



  class BuildLoveIcon extends StatelessWidget {
    final String collectionName;
    final String uid;
    final String placeId;

    const BuildLoveIcon({
      Key? key, 
      required this.collectionName, 
      required this.uid,
      required this.placeId
      
      }) : super(key: key);
  
    @override
    Widget build(BuildContext context) {
      final sb = context.watch<SignInBloc>();
      String _type = collectionName == 'placesN' ? 'loved places' : 'loved blogs';
      if(sb.isSignedIn == false) return LoveIcon().normal;
      return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        final data = snap.data;
        if (!snap.hasData) return LoveIcon().normal;
        List d = data![_type];

        if (d.contains(placeId)) {
          return LoveIcon().bold;
        } else {
          return LoveIcon().normal;
        }
      },
    );
    }
  }