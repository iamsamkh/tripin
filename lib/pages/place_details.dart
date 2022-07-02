import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:line_icons/line_icons.dart';
import 'package:tripin/utils/loading_cards.dart';
import 'package:tripin/widgets/weather_card.dart';
import 'package:weather/weather.dart';
import '../blocs/bookmark_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../config/config.dart';
import '../models/place.dart';
import '../utils/sign_in_dialog.dart';
import '../widgets/bookmark_icon.dart';
import '../widgets/comment_count.dart';
import '../widgets/custom_cache_image.dart';
import '../widgets/love_count.dart';
import '../widgets/love_icon.dart';
import '../widgets/other_places.dart';
import 'package:provider/provider.dart';
import '../widgets/todo.dart';

class PlaceDetails extends StatefulWidget {
  final Place data;
  final String tag;

  const PlaceDetails({Key? key, required this.data, required this.tag})
      : super(key: key);

  @override
  _PlaceDetailsState createState() => _PlaceDetailsState();
}

class _PlaceDetailsState extends State<PlaceDetails> {

   WeatherFactory wf = WeatherFactory(Config().openWeatherAPIKey);
  
  Future<Weather> getWeather() async{
    Weather w = await wf.currentWeatherByLocation(widget.data.latitude, widget.data.longitude);
    return w;
  }


  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((value) async {});
  }

  String collectionName = 'placesN';

  handleLoveClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onLoveIconClick(collectionName, widget.data.id);
    }
  }

  handleBookmarkClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onBookmarkIconClick(collectionName, widget.data.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = context.watch<SignInBloc>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Stack(
              children: <Widget>[
                Hero(
                  tag: widget.tag,
                  child: Container(
                    color: Colors.white,
                    child: Container(
                      height: 320,
                      width: MediaQuery.of(context).size.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                      ),
                      child: CarouselSlider(options: CarouselOptions(), items: 
                      widget.data.imageUrl.map((e) => CustomCacheImage(imageUrl: e)).toList()
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 20,
                  left: 15,
                  child: SafeArea(
                    child: CircleAvatar(
                      backgroundColor: Colors.blue.withOpacity(0.9),
                      child: IconButton(
                        icon: const Icon(
                          LineIcons.arrowLeft,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 0, left: 15, right: 15, bottom: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        Icons.location_on,
                        size: 20,
                        color: Colors.grey,
                      ),
                      Expanded(
                          child: Text(
                        widget.data.address,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )),
                      IconButton(
                          icon: BuildLoveIcon(
                              collectionName: collectionName,
                              uid: sb.uid.toString(),
                              placeId: widget.data.id),
                          onPressed: () {
                            handleLoveClick();
                          }),
                      IconButton(
                          icon: BuildBookmarkIcon(
                              collectionName: collectionName,
                              uid: sb.uid.toString(),
                              id: widget.data.id),
                          onPressed: () {
                            handleBookmarkClick();
                          }),
                    ],
                  ),
                  Text(widget.data.name,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.grey[800])),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    height: 3,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  Row(
                    children: <Widget>[
                      LoveCount(
                          collectionName: collectionName,
                          timestamp: widget.data.id),
                      const SizedBox(
                        width: 20,
                      ),
                      const Icon(
                        Icons.comment,
                        color: Colors.grey,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      CommentCount(
                          collectionName: collectionName,
                          timestamp: widget.data.id)
                    ],
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Html(data: '''${widget.data.description}''', style: {
                    'body': Style(
                        fontSize: const FontSize(17.0),
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[800]),
                  }),
                  const Divider(
                    thickness: 2,
                  ),
                  // const SizedBox(
                  //   height: 10,
                  // ),
                  FutureBuilder<Weather>(
                      future: getWeather(),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return const LoadingCard(height: 100);
                          default:
                            if (snapshot.hasError){
                              return const Center(child: Text('Error loading Weather Info', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red,),));
                            }
                            else{
                              return WeatherCard(w: snapshot.data!);
                            }

                        }
                      }),
                  const SizedBox(
                    height: 10,
                  ),
                  TodoWidget(placeData: widget.data),
                  const SizedBox(
                    height: 15,
                  ),
                  OtherPlaces(
                    categoryId: widget.data.province,
                    placeId: widget.data.id,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
