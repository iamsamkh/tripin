import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:tripin/pages/blogs.dart';
import 'package:tripin/pages/categories.dart';
import 'package:tripin/pages/manage_events.dart';
import 'package:tripin/pages/manage_places.dart';
import 'package:tripin/pages/view_booking.dart';
import '../blocs/sign_in_bloc.dart';
import '../config/config.dart';
import '../pages/edit_profile.dart';
import '../pages/notifications.dart';
import '../pages/sign_in.dart';
import '../utils/next_screen.dart';
import '../widgets/language.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_localization/easy_localization.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with AutomaticKeepAliveClientMixin {
  openAboutDialog() {
    final sb = context.read<SignInBloc>();
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AboutDialog(
            applicationName: Config().appName,
            applicationIcon: Image(
              image: AssetImage(Config().splashIcon),
              height: 30,
              width: 30,
            ),
            applicationVersion: sb.appVersion,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final sb = context.watch<SignInBloc>();
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile').tr(),
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: Colors.black,
          ),
          centerTitle: false,
          actions: [
            IconButton(
                icon: const Icon(
                  FontAwesomeIcons.bell,
                  size: 20,
                ),
                onPressed: () => nextScreen(context, const NotificationsPage()))
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
          children: [
            sb.isSignedIn == false ? const GuestUserUI() : const UserUI(),
            const Text(
              "General Setting",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ).tr(),
            const SizedBox(
              height: 15,
            ),
            ListTile(
                title: const Text('View Categories').tr(),
                leading: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(5)),
                  child: const Icon(FontAwesomeIcons.borderAll,
                      size: 20, color: Colors.white),
                ),
                trailing: const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 20,
                ),
                onTap: () async {
                  nextScreen(context, const CategoriesPage());
                }),
            const Divider(
              height: 5,
            ),
            ListTile(
              title: const Text('Get Notifications').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: const Icon(
                  FontAwesomeIcons.bell,
                  size: 20,
                  color: Colors.white,
                ),
              ),
              trailing: Switch(
                  activeColor: Theme.of(context).primaryColor,
                  // value: context.watch<NotificationBloc>().subscribed,
                  value: false,
                  onChanged: (val) {
                    // context.read<NotificationBloc>().fcmSubscribe(bool);
                  }),
            ),
            const Divider(
              height: 5,
            ),
            ListTile(
                title: const Text('Contact Us').tr(),
                leading: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(5)),
                  child: const Icon(FontAwesomeIcons.envelope,
                      size: 20, color: Colors.white),
                ),
                trailing: const Icon(
                  FontAwesomeIcons.chevronRight,
                  size: 20,
                ),
                onTap: () async {
                  final url = Uri.parse(
                      'mailto:${Config().supportEmail}?subject=About ${Config().appName} App&body=');
                  await launchUrl(url);
                }),
            const Divider(
              height: 5,
            ),
            ListTile(
              title: const Text('Language').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.pinkAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: const Icon(FontAwesomeIcons.globe,
                    size: 20, color: Colors.white),
              ),
              trailing: const Icon(
                FontAwesomeIcons.chevronRight,
                size: 20,
              ),
              onTap: () => nextScreenPopup(context, const LanguagePopup()),
            ),
            const Divider(
              height: 5,
            ),
            ListTile(
              title: const Text('Rate this app').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: const Icon(FontAwesomeIcons.star,
                    size: 20, color: Colors.white),
              ),
              trailing: const Icon(
                FontAwesomeIcons.chevronRight,
                size: 20,
              ),
              // onTap: () async => LaunchReview.launch(
              //     androidAppId: sb.packageName, iOSAppId: Config().iOSAppId),
            ),
            const Divider(
              height: 5,
            ),
            ListTile(
              title: const Text('Licence').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: const Icon(FontAwesomeIcons.paperclip,
                    size: 20, color: Colors.white),
              ),
              trailing: const Icon(
                FontAwesomeIcons.chevronRight,
                size: 20,
              ),
              onTap: () => openAboutDialog(),
            ),
            const Divider(
              height: 5,
            ),
            ListTile(
              title: const Text('Privacy Policy').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(5)),
                child: const Icon(FontAwesomeIcons.lock,
                    size: 20, color: Colors.white),
              ),
              trailing: const Icon(
                FontAwesomeIcons.chevronRight,
                size: 20,
              ),
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(Config().privacyPolicyUrl))) {
                  launchUrl(Uri.parse(Config().privacyPolicyUrl));
                }
              },
            ),
            const Divider(
              height: 5,
            ),
            ListTile(
              title: const Text('About Us').tr(),
              leading: Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(5)),
                child: const Icon(FontAwesomeIcons.info,
                    size: 20, color: Colors.white),
              ),
              trailing: const Icon(
                FontAwesomeIcons.chevronRight,
                size: 20,
              ),
              onTap: () async {
                if (await canLaunchUrl(Uri.parse(Config().ourWebsiteUrl))) {
                  launchUrl(Uri.parse(Config().ourWebsiteUrl));
                }
              },
            ),
          ],
        ));
  }

  @override
  bool get wantKeepAlive => true;
}

