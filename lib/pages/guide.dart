import 'dart:async';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geo/geo.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../blocs/ads_bloc.dart';
import '../models/colors.dart';
import '../config/config.dart';
import '../models/directions_model.dart';
import '../models/place.dart';
import 'package:easy_localization/easy_localization.dart';
import '../utils/convert_map_icon.dart';
import '../utils/map_util.dart';
import 'package:provider/provider.dart';

class GuidePage extends StatefulWidget {
  final Place d;
  const GuidePage({Key? key, required this.d}) : super(key: key);

  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  late GoogleMapController mapController;

  final List<Marker> _markers = [];
  Map data = {};
  String distance = 'O km';

  // Map<PolylineId, Polyline> polylines = {};
  // List<LatLng> polylineCoordinates = [];
  // PolylinePoints polylinePoints = PolylinePoints();
  Directions? _info;

  late Uint8List _sourceIcon;
  late Uint8List _destinationIcon;

  Future getData() async {
    await FirebaseFirestore.instance
        .collection('placesN')
        .doc(widget.d.id)
        .collection('travel guide')
        .doc(widget.d.id)
        .get()
        .then((DocumentSnapshot snap) {
      setState(() {
        data = snap.data() as Map<dynamic, dynamic>;
      });
    });
  }

  _setMarkerIcons() async {
    _sourceIcon = await getBytesFromAsset(Config().drivingMarkerIcon, 110);
    _destinationIcon =
        await getBytesFromAsset(Config().destinationMarkerIcon, 110);
  }

  Future addMarker() async {
    List m = [
      Marker(
          markerId: MarkerId(data['startpoint name']),
          position: LatLng(data['startpoint lat'], data['startpoint lng']),
          infoWindow: InfoWindow(title: data['startpoint name']),
          icon: BitmapDescriptor.fromBytes(_sourceIcon)),
      Marker(
          markerId: MarkerId(data['endpoint name']),
          position: LatLng(data['endpoint lat'], data['endpoint lng']),
          infoWindow: InfoWindow(title: data['endpoint name']),
          icon: BitmapDescriptor.fromBytes(_destinationIcon))
    ];
    setState(() {
      for (var element in m) {
        _markers.add(element);
      }
    });
  }

  // Future computeDistance() async {
  //   var p1 = geo.LatLng(data['startpoint lat'], data['startpoint lng']);
  //   var p2 = geo.LatLng(data['endpoint lat'], data['endpoint lng']);
  //   double _distance = geo.computeDistanceBetween(p1, p2) / 1000;
  //   setState(() {
  //     distance = '${_distance.toStringAsFixed(2)} km';
  //   });
  // }
  
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/directions/json?';
  Future<Directions> getDirections(LatLng origin, LatLng destination)async{
    final response = await Dio().get(_baseUrl, queryParameters: {
      'origin': '${origin.latitude},${origin.longitude}',
      'destination': '${destination.latitude},${destination.longitude}',
      'key': Config().mapAPIKey,
    });

    if(response.statusCode == 200) {
      print(response.statusMessage);
      return Directions.fromMap(response.data);
    }
    throw('error');
  }
  Future<void> temp()async{
    final directions = await getDirections(LatLng(data['startpoint lat'], data['startpoint lng']), LatLng(data['endpoint lat'], data['endpoint lng']));
    print(directions.polylinePoints);
    setState(() {
      _info = directions;
    });
  }
  // Future _getPolyline() async {
  //   PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
  //     Config().mapAPIKey,
  //     PointLatLng(data['startpoint lat'], data['startpoint lng']),
  //     PointLatLng(data['endpoint lat'], data['endpoint lng']),
  //     travelMode: TravelMode.driving,
  //   );
  //   if (result.points.isNotEmpty) {
  //     for (var point in result.points) {
  //       polylineCoordinates.add(LatLng(point.latitude, point.longitude));
  //     }
  //     print('PolyLine: $polylineCoordinates');
  //   }
  //   _addPolyLine();
  // }

  // _addPolyLine() {
  //   PolylineId id = PolylineId("poly");
  //   Polyline polyline = Polyline(
  //       polylineId: id,
  //       color: const Color.fromARGB(255, 40, 122, 198),
  //       points: polylineCoordinates);
  //   polylines[id] = polyline;
  //   setState(() {});
  // }

