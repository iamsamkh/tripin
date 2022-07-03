import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:tripin/blocs/manage_bookings_bloc.dart';
import '../blocs/blocs.dart';
import '../pages/splash.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await EasyLocalization.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(EasyLocalization(
    supportedLocales: const [
      Locale('en'),
    ],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    useOnlyLangCode: true,
    child: const MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) {
        return MultiProvider(
        providers: [
          ChangeNotifierProvider<BlogBloc>(
            create: (context) => BlogBloc(),
          ),
          ChangeNotifierProvider<InternetBloc>(
            create: (context) => InternetBloc(),
          ),
          ChangeNotifierProvider<SignInBloc>(
            create: (context) => SignInBloc(),
          ),
          ChangeNotifierProvider<CommentsBloc>(
            create: (context) => CommentsBloc(),
          ),
          ChangeNotifierProvider<BookmarkBloc>(
            create: (context) => BookmarkBloc(),
          ),
          ChangeNotifierProvider<PopularPlacesBloc>(
            create: (context) => PopularPlacesBloc(),
          ),
          ChangeNotifierProvider<RecentPlacesBloc>(
            create: (context) => RecentPlacesBloc(),
          ),
          ChangeNotifierProvider<RecommandedPlacesBloc>(
            create: (context) => RecommandedPlacesBloc(),
          ),
          ChangeNotifierProvider<FeaturedBloc>(
            create: (context) => FeaturedBloc(),
          ),
          ChangeNotifierProvider<SearchBloc>(
            create: (context) => SearchBloc(),
          ),
          ChangeNotifierProvider<NotificationBloc>(
            create: (context) => NotificationBloc(),
          ),
          ChangeNotifierProvider<CategoriesBloc>(
            create: (context) => CategoriesBloc(),
          ),
          ChangeNotifierProvider<OtherPlacesBloc>(
            create: (context) => OtherPlacesBloc(),
          ),
          ChangeNotifierProvider<AdsBloc>(
            create: (context) => AdsBloc(),
          ),
          ChangeNotifierProvider<ManagePlacesBloc>(
            create: (context) => ManagePlacesBloc(),
          ),
          ChangeNotifierProvider<ViewEventBloc>(
            create: (context) => ViewEventBloc(),
          ),
          ChangeNotifierProvider<ManageEventBloc>(
            create: (context) => ManageEventBloc(),
          ),
          ChangeNotifierProvider<ViewBookingBloc>(
            create: (context) => ViewBookingBloc(),
          ),
          ChangeNotifierProvider<ManageBookingsBloc>(
            create: (context) => ManageBookingsBloc(),
          ),
        ],
        child: MaterialApp(
            supportedLocales: context.supportedLocales,
            localizationsDelegates: context.localizationDelegates,
            locale: context.locale,
            theme: ThemeData(
                primarySwatch: Colors.green,
                primaryColor: Colors.greenAccent,
                iconTheme: IconThemeData(color: Colors.grey[900]),
                fontFamily: 'Muli',
                scaffoldBackgroundColor: Colors.grey[100],
                appBarTheme: AppBarTheme(
                  color: Colors.white,
                  elevation: 0,
                  iconTheme: IconThemeData(
                    color: Colors.grey[800],
                  ),
                  brightness:
                      Platform.isAndroid ? Brightness.dark : Brightness.light,
                  textTheme: TextTheme(
                      headline6: GoogleFonts.montserrat(
                          fontSize: 18,
                          color: Colors.grey[900],
                          fontWeight: FontWeight.w500)),
                )),
            debugShowCheckedModeBanner: false,
            home: const SplashPage()),
      );
      },
      
    );
  }
}
