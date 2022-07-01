import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../blocs/ads_bloc.dart';
import '../blocs/bookmark_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/blog.dart';
import '../config/config.dart';
import 'experiences.dart';
import '../utils/next_screen.dart';
import '../utils/sign_in_dialog.dart';
import '../widgets/bookmark_icon.dart';
import '../widgets/custom_cache_image.dart';
import '../widgets/love_count.dart';
import '../widgets/love_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class BlogDetails extends StatefulWidget {
  final Blog blogData;
  final String tag;

  const BlogDetails({Key? key, required this.blogData, required this.tag})
      : super(key: key);

  @override
  _BlogDetailsState createState() => _BlogDetailsState();
}

class _BlogDetailsState extends State<BlogDetails> {
  final String collectionName = 'blogs';

  handleLoveClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onLoveIconClick(collectionName, widget.blogData.timestamp);
    }
  }

  handleBookmarkClick() {
    bool _guestUser = context.read<SignInBloc>().guestUser;

    if (_guestUser == true) {
      openSignInDialog(context);
    } else {
      context
          .read<BookmarkBloc>()
          .onBookmarkIconClick(collectionName, widget.blogData.timestamp);
    }
  }

  handleSource(link) async {
    if (await canLaunchUrl(link)) {
      launchUrl(link);
    }
  }

  handleShare() {
    Share.share(
        '${widget.blogData.title}, To read more install ${Config().appName} App. https://play.google.com/store/apps/details?id=com.mrblab.travel_hour');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final SignInBloc sb = context.watch<SignInBloc>();
    final Blog d = widget.blogData;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 35,
                    width: 35,
                    decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5)),
                    child: IconButton(
                      padding: const EdgeInsets.all(0),
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Spacer(),
                  Container(
                      height: 35,
                      width: 35,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(5)),
                      child: IconButton(
                        padding: const EdgeInsets.all(0),
                        icon: const Icon(
                          Icons.share,
                          size: 22,
                        ),
                        onPressed: () {
                          handleShare();
                        },
                      )),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      const Icon(
                        CupertinoIcons.time,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      Text(
                        d.date,
                        style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    d.title,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[800]),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    height: 3,
                    width: 150,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      FlatButton.icon(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.all(0),
                        onPressed: () => handleSource(d.sourceUrl),
                        icon: const FaIcon(FontAwesomeIcons.arrowUpRightFromSquare,
                        //  external_link,
                            size: 20, color: Colors.blueAccent),
                        label: Text(
                          d.sourceUrl.contains('www')
                              ? d.sourceUrl
                                  .replaceAll('https://www.', '')
                                  .split('.')
                                  .first
                              : d.sourceUrl
                                  .replaceAll('https://', '')
                                  .split('.')
                                  .first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Colors.grey[900],
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                          icon: BuildLoveIcon(
                              collectionName: collectionName,
                              uid: sb.uid.toString(),
                              placeId: d.timestamp),
                          onPressed: () {
                            handleLoveClick();
                          }),
                      IconButton(
                          icon: BuildBookmarkIcon(
                              collectionName: collectionName,
                              uid: sb.uid.toString(),
                              id: d.timestamp),
                          onPressed: () {
                            handleBookmarkClick();
                          }),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Hero(
              tag: widget.tag,
              child: SizedBox(
                  height: 220,
                  width: MediaQuery.of(context).size.width,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: CustomCacheImage(imageUrl: d.thumbnailImagelUrl))),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  LoveCount(
                      collectionName: collectionName, timestamp: d.timestamp),
                  const SizedBox(
                    width: 15,
                  ),
                  FlatButton.icon(
                      color: Colors.green[300],
                      onPressed: () {
                        nextScreen(
                            context,
                            ExperiencesPage(
                                collectionName: collectionName,
                                id: d.timestamp));
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('comments').tr())
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Html(
                style: {
                  'body': Style(
                    fontSize: const FontSize(17.0),
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[800] 
                  ),
                },
                // defaultTextStyle: TextStyle(
                //     fontSize: 17,
                //     fontWeight: FontWeight.w400,
                //     color: Colors.grey[800]),
                data: '''  ${d.description}   '''),
            const SizedBox(
              height: 30,
            )
          ]),
        ),
      ),
    );
  }
}
