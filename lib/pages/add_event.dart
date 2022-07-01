import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:tripin/utils/toast.dart';
import '../blocs/categories_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../utils/styles.dart';

class AddNewEvent extends StatefulWidget {
  const AddNewEvent({Key? key}) : super(key: key);

  @override
  _AddNewEventState createState() => _AddNewEventState();
}

class _AddNewEventState extends State<AddNewEvent> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isUploading = false;
  DateTime? departDate;
  DateTime? deadline;
  var formKey = GlobalKey<FormState>();
  var titleCtrl = TextEditingController();
  var duarationCtrl = TextEditingController();
  var capacityCtrl = TextEditingController();
  var departCtrl = TextEditingController();
  var destCtrl = TextEditingController();
  var priceCtrl = TextEditingController();
  var facilitesCtrl = TextEditingController();
  var descriptionCtrl = TextEditingController();
  String modeSelection = '';
  List<String> mode = ['Aeroplane', 'Bus', 'Car', 'Train'];
  List facilities = [];
  String _facilitiesHelperText =
      'Enter facilities list to help users get an idea about the available resources at a certain place...';

  Timestamp? _timestamp;

  void handleSubmit() async {
    if (modeSelection.isNotEmpty) {
      if(departDate != null && deadline !=null){
        if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      if (facilities.isEmpty) {
        openToast1(context, 'facilities');
      } else {
        setState(() => isUploading = true);
        await getDate().then((_) async {
          await saveToDatabase()
              .then((value) => setState(() => isUploading = false));
          openToast(context, 'Uploaded Successfully');
          // Navigator.pop(context);
        }
        );
      }
      }
      }else{
        openToast(context, 'Please Select Departure Date & Booking Deadline');
      }
    
    } else {
      openToast(context, 'Please Select Mode of Travel');
    }
  } 

  Future getDate() async {
    Timestamp _now = Timestamp.now();
    setState(() {
      _timestamp = _now;
    });
  }

  Future<void> saveToDatabase() async {
    final sb = Provider.of<SignInBloc>(context, listen: false);
    final _firestore = FirebaseFirestore.instance;
    final DocumentReference ref =
        _firestore.collection('events').doc();
    var _eventData = {
      'createrId': sb.uid,
      'createrName': sb.name,
      'status': 'active',
      'eventTitle': titleCtrl.text,
      'duration': int.parse(duarationCtrl.text),
      'capacity': int.parse(capacityCtrl.text),
      'seatsBooked': 0,
      'departCity': departCtrl.text,
      'destCity': destCtrl.text,
      'deptDate': departDate,
      'travelMode': modeSelection,
      'price': double.parse(priceCtrl.text),
      'description': descriptionCtrl.text,
      'facilities': facilities,
      'eventId': ref.id,
      'dateAdded': _timestamp,
      'bookingDeadline': deadline,
      'updateTime': null
    };
    await ref.set(_eventData);
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((value) {
      context.read<CategoriesBloc>().getData(mounted);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context); //
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text('New Event').tr(),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: Colors.black,
        ),
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              FontAwesomeIcons.xmark,
              size: 22,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
            key: formKey,
            child: ListView(children: <Widget>[
              // const SizedBox(
              //   height: 20,
              // ),
              TextFormField(
                decoration: inputDecoration(
                    'Enter Event Title', 'Event Title', titleCtrl),
                controller: titleCtrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: inputDecoration(
                          'Enter number of days', 'Duration', duarationCtrl),
                      controller: duarationCtrl,
                      validator: (value) {
                        if (value!.isEmpty) return 'Value is empty';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: inputDecoration('Enter total available seats',
                          'Capacity', capacityCtrl),
                      keyboardType: TextInputType.number,
                      controller: capacityCtrl,
                      validator: (value) {
                        if (value!.isEmpty) return 'Value is empty';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: inputDecoration('Enter the City of Departure',
                          'Departure City', departCtrl),
                      controller: departCtrl,
                      validator: (value) {
                        if (value!.isEmpty) return 'Value is empty';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: inputDecoration('Enter the Desitination City',
                          'Destination City', destCtrl),
                      controller: destCtrl,
                      validator: (value) {
                        if (value!.isEmpty) return 'Value is empty';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<String>(
                itemHeight: 50,
                hint: const Text('Select Mode of Transport'),
                onChanged: (value) {
                  setState(() {
                    modeSelection = value!;
                  });
                },
                onSaved: (value) {
                  setState(() {
                    modeSelection = value!;
                  });
                },
                // value: modeSelection,
                items: mode.map((e) {
                  return DropdownMenuItem(child: Text(e), value: e);
                }).toList(),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: inputDecoration(
                    'Enter Event Cost For Per Person in Pkr',
                    'Price',
                    priceCtrl),
                controller: priceCtrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText:
                        "Enter facility list one by one by tapping 'Enter' everytime",
                    border: const OutlineInputBorder(),
                    labelText: 'Facilities list',
                    helperText: _facilitiesHelperText,
                    contentPadding: const EdgeInsets.only(
                        right: 0, left: 10, top: 15, bottom: 5),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey[300],
                        child: IconButton(
                            icon: const Icon(
                              Icons.clear,
                              size: 15,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              facilitesCtrl.clear();
                            }),
                      ),
                    )),
                controller: facilitesCtrl,
                onFieldSubmitted: (String value) {
                  if (value.isEmpty) {
                    setState(() {
                      _facilitiesHelperText =
                          "You can't put empty item is the list";
                    });
                  } else {
                    setState(() {
                      facilities.add(value);
                      facilitesCtrl.clear();
                      _facilitiesHelperText =
                          'Added ${facilities.length} items';
                    });
                  }
                },
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                child: facilities.isEmpty
                    ? const Center(
                        child: Text('No facilities were added'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: facilities.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(index.toString()),
                            ),
                            title: Text(facilities[index]),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  setState(() {
                                    facilities.remove(facilities[index]);
                                    _facilitiesHelperText =
                                        'Added ${facilities.length} items';
                                  });
                                }),
                          );
                        },
                      ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Enter all the details about the event',
                    border: const OutlineInputBorder(),
                    labelText: 'Description',
                    contentPadding: const EdgeInsets.only(
                        right: 0, left: 10, top: 15, bottom: 5),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.grey[300],
                        child: IconButton(
                            icon: const Icon(Icons.close, size: 15),
                            onPressed: () {
                              descriptionCtrl.clear();
                            }),
                      ),
                    )),
                textAlignVertical: TextAlignVertical.top,
                minLines: 5,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                controller: descriptionCtrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        const Text('Departure Date: '),
                        if (departDate != null)
                          Text(
                            DateFormat('d MMMM y').format(departDate!),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    )),
                    TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1));
                          setState(() {
                            departDate = date;
                          });
                        },
                        child: const Text('Select')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Row(
                      children: [
                        const Text('Booking Deadline: '),
                        if (deadline != null)
                          Text(
                            DateFormat('d MMMM y').format(deadline!),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                      ],
                    )),
                    TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(DateTime.now().year + 1));
                          setState(() {
                            deadline = date;
                          });
                        },
                        child: const Text('Select')),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.green, primary: Colors.white),
                  onPressed: () async {
                    handleSubmit();
                  },
                  child: const Text('Create Event')),
            ])),
      ),
    );
  }
}
