import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:tripin/blocs/view_events_bloc.dart';
import 'package:tripin/pages/book_event.dart';
import 'package:tripin/utils/toast.dart';
import '../blocs/sign_in_bloc.dart';
import '../models/event.dart';
import '../utils/empty.dart';
import '../utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/next_screen.dart';
import '../utils/sign_in_dialog.dart';
import 'event_details.dart';

class ViewEvents extends StatefulWidget {
  const ViewEvents({Key? key}) : super(key: key);

  @override
  _ViewEventsState createState() => _ViewEventsState();
}

class _ViewEventsState extends State<ViewEvents>
    with AutomaticKeepAliveClientMixin {
  ScrollController controller = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _filterBy = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((value) {
      controller.addListener(_scrollListener);
      context.read<ViewEventBloc>().getData(mounted, _filterBy);
    });
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    final db = context.read<ViewEventBloc>();

    if (!db.isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        context.read<ViewEventBloc>().setLoading(true);
        context.read<ViewEventBloc>().getData(mounted, _filterBy);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    ToastContext().init(context); //
    final bb = context.watch<ViewEventBloc>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text('View Events').tr(),
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: Colors.black,
        ),
        elevation: 0,
        actions: <Widget>[
          PopupMenuButton(
              child: const Icon(Icons.filter_list_outlined),
              itemBuilder: (BuildContext context) {
                return <PopupMenuItem>[
                  if(_filterBy != '')
                  const PopupMenuItem(
                    child: Text('Remove Filter'),
                    value: '',
                  ),
                  const PopupMenuItem(
                    child: Text('Active'),
                    value: 'active',
                  ),
                  const PopupMenuItem(
                    child: Text('Completed'),
                    value: 'completed',
                  ),
                  const PopupMenuItem(
                    child: Text('Booking Closed'),
                    value: 'booked',
                  ),
                  const PopupMenuItem(
                    child: Text('Cancelled'),
                    value: 'cancelled',
                  ),
                ];
              },
              onSelected: (value) {
                setState(() {
                  _filterBy = value.toString();
                });
                bb.afterPopSelection(value, mounted, _filterBy);
              }),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.rotate,
              size: 22,
            ),
            onPressed: () {
              context.read<ViewEventBloc>().onRefresh(mounted, _filterBy);
            },
          )
        ],
      ),
      body: RefreshIndicator(
        child: bb.hasData == false
            ? ListView(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.35,
                  ),
                  const EmptyPage(
                      icon: FontAwesomeIcons.landmark,
                      message: 'No Event Found',
                      message1: ''),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.all(15),
                controller: controller,
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: bb.data.isNotEmpty ? bb.data.length + 1 : 5,
                separatorBuilder: (BuildContext context, int index) => SizedBox(
                  height: 15.h,
                ),

                //shrinkWrap: true,
                itemBuilder: (_, int index) {
                  if (index < bb.data.length) {
                    return _ListItem(eventData: bb.data[index]);
                  }
                  return Opacity(
                    opacity: bb.isLoading ? 1.0 : 0.0,
                    child: bb.lastVisible == null
                        ? LoadingCard(height: 250.h)
                        : Center(
                            child: SizedBox(
                                width: 32.w,
                                height: 32.h,
                                child: const CupertinoActivityIndicator()),
                          ),
                  );
                },
              ),
        onRefresh: () async {
          context.read<ViewEventBloc>().onRefresh(mounted, _filterBy);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ListItem extends StatelessWidget {
  final Event eventData;
  const _ListItem({Key? key, required this.eventData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context); //
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 10),
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
                        offset: const Offset(0, 3))
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              'Apply Before: ',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                            const Spacer(),
                            Text(
                              DateFormat('d MMMM yyyy ')
                                  .format(eventData.bookingDeadline.toDate()),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.red[400]),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                                onPressed: () {
                                  nextScreen(
                                      context, EventDetails(data: eventData));
                                },
                                child: const Text('View Event')),
                            TextButton(
                                onPressed: () {
                                  bool _guestUser =
                                      context.read<SignInBloc>().guestUser;
                                  if (_guestUser == true) {
                                    openSignInDialog(context);
                                  } else {
                                    if(eventData.status == 'active'){
                                      nextScreenPopup(
                                        context, BookEvent(e: eventData));
                                    } else{
                                      openToast(context, 'Sorry! This event is not active');
                                    }
                                    
                                  }
                                },
                                child: const Text('Book Event')),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5)),
                    ),
                    child: Row(
                      children: [
                        const Spacer(),
                        Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child:
                                Text('Created By: ${eventData.createrName}')),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
