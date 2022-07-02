import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import '../blocs/other_places_bloc.dart';
import 'package:provider/provider.dart';
import '../models/place.dart';
import '../pages/place_details.dart';
import '../utils/loading_cards.dart';
import '../utils/next_screen.dart';
import 'custom_cache_image.dart';
import 'package:easy_localization/easy_localization.dart';

class OtherPlaces extends StatefulWidget {
  final String categoryId;
  final String placeId;
  const OtherPlaces({Key? key, required this.categoryId, required this.placeId})
      : super(key: key);

  @override
  _OtherPlacesState createState() => _OtherPlacesState();
}

class _OtherPlacesState extends State<OtherPlaces> {
  @override
  void initState() {
    super.initState();
    context
        .read<OtherPlacesBloc>()
        .getData(widget.categoryId, widget.placeId);
  }

  @override
  Widget build(BuildContext context) {
    final ob = context.watch<OtherPlacesBloc>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          margin: const EdgeInsets.only(
            left: 0,
            top: 10,
          ),
          child: const Text(
            'you may also like',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ).tr(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          height: 3,
          width: 100,
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(40)),
        ),
        SizedBox(
          height: 220,
          //color: Colors.green,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
            padding: const EdgeInsets.only(right: 15, top: 5),
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: ob.data.isEmpty ? 3 : ob.data.length,
            itemBuilder: (BuildContext context, int index) {
              if (ob.data.isEmpty) return const LoadingPopularPlacesCard();
              return ItemList(
                d: ob.data[index],
              );
            },
          ),
        )
      ],
    );
  }
}

class ItemList extends StatelessWidget {
  final Place d;
  const ItemList({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(left: 0, right: 10, top: 5, bottom: 5),
        width: MediaQuery.of(context).size.width * 0.35,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
        child: Stack(
          children: [
            Hero(
              tag: 'others${d.id}',
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CustomCacheImage(imageUrl: d.imageUrl[0])),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20, left: 10, right: 10),
                child: Text(
                  d.name,
                  maxLines: 2,
                  style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                  padding: const EdgeInsets.only(
                    top: 15,
                    right: 15,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.grey[600]!.withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LineIcons.heart, size: 16, color: Colors.white),
                        const SizedBox(
                          width: 5,
                        ),
                        Text(
                          d.loves.toString(),
                          style: const TextStyle(fontSize: 12, color: Colors.white),
                        )
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
      onTap: () =>
          nextScreen(context, PlaceDetails(data: d, tag: 'others${d.id}')),
    );
  }
}
