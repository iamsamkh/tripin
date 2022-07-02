import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../config/config.dart';
import '../utils/next_screen.dart';
import '../pages/home.dart';
import 'package:easy_localization/easy_localization.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({Key? key}) : super(key: key);

  @override
  _IntroPageState createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          SizedBox(
            height: h * 0.80,
            child: CarouselSlider(
              options: CarouselOptions(
                height: h * 0.6,
                autoPlay: false,),
              items: [
                IntroView(
                    title: 'intro-title1',
                    description: 'intro-description1',
                    image: Config().introImage1),
                IntroView(
                    title: 'intro-title2',
                    description: 'intro-description2',
                    image: Config().introImage2),
                IntroView(
                    title: 'intro-title3',
                    description: 'intro-description3',
                    image: Config().introImage3),
              ],
            ),
          ),
          Container(
            height: 45,
            width: w * 0.70,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: FlatButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25)),
              child: const Text(
                'get started',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
              ).tr(),
              onPressed: () {
                nextScreenReplace(context, const HomePage());
              },
            ),
          ),
          SizedBox(
            height: 0.15.w
          ),
        ],
      ),
    );
  }
}

class IntroView extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  const IntroView(
      {Key? key,
      required this.title,
      required this.description,
      required this.image})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            height: h * 0.34,
            child: Image.asset(image, fit: BoxFit.contain,),
          ),
          SizedBox(
            height: 10.w,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25, right: 25),
            child: Text(
              title,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.grey[800]),
            ).tr(),
          ),
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 10),
            height: 3.w,
            width: 150.w,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(40)),
          ),
          SizedBox(
            height: 15.w,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800]),
            ).tr(),
          ),
        ],
      ),
    );
  }
}