class GuestUserUI extends StatelessWidget {
  const GuestUserUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Login').tr(),
          leading: Container(
            height: 30,
            width: 30,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5)),
            child: const Icon(FontAwesomeIcons.user,
                size: 20, color: Colors.white),
          ),
          trailing: const Icon(
            FontAwesomeIcons.chevronRight,
            size: 20,
          ),
          onTap: () => nextScreenPopup(
              context,
              const SignInPage(
                tag: 'popup',
              )),
        ),
        const SizedBox(
          height: 20,
        ),
      ],
    );
  }
}

class UserUI extends StatelessWidget {
  const UserUI({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sb = context.watch<SignInBloc>();
    return Column(
      // crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 200.h,
          child: Column(
            children: [
              CircleAvatar(
                  radius: 60.r,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: CachedNetworkImageProvider(sb.imageUrl!)),
              SizedBox(
                height: 10.h,
              ),
              Text(
                sb.name!,
                style: const TextStyle(fontSize: 18),
              )
            ],
          ),
        ),
        ListTile(
          title: Text(sb.email!),
          leading: Container(
            height: 30.h,
            width: 30.w,
            decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(5)),
            child: const Icon(FontAwesomeIcons.envelope,
                size: 20, color: Colors.white),
          ),
        ),
        const Divider(
          height: 5,
        ),
        ListTile(
          title: Text(sb.joiningDate!),
          leading: Container(
            height: 30.h,
            width: 30.w,
            decoration: BoxDecoration(
                color: Colors.orange, borderRadius: BorderRadius.circular(5)),
            child: const Icon(
                // FlutterIcons.dashboard_ant,
                FontAwesomeIcons.gauge,
                size: 20,
                color: Colors.white),
          ),
        ),
        const Divider(
          height: 5,
        ),
        ListTile(
            title: const Text('View Bookings'),
            leading: Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(5)),
              child: const Icon(FontAwesomeIcons.landmark,
                  size: 20, color: Colors.white),
            ),
            trailing: const Icon(
              FontAwesomeIcons.chevronRight,
              size: 20,
            ),
            onTap: () => nextScreen(context, const ViewBooking())),
        const Divider(
          height: 5,
        ),
        ListTile(
            title: const Text('Manage Places'),
            leading: Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(5)),
              child: const Icon(FontAwesomeIcons.landmark,
                  size: 20, color: Colors.white),
            ),
            trailing: const Icon(
              FontAwesomeIcons.chevronRight,
              size: 20,
            ),
            onTap: () => nextScreen(context, const ManagePlaces())),
        Divider(
          height: 5.h,
        ),
        ListTile(
            title: const Text('Edit Profile').tr(),
            leading: Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  borderRadius: BorderRadius.circular(5)),
              child: const Icon(FontAwesomeIcons.penToSquare,
                  size: 20, color: Colors.white),
            ),
            trailing: const Icon(
              FontAwesomeIcons.chevronRight,
              size: 20,
            ),
            onTap: () => nextScreen(
                context, EditProfile(name: sb.name!, imageUrl: sb.imageUrl!))),
        const Divider(
          height: 5,
        ),
        ListTile(
          title: const Text('Logout').tr(),
          leading: Container(
            height: 30.h,
            width: 30.w,
            decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(5)),
            child: const Icon(FontAwesomeIcons.arrowRightFromBracket,
                size: 20, color: Colors.white),
          ),
          trailing: const Icon(
            FontAwesomeIcons.chevronRight,
            size: 20,
          ),
          onTap: () => openLogoutDialog(context),
        ),
        const SizedBox(
          height: 15,
        ),
        Row(
          children: [
            const Text(
              "Manager Setting",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ).tr(),
            const Spacer(),
          ],
        ),
        const SizedBox(
          height: 15,
        ),
        ListTile(
            title: const Text('Manage Event'),
            leading: Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(5)),
              child: const Icon(FontAwesomeIcons.landmark,
                  size: 20, color: Colors.white),
            ),
            trailing: const Icon(
              FontAwesomeIcons.chevronRight,
              size: 20,
            ),
            onTap: () => nextScreen(context, const ManageEvents())),
        Divider(
          height: 5.h,
        ),
        ListTile(
            title: const Text('Manage Bookings'),
            leading: Container(
              height: 30.h,
              width: 30.w,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(5)),
              child: const Icon(FontAwesomeIcons.landmark,
                  size: 20, color: Colors.white),
            ),
            trailing: const Icon(
              FontAwesomeIcons.chevronRight,
              size: 20,
            ),
            onTap: () => nextScreen(context, const ManageEvents())),
        const SizedBox(
          height: 15,
        ),
      ],
    );
  }

  void openLogoutDialog(context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Logout Title').tr(),
            actions: [
              TextButton(
                child: const Text('No').tr(),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(
                child: const Text('Yes').tr(),
                onPressed: () async {
                  Navigator.pop(context);
                  await context.read<SignInBloc>().userSignout().then((value) =>
                      nextScreenCloseOthers(context, const SignInPage()));
                },
              )
            ],
          );
        });
  }
}
