import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icons.dart';
import '../models/place.dart';
import '../pages/place_details.dart';
import '../utils/next_screen.dart';
import '../widgets/custom_cache_image.dart';
import '../utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

class MorePlacesPage extends StatefulWidget {
  final String title;
  final Color color;
  const MorePlacesPage({Key? key, required this.title, required this. color}) : super(key: key);

  @override
  _MorePlacesPageState createState() => _MorePlacesPageState();
}

class _MorePlacesPageState extends State<MorePlacesPage> {



  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String collectionName = 'placesN';
  ScrollController controller = ScrollController();
  DocumentSnapshot? _lastVisible;
  bool? _isLoading;
  List<DocumentSnapshot> _snap = [];
  List<Place> _data = [];
  bool? _descending;
  String? _orderBy;

  @override
  void initState() {
    controller.addListener(_scrollListener);
    super.initState();
    _isLoading = true;
    if(widget.title == 'popular'){
      _orderBy = 'loveCount';
      _descending = true;
    }else if(widget.title == 'recommended'){
      _orderBy = 'experienceCount';
      _descending = true;
    }else{
      _orderBy = 'dateAdded';
      _descending = false;
    }
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




  Future<Null> _getData() async {
    QuerySnapshot data;
    if (_lastVisible == null){
      data = await firestore
          .collection(collectionName)
          .orderBy(_orderBy!, descending: _descending!)
          .limit(5)
          .get();
    }
      
    else{
      data = await firestore
          .collection(collectionName)
          .orderBy(_orderBy!, descending: _descending!)
          .startAfter([_lastVisible![_orderBy!]])
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
      setState(() => _isLoading = false);
    }
    return null;
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
                  '${widget.title} places',
                  style: GoogleFonts.montserrat(
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),
                  
                ).tr(),
                titlePadding: const EdgeInsets.only(left: 20, bottom: 15),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(15),
                sliver : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index < _data.length) {
                      return _ListItem(d: _data[index], tag: '${widget.title}$index',);
                    }
                    return Opacity(
                  opacity: _isLoading! ? 1.0 : 0.0,
                  child: _lastVisible == null
                  ? Column(
                    children: const[
                      LoadingCard(height: 180,),
                      SizedBox(height: 15,)
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
                  childCount: _data.isEmpty ? 5  : _data.length+ 1,
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
  final tag;
  const _ListItem({Key? key, required this.d, required this.tag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
          child: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5),
            boxShadow: <BoxShadow>[
              BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 10,
              offset: const Offset(0, 3)
            )
            ]
          ),
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
                        topRight: Radius.circular(5)
                      ),
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
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(
                  // Feather.map_pin,
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
                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
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
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            )
                ],
              ),
            ),
            
          ],
        )),
      ),

      onTap: ()=> nextScreen(context, PlaceDetails(data: d, tag: tag)),
    );
  }
}
