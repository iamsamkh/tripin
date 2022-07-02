import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tripin/pages/add_place.dart';
import 'package:tripin/pages/view_events.dart';
import 'package:tripin/utils/next_screen.dart';
import '../blocs/ads_bloc.dart';
import '../blocs/notification_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../pages/blogs.dart';
import '../pages/bookmark.dart';
import '../pages/explore.dart';
import '../pages/profile.dart';
import '../utils/sign_in_dialog.dart';
import 'categories.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  List<IconData> iconList = [
    FontAwesomeIcons.house,
    // FontAwesomeIcons.borderAll,
    FontAwesomeIcons.calendar,
    // FontAwesomeIcons.list,
    FontAwesomeIcons.bookmark,
    FontAwesomeIcons.user
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(index,
        curve: Curves.easeIn, duration: const Duration(milliseconds: 400));
  }

  @override
  void initState() {
    super.initState();
    // Future.delayed(Duration(milliseconds: 0))
    // .then((value) async{
    //   //await context.read<AdsBloc>().initAdmob();
    //   //await context.read<AdsBloc>().initFbAd();
    //   await context.read<NotificationBloc>().initFirebasePushNotification(context);

    //   //await context.read<AdsBloc>().checkAdsEnable();
    //   //context.read<AdsBloc>().enableAds();
    // });
  }

  @override
  void dispose() {
    _pageController.dispose();
    // context.read<AdsBloc>().dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async => false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          // backgroundColor: Colors.grey,
          child: const Icon(
            FontAwesomeIcons.plus,
          ),
          onPressed: () {
            bool _guestUser = context.read<SignInBloc>().guestUser;
            if (_guestUser == true) {
              openSignInDialog(context);
            } else {
              bottomDialogScreen(context, const AddNewPlace());
            }
          },
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: AnimatedBottomNavigationBar(
          gapWidth: 10.w,
          icons: iconList,
          activeIndex: _currentIndex,
          gapLocation: GapLocation.center,
          inactiveColor: Colors.grey[600],
          onTap: (index) => onTabTapped(index),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: const <Widget>[
            Explore(),
            // CategoriesPage(),
            ViewEvents(),
            // BlogPage(),
            BookmarkPage(),
            ProfilePage(enableBack: false,),
          ],
        ),
      ),
    );
  }
}
