import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final int bookedSeats;
  final Timestamp bookingDate;
  final String bookingId;
  final String bookingStatus;
  final String cnic;
  final String contactNumber;
  final String createrId;
  final String email;
  final String eventId;
  final String eventTitle;
  final String fullName;
  final double totalBill;
  final String userId;
  final int duration;

  Booking(
      {required this.bookedSeats,
      required this.bookingDate,
      required this.bookingId,
      required this.bookingStatus,
      required this.cnic,
      required this.contactNumber,
      required this.createrId,
      required this.email,
      required this.eventId,
      required this.eventTitle,
      required this.fullName,
      required this.totalBill,
      required this.userId,
      required this.duration});

  factory Booking.fromFirestore(DocumentSnapshot snap) {
    return Booking(
        bookedSeats: snap['bookedSeats'],
        bookingDate: snap['bookingDate'],
        bookingId: snap['bookingId'],
        bookingStatus: snap['bookingStatus'],
        cnic: snap['cnic'],
        contactNumber: snap['contactNumber'],
        createrId: snap['createrId'],
        email: snap['email'],
        eventId: snap['eventId'],
        eventTitle: snap['eventTitle'],
        fullName: snap['fullName'],
        totalBill: snap['totalBill'],
        userId: snap['userId'],
        duration: snap['duration']);
  }
}
