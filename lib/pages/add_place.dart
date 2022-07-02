import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:tripin/utils/toast.dart';
import '../blocs/categories_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../utils/loading_cards.dart';
import '../utils/styles.dart';

class AddNewPlace extends StatefulWidget {
  const AddNewPlace({Key? key}) : super(key: key);

  @override
  _AddNewPlaceState createState() => _AddNewPlaceState();
}

class _AddNewPlaceState extends State<AddNewPlace> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool isUploading = false;

  var formKey = GlobalKey<FormState>();
  var nameCtrl = TextEditingController();
  var addressCtrl = TextEditingController();
  var latCtrl = TextEditingController();
  var lngCtrl = TextEditingController();
  var cityCtrl = TextEditingController();
  var provinceCtrl = TextEditingController();
  var facilitesCtrl = TextEditingController();
  var descriptionCtrl = TextEditingController();
  var imageCtrl = TextEditingController();
  var categorySelection;
  List facilities = [];
  List<String> imageUrls = [];
  String _imageUrlsHelperText = 'Enter atleast 1 Image Urls for the Place...';
  String _facilitiesHelperText =
      'Enter facilities list to help users get an idea about the available resources at a certain place...';

  Timestamp? _timestamp;

  void handleSubmit() async {
    if (categorySelection == null) {
      openToast(context, 'Select Category First');
    } else {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        if (facilities.isEmpty || imageUrls.isEmpty) {
          openToast1(
              context, 'Paths, facilities, imageUrl Lists can not be empty');
        } else {
          setState(() => isUploading = true);
          await getDate().then((_) async {
            await saveToDatabase()
                .then((value) => setState(() => isUploading = false));
            openToast(context, 'Uploaded Successfully');
            Navigator.pop(context);
          });
        }
      }
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
        _firestore.collection('newplaceRequests').doc();
    var _placeData = {
      'status': 'pendingApproval',
      'uploaderId': sb.uid,
      'category': categorySelection,
      'placeName': nameCtrl.text,
      'address': addressCtrl.text,
      'city': cityCtrl.text,
      'province': provinceCtrl.text,
      'latitude': double.parse(latCtrl.text),
      'longitude': double.parse(lngCtrl.text),
      'description': descriptionCtrl.text,
      'facilities': facilities,
      'image': imageUrls,
      'loveCount': 0,
      'experienceCount': 0,
      'questionsCount': 0,
      'storiesCount': 0,
      'placeId': ref.id,
      'dateAdded': _timestamp,
      'updateTime': null
    };
    await ref.set(_placeData);
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
        title: const Text('Add Place').tr(),
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
              const SizedBox(
                height: 10,
              ),
              const Text(
                'Place Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(
                height: 10,
              ),
              categoriesDropdown(),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: inputDecoration(
                    'Enter place name', 'Place name', nameCtrl),
                controller: nameCtrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: inputDecoration(
                    'Enter Address name', 'Place Address', addressCtrl),
                controller: addressCtrl,
                validator: (value) {
                  if (value!.isEmpty) return 'Value is empty';
                  return null;
                },
              ),
              const SizedBox(
                height: 20,
              ),

              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration: inputDecoration(
                          'Enter Latitude', 'Latitude', latCtrl),
                      controller: latCtrl,
                      keyboardType: TextInputType.number,
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
                      decoration: inputDecoration(
                          'Enter Longitude', 'Longitude', lngCtrl),
                      keyboardType: TextInputType.number,
                      controller: lngCtrl,
                      validator: (value) {
                        if (value!.isEmpty) return 'Value is empty';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      decoration:
                          inputDecoration('Enter City', 'City', latCtrl),
                      controller: cityCtrl,
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
                      decoration: inputDecoration(
                          'Enter Province', 'Province', lngCtrl),
                      keyboardType: TextInputType.number,
                      controller: provinceCtrl,
                      validator: (value) {
                        if (value!.isEmpty) return 'Value is empty';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText:
                        "Enter Image URLs list one by one by tapping 'Enter' everytime",
                    border: const OutlineInputBorder(),
                    labelText: 'Image Urls List',
                    helperText: _imageUrlsHelperText,
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
                              imageCtrl.clear();
                            }),
                      ),
                    )),
                controller: imageCtrl,
                onFieldSubmitted: (String value) {
                  if (value.isEmpty) {
                    setState(() {
                      _imageUrlsHelperText =
                          "You can't put empty item is the list";
                    });
                  } else {
                    setState(() {
                      imageUrls.add(value);
                      imageCtrl.clear();
                      _imageUrlsHelperText =
                          'Added ${imageUrls.length} items';
                    });
                  }
                },
              ),

              const SizedBox(
                height: 20,
              ),
              Container(
                child: imageUrls.isEmpty
                    ? const Center(
                        child: Text('No path list were added'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: imageUrls.length,
                        itemBuilder: (BuildContext context, int index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text(index.toString()),
                            ),
                            title: Text(imageUrls[index]),
                            trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () {
                                  setState(() {
                                    imageUrls.remove(imageUrls[index]);
                                    _facilitiesHelperText =
                                        'Added ${imageUrls.length} items';
                                  });
                                }),
                          );
                        },
                      ),
              ),
              const SizedBox(
                height: 20,
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
                height: 20,
              ),
              Container(
                child: facilities.isEmpty
                    ? const Center(
                        child: Text('No path list were added'),
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
                height: 20,
              ),
              TextFormField(
                decoration: InputDecoration(
                    hintText: 'Enter place details (Html or Normal Text)',
                    border: const OutlineInputBorder(),
                    labelText: 'Place details',
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
              const SizedBox(
                height: 10,
              ),
              TextButton(
                  style: TextButton.styleFrom(
                      backgroundColor: Colors.green, primary: Colors.white),
                  onPressed: () async {
                    handleSubmit();
                  },
                  child: const Text('Submit')),
            ])),
      ),
    );
  }

  Widget categoriesDropdown() {
    final sb = context.watch<CategoriesBloc>();
    if (sb.hasData) {
      return Container(
          height: 50,
          padding: const EdgeInsets.only(left: 15, right: 15),
          decoration: BoxDecoration(
              color: Colors.grey[200],
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(30)),
          child: DropdownButtonFormField(
              itemHeight: 50,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500),
              decoration: const InputDecoration(border: InputBorder.none),
              onChanged: (value) {
                setState(() {
                  categorySelection = value;
                });
              },
              onSaved: (value) {
                setState(() {
                  categorySelection = value;
                });
              },
              value: categorySelection,
              hint: const Text('Select Category'),
              items: sb.data.map((f) {
                return DropdownMenuItem(
                  child: Text(f.name),
                  value: f.id,
                );
              }).toList()));
    } else {
      return const LoadingCard(height: 40);
    }
  }
}
