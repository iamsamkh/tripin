import 'dart:convert' as convert;

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:tripin/config/config.dart';

class LocationService {
  final String key = Config().mapAPIKey;

  Future<Map> getDirections(String origin, String destination) async {
    print(origin);
    print(destination);
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination&key=$key';

    var response = await http.get(Uri.parse(url));
    try{
      var json = convert.jsonDecode(response.body);
    print(json);
    var result = {
      'bound_ne': json['routes'][0]['bounds']['northeast'],
      'bound_sw': json['routes'][0]['bounds']['southwest'],
      'start_location': json['routes'][0]['legs'][0]['start_location'],
      'end_location': json['routes'][0]['legs'][0]['end_location'],
      'polyline': json['routes'][0]['overview_polyline']['points'],
      'polyline_decode': PolylinePoints()
          .decodePolyline(json['routes'][0]['overview_polyline']['points']),
      'distance': json['routes'][0]['legs'][0]['distance']['text'],
      'duration': json['routes'][0]['legs'][0]['duration']['text'],
    };
    return result;
    }catch(_){
      return Future.error('Error');
    }
  }
}
