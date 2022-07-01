import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../utils/snacbar.dart';
import 'package:easy_localization/easy_localization.dart';

class EditProfile extends StatefulWidget {
  
  final String name;
  final String imageUrl;

  const EditProfile({Key? key, required this.name, required this.imageUrl})
      : super(key: key);

  @override
  _EditProfileState createState() =>
      _EditProfileState(this.name, this.imageUrl);
}

class _EditProfileState extends State<EditProfile> {
  _EditProfileState(this.name, this.imageUrl);

  final _fireStorage = FirebaseStorage.instance;
  String name;
  String imageUrl;

  File? imageFile;
  String? fileName;
  bool loading = false;

  var formKey = GlobalKey<FormState>();
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var nameCtrl = TextEditingController();

  Future pickImage() async {
    final _imagePicker = ImagePicker();
    var imagepicked = await _imagePicker.pickImage(
        source: ImageSource.gallery, maxHeight: 200, maxWidth: 200);

    if (imagepicked != null) {
      setState(() {
        imageFile = File(imagepicked.path);
        fileName = (imageFile!.path);
      });
    } else {
      print('No image has is selected!');
    }
  }

  Future uploadPicture() async {
    final SignInBloc sb = context.read<SignInBloc>();
    if (imageFile != null) {
      final ref = _fireStorage.ref('Profile Pictures').child(sb.uid!);
      try {
        await ref.putFile(imageFile!);
        String uploadUrl = await ref.getDownloadURL();
        setState(() {
        imageUrl = uploadUrl;
      });

      } catch (e) {
        print(e);
      }
    }
  }

  handleUpdateData() async {
    final InternetBloc ib = Provider.of<InternetBloc>(context, listen: false);
    final sb = context.read<SignInBloc>();
    await ib.checkInternet();
    if (ib.hasInternet == false) {
      openSnacbar(scaffoldKey, 'no internet'.tr());
    } else {
      if (formKey.currentState!.validate()) {
        formKey.currentState!.save();
        setState(() => loading = true);
        imageFile == null
            ? await sb.updateUserProfile(nameCtrl.text, imageUrl).then((value) {
                openSnacbar(scaffoldKey, 'updated successfully'.tr());
                setState(() => loading = false);
              })
            : await uploadPicture().then((value) =>
                sb.updateUserProfile(nameCtrl.text, imageUrl).then((_) {
                  openSnacbar(scaffoldKey, 'updated successfully'.tr());
                  setState(() => loading = false);
                }));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    nameCtrl.text = name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('edit profile').tr(),
        ),
        body: ListView(
          padding: const EdgeInsets.all(25),
          children: <Widget>[
            InkWell(
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.grey[300],
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey[800]!),
                      color: Colors.grey[500],
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: imageFile == null ? CachedNetworkImageProvider(imageUrl) as ImageProvider: FileImage(imageFile!),
                          // image: FileImage(imageFile!),
                          fit: BoxFit.cover)),
                  child: const Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(
                        Icons.edit,
                        size: 30,
                        color: Colors.black,
                      )),
                ),
              ),
              onTap: () {
                pickImage();
              },
            ),
            const SizedBox(
              height: 50,
            ),
            Form(
                key: formKey,
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'enter new name'.tr(),
                  ),
                  controller: nameCtrl,
                  validator: (value) {
                    if (value!.isEmpty) return "Name can't be empty";
                    return null;
                  },
                )),
            const SizedBox(
              height: 50,
            ),
            SizedBox(
              height: 45,
              width: MediaQuery.of(context).size.width,
              child: RaisedButton(
                textColor: Colors.white,
                color: Theme.of(context).primaryColor,
                child: loading == true
                    ? const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.white,
                        ),
                      )
                    : const Text(
                        'update profile',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ).tr(),
                onPressed: () {
                  handleUpdateData();
                },
              ),
            ),
          ],
        ));
  }
}
