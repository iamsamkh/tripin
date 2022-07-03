import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/event.dart';
import '../utils/styles.dart';
import '../utils/toast.dart';

class BookEvent extends StatefulWidget {
  const BookEvent({required this.e, Key? key}) : super(key: key);
  final Event e;
  @override
  _BookEventState createState() => _BookEventState();
}

class _BookEventState extends State<BookEvent> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isUploading = false;
  int _seatsSelected = 1;
  var formKey = GlobalKey<FormState>();
  var nameCtrl = TextEditingController();
  var cnicCtrl = TextEditingController();
  var numberCtrl = TextEditingController();
  var emailCtrl = TextEditingController();

  Timestamp? _timestamp;

  void handleSubmit() async {
    if (_seatsSelected != 0) {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        if (_seatsSelected > widget.e.capacity - widget.e.seatsBooked) {
          openToast1(context,
              'Seats selected exceed available seating capacity');
        } else {
          setState(() => isUploading = true);
          await getDate().then((_) async {
            await saveToDatabase()
                .then((value) {
                  if(value){
                    setState(() => isUploading = false);
                    openToast(context, 'Booking Successful');
                    Navigator.pop(context);
                  }else{
                    setState(() => isUploading = false);
                    openToast(context, 'Seats selected exceed available seating capacity');
                  }
                });
          });
        }
      }
    } else {
      openToast(context, 'Please Select atleast 1 seat..');
    }
  }

  Future getDate() async {
    Timestamp _now = Timestamp.now();
    setState(() {
      _timestamp = _now;
    });
  }

  Future<bool> saveToDatabase() async {
    final sb = Provider.of<SignInBloc>(context, listen: false);
    final _firestore = FirebaseFirestore.instance;
    final DocumentReference ref = _firestore
        .collection('eventBookings')
        .doc();
    final _eventsnap =
        await _firestore.collection('events').doc(widget.e.eventId).get();
    Event eventData = Event.fromFirestore(_eventsnap);
    if (eventData.seatsBooked == eventData.capacity ||
        _seatsSelected > eventData.capacity - eventData.seatsBooked) {
      return false;
    } else {
      var _eventData = {
        'bookingStatus': 'pending',
        'duration': widget.e.duration,
        'userId': sb.uid,
        'fullName': nameCtrl.text,
        'cnic': cnicCtrl.text,
        'contactNumber': numberCtrl.text,
        'bookedSeats': _seatsSelected,
        'email': emailCtrl.text,
        'totalBill': widget.e.price,
        'eventTitle': widget.e.eventTitle,
        'createrId': widget.e.createrId,
        'eventId': widget.e.eventId,
        'bookingDate': _timestamp,
        'bookingId': ref.id,
      };
      await ref.set(_eventData);
      await _firestore
          .collection('events')
          .doc(widget.e.eventId)
          .update({'seatsBooked': eventData.seatsBooked + _seatsSelected});
          return true;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sb = Provider.of<SignInBloc>(context, listen: false);
    nameCtrl.text = sb.name ?? '';
    emailCtrl.text = sb.email ?? '';

    ToastContext().init(context); //
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
            key: formKey,
            child: ListView(children: <Widget>[
              _ListItem(eventData: widget.e),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Expanded(
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('No. of Seats',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600))),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  onPressed: () => setState(() {
                    final newValue = _seatsSelected - 1;
                    _seatsSelected = newValue.clamp(
                        1, widget.e.capacity - widget.e.seatsBooked);
                  }),
                ),
                Text('$_seatsSelected'),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => setState(() {
                    final newValue = _seatsSelected + 1;
                    _seatsSelected = newValue.clamp(
                        1, widget.e.capacity - widget.e.seatsBooked);
                  }),
                ),
              ]),
              const Text(
                'Personl Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration:
                    inputDecoration('Enter Your Name', 'Full Name', nameCtrl),
                controller: nameCtrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: inputDecoration(
                    'CNIC FORMAT: XXXXX-XXXXXXX-X', 'Cnic', cnicCtrl),
                controller: cnicCtrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: inputDecoration('Contact Number: 03xx1xxxxx9',
                    'Contact Number', numberCtrl),
                controller: numberCtrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration:
                    inputDecoration('Enter Your Email', 'Email', emailCtrl),
                controller: emailCtrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              isUploading
                  ? const Center(child: CircularProgressIndicator())
                  : TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor: Colors.green, primary: Colors.white),
                      onPressed: () async {
                        handleSubmit();
                      },
                      child: const Text('Book Event')),
            ])),
      ),
    );
  }
}

class _ListItem extends StatelessWidget {
  final Event eventData;
  const _ListItem({Key? key, required this.eventData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 10, left: 20, right: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                        color: Colors.grey[200]!,
                        blurRadius: 10,
                        offset: const Offset(0, 10))
                  ]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.only(top: 15, left: 15, right: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              eventData.eventTitle,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                color: eventData.status == 'booked'
                                    ? Colors.orangeAccent
                                    : eventData.status == 'active'
                                        ? Colors.green[500]
                                        : eventData.status == 'completed'
                                            ? Colors.blue[500]
                                            : Colors.red[400],
                              ),
                              child: Text(
                                eventData.status == 'booked'
                                    ? 'Booking Completed'
                                    : eventData.status == 'active'
                                        ? 'Active'
                                        : eventData.status == 'completed'
                                            ? 'Completed'
                                            : 'Cancelled',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
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
                            Text(
                              eventData.departCity,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              eventData.travelMode == 'Aeroplane'
                                  ? FontAwesomeIcons.plane
                                  : eventData.travelMode == 'Bus'
                                      ? FontAwesomeIcons.bus
                                      : eventData.travelMode == 'Car'
                                          ? FontAwesomeIcons.car
                                          : FontAwesomeIcons.train,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              child: Text(
                                eventData.destCity,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700]),
                              ),
                            ),
                            Text(
                              DateFormat('d MMMM yyyy ')
                                  .format(eventData.departDate.toDate()),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Seats Booked: ${eventData.seatsBooked}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                            const Spacer(),
                            Text(
                              'Total Capacity: ${eventData.capacity}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Duration: ${eventData.duration}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                            const Spacer(),
                            Text(
                              '${eventData.price} Pkr',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
