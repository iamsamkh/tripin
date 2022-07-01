import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../models/notification.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationDetails extends StatelessWidget {
  final NotificationModel data;
  const NotificationDetails({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('notification details').tr(),
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 30, bottom: 15, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(CupertinoIcons.time_solid, size: 20, color: Colors.grey),
              const SizedBox(width: 3,),
              Text(data.createdAt, style: const TextStyle(color: Colors.grey),)
            ],
            ),
            SizedBox(height: 10,),
            Text(data.title, style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700
            ),),
            
            Container(
              margin: EdgeInsets.only(top: 15, bottom: 20),
              height: 3,
              width: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor
              ),
            ),

            HtmlWidget(
                data.description,
                textStyle: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],

                ),
                 
                onTapUrl: (url) async{
                  final parsedUrl = Uri.parse(url); 
                  return await launchUrl(parsedUrl);
                  
                },
              ),
          

            
          ],
        ),
      ),
    );
  }
}
