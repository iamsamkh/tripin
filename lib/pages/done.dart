import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import '../pages/intro.dart';
import '../utils/next_screen.dart';

class DonePage extends StatefulWidget {
  const DonePage({Key? key}) : super(key: key);

  @override
  _DonePageState createState() => _DonePageState();
}

class _DonePageState extends State<DonePage> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 2000))
        .then((value) => nextScreenCloseOthers(context, const IntroPage()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SizedBox(
          height: 150,
          width: 150,
          child: FlareActor(
            'assets/flr/success.flr',
            animation: 'success',
            alignment: Alignment.center,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
