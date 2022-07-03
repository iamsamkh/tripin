import 'dart:async';
import 'dart:typed_data';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';
import 'package:tripin/utils/location_services.dart';
import '../config/config.dart';
import '../models/place.dart';
import '../utils/convert_map_icon.dart';

class GuidePage extends StatefulWidget {
  final Place place;
  const GuidePage({Key? key, required this.place}) : super(key: key);

  @override
  State<GuidePage> createState() => GuidePageState();
}

class GuidePageState extends State<GuidePage> {
  Completer<GoogleMapController> _controller = Completer();
  Uint8List? _sourceIcon;
  Uint8List? _destinationIcon;

  int _polylineIdVal = 1;
  Set<Marker> _markers = Set<Marker>();
  Set<Polyline> _polyline = Set<Polyline>();

  String distance = 'Loading';
  String duration = 'Loading';

  @override
  void initState() {
    super.initState();
    _setMarkerIcons().then((_) => determinePosition().then((value) {
          if (value != null) {
            placemarkFromCoordinates(value.latitude, value.longitude).then((placemart) =>  LocationService()
                .getDirections(
                    // '${value.latitude},${value.longitude}',
                    placemart[0].name!,
                    widget.place.name
                    // '${widget.place.latitude},${widget.place.longitude}'
                    )
                .then((direction) {
              _setMarker(
                  LatLng(direction['start_location']['lat'],
                      direction['start_location']['lng']),
                  'You',
                  _sourceIcon);
              _setMarker(
                  LatLng(direction['end_location']['lat'],
                      direction['end_location']['lng']),
                  widget.place.name,
                  _destinationIcon);
              _setPolyline(direction['polyline_decode']);
              _goToMyLocation(
                  LatLng(direction['start_location']['lat'],
                      direction['start_location']['lng']),
                  direction['bound_ne'],
                  direction['bound_sw']);
              setState(() {
                distance = direction['distance'];
                duration = direction['duration'];
              });
            }).catchError((_) {
              print('error');
            }));
            
          }
        }));
  }

  void _setMarker(LatLng point, String id, icon) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(id),
        infoWindow: InfoWindow(title: id),
        position: point,
        icon: BitmapDescriptor.fromBytes(icon),
      ));
    });
  }

  void _setPolyline(List<PointLatLng> point) {
    final String polylineIdVal = 'polyine_$_polylineIdVal';
    _polylineIdVal++;

    _polyline.add(Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 3,
        color: Colors.green[800]!,
        points: point
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList()));
  }

  Future _setMarkerIcons() async {
    _sourceIcon = await getBytesFromAsset(Config().drivingMarkerIcon, 110);
    _destinationIcon =
        await getBytesFromAsset(Config().destinationMarkerIcon, 110);
  }

  Future<void> _goToMyLocation(LatLng point, Map<String, dynamic> boundsNe,
      Map<String, dynamic> boundsSW) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSW['lat'], boundsSW['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));
  }

  Future<dynamic> determinePosition() async {
    Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  // Test if location services are enabled.
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    // Location services are not enabled don't continue
    // accessing the position and request users of the 
    // App to enable the location services.
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Permissions are denied, next time you could try
      // requesting permissions again (this is also where
      // Android's shouldShowRequestPermissionRationale 
      // returned true. According to Android guidelines
      // your App should show an explanatory UI now.
      return Future.error('Location permissions are denied');
    }
  }
  
  if (permission == LocationPermission.deniedForever) {
    // Permissions are denied forever, handle appropriately. 
    return Future.error(
      'Location permissions are permanently denied, we cannot request permissions.');
  } 

  // When we reach here, permissions are granted and we can
  // continue accessing the position of the device.
  return await Geolocator.getCurrentPosition();
}
    // Location location = Location();

    // bool _serviceEnabled;
    // PermissionStatus _permissionGranted;
    // LocationData _locationData;

    // _serviceEnabled = await location.serviceEnabled();
    // if (!_serviceEnabled) {
    //   _serviceEnabled = await location.requestService();
    //   if (!_serviceEnabled) {
    //     return null;
    //   }
    // }

    // _permissionGranted = await location.hasPermission();
    // if (_permissionGranted == PermissionStatus.denied) {
    //   _permissionGranted = await location.requestPermission();
    //   if (_permissionGranted != PermissionStatus.granted) {
    //     return null;
    //   }
    // }
    // _locationData = await location.getLocation();
    // return _locationData;
  }

  Widget panelBodyUI(h, w) {
    return Column(children: [
      SizedBox(
        width: w,
        height: h * 0.8,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: Config().initialCameraPosition,
          markers: _markers,
          polylines: _polyline,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
      ),
      Column(
        children: <Widget>[
          const SizedBox(
            height: 20.0,
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
                  text: 'distance = '.tr(),
                  children: <TextSpan>[
                TextSpan(
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    text: distance)
              ])),
          RichText(
              text: TextSpan(
                  style: TextStyle(
                      color: Colors.grey[800],
                      fontSize: 15,
                      fontWeight: FontWeight.normal),
                  text: 'Travel Time = '.tr(),
                  children: <TextSpan>[
                TextSpan(
                    style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                    text: duration)
              ])),
        ],
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        body: SafeArea(
      child: Stack(children: <Widget>[
        panelBodyUI(h, w),
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
                Container(
                  width: MediaQuery.of(context).size.width * 0.80,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey, width: 0.5)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 15, top: 10, bottom: 10, right: 15),
                    child: Text(
                      'You - ${widget.place.name}',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // data.isEmpty && polylines.isEmpty
        //     ? const Align(
        //         alignment: Alignment.center,
        //         child: CircularProgressIndicator(),
        //       )
        //     : Container()
      ]),
    ));
  }
}
