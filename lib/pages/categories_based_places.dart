import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import '../models/place.dart';
import '../pages/place_details.dart';
import '../utils/empty.dart';
import '../utils/next_screen.dart';
import '../widgets/custom_cache_image.dart';
import '../utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoriesBasedPlaces extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final Color color;
  const CategoriesBasedPlaces(
      {Key? key, required this.categoryId, required this.categoryName, required this.color})
      : super(key: key);

  @override
  _CategoriesBasedPlacesState createState() => _CategoriesBasedPlacesState();
}

class _CategoriesBasedPlacesState extends State<CategoriesBasedPlaces> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'placesN';
  ScrollController controller = ScrollController();
  DocumentSnapshot? _lastVisible;
  bool? _isLoading;
  final List<DocumentSnapshot> _snap = [];
  List<Place> _data = [];
  bool? _hasData;

  @override
  void initState() {
    controller.addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    _getData();
  }

  onRefresh() {
    setState(() {
      _snap.clear();
      _data.clear();
      _isLoading = true;
      _lastVisible = null;
    });
    _getData();
  }

  Future<void> _getData() async {
    setState(() => _hasData = true);
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firestore
          .collection(collectionName)
          .where('category', isEqualTo: widget.categoryId)
          .orderBy('loveCount', descending: true)
          .limit(5)
          .get();
    } else {
      data = await firestore
          .collection(collectionName)
          .where('category', isEqualTo: widget.categoryId)
          .orderBy('loveCount', descending: true)
          .startAfter([_lastVisible!['loveCount']])
          .limit(5)
          .get();
    }

    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => Place.fromFirestore(e)).toList();
        });
      }
    } else {
      if (_lastVisible == null) {
        setState(() {
          _isLoading = false;
          _hasData = false;
          print('no items');
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasData = true;
          print('no more items');
        });
      }
    }
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading!) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        child: CustomScrollView(
          controller: controller,
          slivers: <Widget>[
            SliverAppBar(
              automaticallyImplyLeading: false,
              pinned: true,
              actions: <Widget>[
                IconButton(
                  icon: const Icon(
                    Icons.keyboard_arrow_left,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              ],
              backgroundColor: widget.color,
              expandedHeight: 120,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: false,
                background: Container(
                  color: widget.color,
                  height: 120,
                  width: double.infinity,
                ),
                title: Text(
                  widget.categoryName.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
              ),
            ),
            _hasData == false
                ? SliverFillRemaining(
                    child: Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.30,
                      ),
                      EmptyPage(
                          icon: FontAwesomeIcons.clipboard,
                          message: 'no places found'.tr(),
                          message1: ''),
                    ],
                  ))
                : SliverPadding(
                    padding: const EdgeInsets.all(15),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index < _data.length) {
                            return _ListItem(
                              d: _data[index],
                              tag: '${_data[index].id}$index',
                            );
                          }
                          return Opacity(
                            opacity: _isLoading! ? 1.0 : 0.0,
                            child: _lastVisible == null
                                ? Column(
                                    children: const [
                                      LoadingCard(
                                        height: 180,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      )
                                    ],
                                  )
                                : const Center(
                                    child: SizedBox(
                                        width: 32.0,
                                        height: 32.0,
                                        child: CupertinoActivityIndicator()),
                                  ),
                          );
                        },
                        childCount: _data.isEmpty ? 5 : _data.length + 1,
                      ),
                    ),
                  )
          ],
        ),
        onRefresh: () async => onRefresh(),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final Place d;
  final String tag;
  const _ListItem({Key? key, required this.d, required this.tag})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 15),
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    child: Hero(
                      tag: tag,
                      child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(5),
                              topRight: Radius.circular(5)),
                          child: CustomCacheImage(imageUrl: d.imageUrl[0])),
                    )),
                Container(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.name,
                        maxLines: 1,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(
                            FontAwesomeIcons.mapPin,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Expanded(
                            child: Text(
                              d.address,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.time,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            d.id,
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                          const Spacer(),
                          const Icon(
                            LineIcons.heart,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            d.loves.toString(),
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          const Icon(
                            LineIcons.comment,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(
                            width: 3,
                          ),
                          Text(
                            d.experienceCount.toString(),
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[700]),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            )),
      ),
      onTap: () => nextScreen(context, PlaceDetails(data: d, tag: tag)),
    );
  }
}
