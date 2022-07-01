import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tripin/blocs/manage_event_bloc.dart';
import 'package:tripin/pages/add_event.dart';
import '../models/Place.dart';
import '../models/event.dart';
import '../utils/empty.dart';
import '../utils/loading_cards.dart';
import 'package:easy_localization/easy_localization.dart';

import '../utils/next_screen.dart';

class ManageEvents extends StatefulWidget {
  const ManageEvents({Key? key}) : super(key: key);

  @override
  _ManageEventsState createState() => _ManageEventsState();
}

class _ManageEventsState extends State<ManageEvents>
    with AutomaticKeepAliveClientMixin {
  ScrollController controller = ScrollController();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _filterBy = '';

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 0)).then((value) {
      controller.addListener(_scrollListener);
      context.read<ManageEventBloc>().getData(mounted, _filterBy);
    });
  }

  @override
  void dispose() {
    controller.removeListener(_scrollListener);
    super.dispose();
  }

  void _scrollListener() {
    final db = context.read<ManageEventBloc>();

    if (!db.isLoading) {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        context.read<ManageEventBloc>().setLoading(true);
        context.read<ManageEventBloc>().getData(mounted, _filterBy);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bb = context.watch<ManageEventBloc>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        automaticallyImplyLeading: false,
        title: const Text('Create/Manage Events').tr(),
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
                  // if (value == 'pendingApproval') {
                  //   _filterBy = 'pendingApproval';
                  // } else if (value == 'pendingApproval') {
                  //   _filterBy = 'pendingApproval';
                  // } else if (value == 'approved') {
                  //   _filterBy = 'approved';
                  // } else if (value == 'rejected') {
                  //   _filterBy = 'rejected';
                  // } else {
                  //   _filterBy = '';
                  // }
                });
                bb.afterPopSelection(value, mounted, _filterBy);
              }),
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.rotate,
              size: 22,
            ),
            onPressed: () {
              context.read<ManageEventBloc>().onRefresh(mounted, _filterBy);
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          bottomDialogScreen(context, const AddNewEvent());
        },
        tooltip: 'Create Event',
        child: const FaIcon(
          FontAwesomeIcons.plus,
          size: 22,
        ),
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
                    return _ListItem(d: bb.data[index]);
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
          context.read<ManageEventBloc>().onRefresh(mounted, _filterBy);
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class _ListItem extends StatelessWidget {
  final Event d;
  const _ListItem({Key? key, required this.d}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Container(
        margin: const EdgeInsets.only(top: 5, bottom: 10),
        child: Slidable(
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children:  [
              SlidableAction(
                onPressed: (value){},
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                icon: Icons.done,
                label: 'Booked',
              ),
              SlidableAction(
                onPressed: (value){},
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                icon: Icons.delete,
                label: 'Cancel',
              ),
            ],
          ),
          child: Container(
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
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              d.eventTitle,
                              maxLines: 1,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.all(3.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6.0),
                                color: d.status == 'pendingApproval'
                                    ? Colors.orangeAccent
                                    : d.status == 'active'
                                        ? Colors.green[500]
                                        : Colors.red[400],
                              ),
                              child: Text(
                                d.status == 'pendingApproval'
                                    ? 'Pending Approval'
                                    : d.status == 'active'
                                        ? 'Active'
                                        : 'Rejected',
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
                              d.departCity,
                              maxLines: 1,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            Icon(
                              d.travelMode == 'Aeroplane'
                                  ? FontAwesomeIcons.plane
                                  : d.travelMode == 'Bus'
                                      ? FontAwesomeIcons.bus
                                      : d.travelMode == 'Car'
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
                                d.destCity,
                                maxLines: 1,
                                style: TextStyle(
                                    fontSize: 13, color: Colors.grey[700]),
                              ),
                            ),
                            Text(
                              DateFormat('d MMMM yyyy ')
                                  .format(d.departDate.toDate()),
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
                              'Seats Booked: ${d.seatsBooked}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                            const Spacer(),
                            Text(
                              'Total Capacity: ${d.capacity}',
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
                              'Duration: ${d.duration}',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[700]),
                            ),
                            const Spacer(),
                            Text(
                              '${d.price} Pkr',
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
                                  .format(d.bookingDeadline.toDate()),
                              style: TextStyle(
                                  fontSize: 13, color: Colors.red[400]),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text('Event Created By: ${d.createrName}')
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ),

      // onTap: ()=> nextScreen(context, PlaceDetails(data: d, tag: tag)),
    );
  }
}
