import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';

class Capsule extends StatelessWidget {
  final String val;
  const Capsule({Key? key, required this.val}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.green, borderRadius: BorderRadius.circular(30),),
      child: Text(val, style: const TextStyle(color: Colors.white,),),
    );
  }
}
