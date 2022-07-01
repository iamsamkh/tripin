import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String createrId;
  final String createrName;
  final String status;
  final String eventTitle;
  final int duration;
  final int capacity;
  final int seatsBooked;
  final String departCity;
  final String destCity;
  final Timestamp departDate;
  final String travelMode;
  final double price;
  final String description;
  final List<dynamic> facilities;
  final String eventId;
  final Timestamp dateAdded;
  final Timestamp bookingDeadline;
  final dynamic updateTime;

  Event({
    required this.createrId,
    required this.createrName,
    required this.status,
    required this.eventTitle,
    required this.duration,
    required this.capacity,
    required this.seatsBooked,
    required this.departCity,
    required this.destCity,
    required this.departDate,
    required this.travelMode,
    required this.price,
    required this.description,
    required this.facilities,
    required this.eventId,
    required this.dateAdded,
    required this.updateTime,
    required this.bookingDeadline,
  });

  factory Event.fromFirestore(DocumentSnapshot snap) {
    return Event(
        createrId: snap['createrId'],
        createrName: snap['createrName'],
        status: snap['status'],
        eventTitle: snap['eventTitle'],
        duration: snap['duration'],
        capacity: snap['capacity'],
        seatsBooked: snap['seatsBooked'],
        departCity: snap['departCity'],
        destCity: snap['destCity'],
        departDate: snap['deptDate'],
        travelMode: snap['travelMode'],
        price: snap['price'],
        description: snap['description'],
        facilities: snap['facilities'],
        eventId: snap['eventId'],
        dateAdded: snap['dateAdded'],
        updateTime: snap['updateTime'],
        bookingDeadline: snap['bookingDeadline'],
        );
        
  }
}