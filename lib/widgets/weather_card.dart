import 'package:flutter/material.dart';
import 'package:weather/weather.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({required this.w, Key? key}) : super(key: key);
  final Weather w;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(5.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Local Weather', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
          const SizedBox(height: 2,),
          const Text('Plan your trip accordingly.', style: TextStyle(fontSize: 12),),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Expanded(
              child: Column(
                children: [
                const Text('Today', style: TextStyle(fontSize: 12)),
                Text(w.weatherMain.toString(), style:const TextStyle(fontWeight: FontWeight.bold),),
                Text(w.temperature.toString(), style: const TextStyle(fontSize: 18),)
              ],),
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  const Text('FEELS LIKE', style: TextStyle(fontSize: 12)),
                  Text(w.tempFeelsLike.toString(), style: const TextStyle(fontSize: 12)),
                ],),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  const Text('HUMIDITY', style: TextStyle(fontSize: 12)),
                  Text('${w.humidity}%', style: const TextStyle(fontSize: 12)),
                ],),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  const Text('WIND', style: TextStyle(fontSize: 12)),
                  Text('${w.windSpeed}km/h', style: const TextStyle(fontSize: 12)),
                ],),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  const Text('PRESSURE', style: TextStyle(fontSize: 12)),
                  Text('${w.pressure}hPa', style: const TextStyle(fontSize: 12)),
                ],),
              ],),
            )
          ],)
        ],
      ),
    );
  }
}