  void animateCamera() {
    mapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(data['startpoint lat'], data['startpoint lng']),
        zoom: 8,
        bearing: 120)));
  }

  void onMapCreated(controller) {
    controller.setMapStyle(MapUtils.mapStyles);
    setState(() {
      mapController = controller;
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((value) async {
      // context.read<AdsBloc>().initiateAds();
    });
    _setMarkerIcons();
    getData().then((value) => addMarker().then((value) => temp().then((value) {
          // _getPolyline();
          // computeDistance();
          animateCamera();
        })));
  }

  Widget panelUI() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 30,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: const BorderRadius.all(Radius.circular(12.0))),
            ),
          ],
        ),
        const SizedBox(
          height: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              "travel guide",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ).tr(),
          ],
        ),
        RichText(
            text: TextSpan(
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 15,
                    fontWeight: FontWeight.normal),
                text: 'estimated cost = '.tr(),
                children: <TextSpan>[
              TextSpan(
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  text: data['price'])
            ])),
        RichText(
            text: TextSpan(
                style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 15,
                    fontWeight: FontWeight.normal),
                text: 'distance = '.tr(),
                children: <TextSpan>[
              TextSpan(
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  text: distance)
            ])),
        Container(
          margin: const EdgeInsets.only(top: 8, bottom: 8),
          height: 3,
          width: 170,
          decoration: BoxDecoration(
              color: Colors.blueAccent,
              borderRadius: BorderRadius.circular(40)),
        ),
        Container(
            padding: const EdgeInsets.all(15),
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'steps',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                ).tr(),
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  height: 3,
                  width: 70,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(40)),
                ),
              ],
            )),
        Expanded(
          child: data.isEmpty
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 10),
                  itemCount: data['paths'].length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Row(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              CircleAvatar(
                                  radius: 15,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor:
                                      ColorList().guideColors[index]),
                              Container(
                                height: 90,
                                width: 2,
                                color: Colors.black12,
                              )
                            ],
                          ),
                          const SizedBox(
                            width: 15,
                          ),
                          SizedBox(
                            child: Expanded(
                              child: Text(
                                data['paths'][index],
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox();
                  },
                ),
        ),
      ],
    );
  }

  Widget panelBodyUI(h, w) {
    return SizedBox(
      width: w,
      child: GoogleMap(
        initialCameraPosition: Config().initialCameraPosition,
        mapType: MapType.normal,
        onMapCreated: (controller) => onMapCreated(controller),
        markers: Set.from(_markers),
        // polylines: Set<Polyline>.of(polylines.values),
        polylines: {
          if(_info != null)
          Polyline(polylineId: const PolylineId('Polyline'),
          color: Colors.red,
          width: 5,
          points: _info!.polylinePoints.map((e) => LatLng(e.latitude, e.longitude)).toList()
          ),
        },
        compassEnabled: true,
        myLocationEnabled: false,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: Stack(children: <Widget>[
        SlidingUpPanel(
            minHeight: 125,
            maxHeight: MediaQuery.of(context).size.height * 0.80,
            backdropEnabled: true,
            backdropOpacity: 0.2,
            backdropTapClosesPanel: true,
            isDraggable: true,
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15), topRight: Radius.circular(15)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey[400]!, blurRadius: 4, offset: const Offset(1, 0))
            ],
            padding: const EdgeInsets.only(top: 15, left: 10, bottom: 0, right: 10),
            panel: panelUI(),
            body: 
            panelBodyUI(h, w)
            ),
        Positioned(
          top: 15,
          left: 10,
          child: SizedBox(
            child: Row(
              children: <Widget>[
                InkWell(
                  child: Container(
                    height: 45,
                    width: 45,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                              color: Colors.grey[300]!,
                              blurRadius: 10,
                              offset: const Offset(3, 3))
                        ]),
                    child: const Icon(Icons.keyboard_backspace),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(
                  width: 5,
                ),
                data.isEmpty
                    ? Container()
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey, width: 0.5)),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 15, top: 10, bottom: 10, right: 15),
                          child: Text(
                            '${data['startpoint name']} - ${data['endpoint name']}',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
        data.isEmpty 
        // && polylines.isEmpty
            ? const Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              )
            : Container()
      ]),
    ));
  }
}
