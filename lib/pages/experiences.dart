import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import '../blocs/comments_bloc.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/experience.dart';
import '../utils/empty.dart';
import '../utils/loading_cards.dart';
import '../utils/sign_in_dialog.dart';
import '../utils/toast.dart';
import 'package:easy_localization/easy_localization.dart';

class ExperiencesPage extends StatefulWidget {
  final String collectionName;
  final String id;
  const ExperiencesPage(
      {Key? key, required this.collectionName, required this.id})
      : super(key: key);

  @override
  _ExperiencesPageState createState() => _ExperiencesPageState();
}

class _ExperiencesPageState extends State<ExperiencesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  ScrollController controller = ScrollController();
  DocumentSnapshot? _lastVisible;
  bool _isLoading = true;
  List<DocumentSnapshot> _snap = [];
  List<Experience> _data = [];
  final scaffoldKey = GlobalKey<ScaffoldState>();
  var textCtrl = TextEditingController();
  bool? _hasData;

  @override
  void initState() {
    controller.addListener(_scrollListener);
    super.initState();
    // _isLoading = true;
    _getData();
  }

  Future<void> _getData() async {
    setState(() => _hasData = true);
    QuerySnapshot data;
    if (_lastVisible == null) {
      data = await firestore
          .collection('${widget.collectionName}/${widget.id}/comments')
          .orderBy('reviewTime', descending: true)
          .limit(7)
          .get();
    } else {
      data = await firestore
          .collection('${widget.collectionName}/${widget.id}/comments')
          .orderBy('reviewTime', descending: true)
          .startAfter([_lastVisible!['reviewTime']])
          .limit(7)
          .get();
    }

    if (data.docs.isNotEmpty) {
      _lastVisible = data.docs[data.docs.length - 1];
      if (mounted) {
        setState(() {
          _isLoading = false;
          _snap.addAll(data.docs);
          _data = _snap.map((e) => Experience.fromFirestore(e)).toList();
          print('blog reviews : ${_data.length}');
        });
      }
    } else {
      if (_lastVisible == null) {
        setState(() {
          _isLoading = false;
          _hasData = false;
          print('no items');
        });
      } else {
        setState(() {
          _isLoading = false;
          _hasData = true;
          print('no more items');
        });
      }
    }
    return null;
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    if (!_isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        setState(() => _isLoading = true);
        _getData();
      }
    }
  }

  handleDelete(context, Experience d) {
    final SignInBloc sb = Provider.of<SignInBloc>(context, listen: false);
    final ib = Provider.of<InternetBloc>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(50),
            elevation: 0,
            children: <Widget>[
              const Text('delete?',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w900))
                  .tr(),
              const SizedBox(
                height: 10,
              ),
              Text('delete from database?',
                      style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 16,
                          fontWeight: FontWeight.w700))
                  .tr(),
              const SizedBox(
                height: 30,
              ),
              Center(
                  child: Row(
                children: <Widget>[
                  FlatButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                      color: Colors.redAccent,
                      child: const Text(
                        'yes',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ).tr(),
                      onPressed: () async {
                        await ib.checkInternet();
                        if (ib.hasInternet == false) {
                          Navigator.pop(context);
                          openToast(context, 'no internet'.tr());
                        } else {
                          if (sb.uid != d.uid) {
                            Navigator.pop(context);
                            openToast(
                                context, 'You can not delete others comment');
                          } else {
                            await context.read<CommentsBloc>().deleteComment(
                                widget.collectionName,
                                widget.id,
                                sb.uid,
                                d.reviewTime);

                            onRefreshData();
                            Navigator.pop(context);
                          }
                        }
                      }),
                  SizedBox(width: 10),
                  FlatButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    color: Colors.deepPurpleAccent,
                    child: Text(
                      'no',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ).tr(),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ))
            ],
          );
        });
  }

  Future handleSubmit() async {
    final ib = Provider.of<InternetBloc>(context, listen: false);
    final SignInBloc sb = context.read<SignInBloc>();
    if (sb.guestUser == true) {
      openSignInDialog(context);
    } else {
      await ib.checkInternet();
      if (textCtrl.text == null || textCtrl.text.isEmpty) {
        print('Comment is empty');
      } else {
        if (ib.hasInternet == false) {
          openToast(context, 'no internet'.tr());
        } else {
          context.read<CommentsBloc>().saveNewComment(
              widget.collectionName, widget.id, textCtrl.text);
          onRefreshData();
          textCtrl.clear();
          FocusScope.of(context).requestFocus(FocusNode());
        }
      }
    }
  }

  onRefreshData() {
    setState(() {
      _isLoading = true;
      _snap.clear();
      _data.clear();
      _lastVisible = null;
    });
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
                widget.collectionName == 'places' ? 'user reviews' : 'comments')
            .tr(),
        titleSpacing: 0,
        actions: [
          IconButton(
              icon: Icon(
                // Feather.rotate_cw,
                FontAwesomeIcons.rotate,
                size: 22,
              ),
              onPressed: () => onRefreshData())
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              child: _hasData == false
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.35,
                        ),
                        EmptyPage(
                            icon: LineIcons.comments,
                            message: 'no comments found'.tr(),
                            message1: 'be the first to comment'.tr()),
                      ],
                    )
                  : ListView.separated(
                      padding: EdgeInsets.all(15),
                      controller: controller,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemCount: _data.length != 0 ? _data.length + 1 : 10,
                      separatorBuilder: (BuildContext context, int index) =>
                          SizedBox(
                        height: 10,
                      ),
                      itemBuilder: (_, int index) {
                        if (index < _data.length) {
                          return reviewList(_data[index]);
                        }
                        return Opacity(
                          opacity: _isLoading ? 1.0 : 0.0,
                          child: _lastVisible == null
                              ? LoadingCard(height: 100)
                              : Center(
                                  child: SizedBox(
                                      width: 32.0,
                                      height: 32.0,
                                      child: new CupertinoActivityIndicator()),
                                ),
                        );
                      },
                    ),
              onRefresh: () async {
                onRefreshData();
              },
            ),
          ),
          Divider(
            height: 1,
            color: Colors.black26,
          ),
          SafeArea(
            child: Container(
              height: 65,
              padding: EdgeInsets.only(top: 8, bottom: 10, right: 20, left: 20),
              width: double.infinity,
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(25)),
                child: TextFormField(
                  decoration: InputDecoration(
                      errorStyle: TextStyle(fontSize: 0),
                      contentPadding:
                          EdgeInsets.only(left: 15, top: 10, right: 5),
                      border: InputBorder.none,
                      hintText: widget.collectionName == 'places'
                          ? 'write a review'.tr()
                          : 'write a comment'.tr(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: Colors.grey[700],
                          size: 20,
                        ),
                        onPressed: () {
                          handleSubmit();
                        },
                      )),
                  controller: textCtrl,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget reviewList(Experience d) {
    return Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(5)),
        child: ListTile(
          leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey[200],
              backgroundImage: CachedNetworkImageProvider(d.imageUrl)),
          title: Row(
            children: <Widget>[
              Text(
                d.name,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
              ),
              SizedBox(
                width: 10,
              ),
              Text(d.date,
                  style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                      fontWeight: FontWeight.w500)),
            ],
          ),
          subtitle: Text(
            d.comment,
            style: TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500),
          ),
          onLongPress: () {
            handleDelete(context, d);
          },
        ));
  }
}
