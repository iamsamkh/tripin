import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../blocs/internet_bloc.dart';
import '../blocs/sign_in_bloc.dart';
import '../config/config.dart';
import '../pages/done.dart';
import '../utils/next_screen.dart';
import '../utils/snacbar.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/language.dart';
import 'home.dart';

class SignInPage extends StatefulWidget {
  final String? tag;
  const SignInPage({Key? key, this.tag}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool googleSignInStarted = false;
  bool facebookSignInStarted = false;
  bool appleSignInStarted = false;
  bool newUser = false;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  handleSkip() {
    final sb = context.read<SignInBloc>();
    sb.setGuestUser();
    nextScreen(context, const DonePage());
  }

  handleGoogleSignIn() async {
    final sb = context.read<SignInBloc>();
    final ib = context.read<InternetBloc>();
    setState(() => googleSignInStarted = true);
    await ib.checkInternet();
    if (ib.hasInternet == false) {
      openSnacbar(scaffoldKey, 'check your internet connection!'.tr());
    } else {
      await sb.signInWithGoogle().then((_) {
        if (sb.hasError == true) {
          openSnacbar(
              scaffoldKey, 'something is wrong. please try again.'.tr());
          setState(() => googleSignInStarted = false);
        } else {
          sb.checkUserExists().then((value) {
            if (value == true) {
              sb.getUserDatafromFirebase(sb.uid).then((value) => sb
                  .saveDataToSP()
                  .then((value) => sb.guestSignout())
                  .then((value) => sb.setSignIn().then((value) {
                        setState(() => googleSignInStarted = false);
                        afterSignIn();
                      })));
            } else {
              sb.getJoiningDate().then((value) => sb
                  .saveToFirebase()
                  .then((value) => sb.increaseUserCount())
                  .then((value) => sb.saveDataToSP().then((value) => sb
                      .guestSignout()
                      .then((value) => sb.setSignIn().then((value) {
                            setState(() => googleSignInStarted = false);
                            newUser = true;
                            afterSignIn();
                          })))));
            }
          });
        }
      });
    }
  }

  // handleFacebookSignIn() async{
  //   final sb = context.read<SignInBloc>();
  //   final ib = context.read<InternetBloc>();
  //   setState(() =>facebookSignInStarted = true);
  //   await ib.checkInternet();
  //   if(ib.hasInternet == false){
  //     openSnacbar(scaffoldKey, 'check your internet connection!'.tr());

  //   }else{
  //     await sb.signInwithFacebook().then((_){
  //       if(sb.hasError == true){
  //         openSnacbar(scaffoldKey, 'something is wrong. please try again.'.tr());
  //         setState(() =>facebookSignInStarted = false);

  //       }else {
  //         sb.checkUserExists().then((value){
  //         if(value == true){
  //           sb.getUserDatafromFirebase(sb.uid)
  //           .then((value) => sb.saveDataToSP()
  //           .then((value) => sb.guestSignout())
  //           .then((value) => sb.setSignIn()
  //           .then((value){
  //             setState(() =>facebookSignInStarted = false);
  //             afterSignIn();
  //           })));
  //         } else{
  //           sb.getJoiningDate()
  //           .then((value) => sb.saveToFirebase()
  //           .then((value) => sb.increaseUserCount())
  //           .then((value) => sb.saveDataToSP()
  //           .then((value) => sb.guestSignout()
  //           .then((value) => sb.setSignIn()
  //           .then((value){
  //             setState(() =>facebookSignInStarted = false);
  //             afterSignIn();
  //           })))));
  //         }
  //           });

  //       }
  //     });
  //   }
  // }

  // handleAppleSignIn() async{
  //   final sb = context.read<SignInBloc>();
  //   final ib = context.read<InternetBloc>();
  //   setState(() =>appleSignInStarted = true);
  //   await ib.checkInternet();
  //   if(ib.hasInternet == false){
  //     openSnacbar(scaffoldKey, 'check your internet connection!'.tr());

  //   }else{
  //     await sb.signInWithApple().then((_){
  //       if(sb.hasError == true){
  //         openSnacbar(scaffoldKey, 'something is wrong. please try again.'.tr());
  //         setState(() =>appleSignInStarted = false);

  //       }else {
  //         sb.checkUserExists().then((value){
  //         if(value == true){
  //           sb.getUserDatafromFirebase(sb.uid)
  //           .then((value) => sb.saveDataToSP()
  //           .then((value) => sb.guestSignout())
  //           .then((value) => sb.setSignIn()
  //           .then((value){
  //             setState(() =>appleSignInStarted = false);
  //             afterSignIn();
  //           })));
  //         } else{
  //           sb.getJoiningDate()
  //           .then((value) => sb.saveToFirebase()
  //           .then((value) => sb.increaseUserCount())
  //           .then((value) => sb.saveDataToSP()
  //           .then((value) => sb.guestSignout()
  //           .then((value) => sb.setSignIn()
  //           .then((value){
  //             setState(() =>appleSignInStarted = false);
  //             afterSignIn();
  //           })))));
  //         }
  //           });

  //       }
  //     });
  //   }
  // }

  afterSignIn() {
    if (widget.tag == null) {
      if(newUser){
        nextScreen(context, const DonePage());
      }
      nextScreenReplace(context, const HomePage());
      
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      key: scaffoldKey,
      appBar: AppBar(
        actions: [
          widget.tag != null
              ? Container()
              : TextButton(
                  onPressed: () => handleSkip(),
                  child: const Text('skip',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )).tr()),
          IconButton(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(0),
            iconSize: 22,
            icon: const Icon(
              Icons.language,
            ),
            onPressed: () {
              nextScreenPopup(context, const LanguagePopup());
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Flexible(
              flex: 1,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'welcome to',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700]),
                  ).tr(),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    '${Config().appName}',
                    style: TextStyle(
                        fontSize: 35,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey[700]),
                  ),
                ],
              )),
          Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 40, right: 40),
                    child: Text(
                      'welcome message',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[700]),
                    ).tr(),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 3,
                    width: MediaQuery.of(context).size.width * 0.50,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(40)),
                  ),
                ],
              )),
          Flexible(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 45,
                    width: MediaQuery.of(context).size.width * 0.80,
                    child: googleSignInStarted == false
                            ? FlatButton(
                        onPressed: () => handleGoogleSignIn(),
                        color: Colors.blueAccent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(
                                    FontAwesomeIcons.google,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Sign In with Google',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white),
                                  )
                                ],
                              )
                            ) : const Center(
                                child: CircularProgressIndicator(
                                    backgroundColor: Colors.white),
                              ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  // SizedBox(
                  //   height: 45,
                  //   width: MediaQuery.of(context).size.width * 0.80,
                  //   child: FlatButton(
                  //       onPressed: () {
                  //         // handleFacebookSignIn();
                  //       },
                  //       color: Colors.indigo,
                  //       shape: RoundedRectangleBorder(
                  //           borderRadius: BorderRadius.circular(5)),
                  //       child: facebookSignInStarted == false
                  //           ? Row(
                  //               crossAxisAlignment: CrossAxisAlignment.center,
                  //               mainAxisAlignment: MainAxisAlignment.center,
                  //               children: const [
                  //                 Icon(
                  //                   FontAwesomeIcons.facebook,
                  //                   color: Colors.white,
                  //                 ),
                  //                 SizedBox(
                  //                   width: 10,
                  //                 ),
                  //                 Text(
                  //                   'Sign In with Facebook',
                  //                   style: TextStyle(
                  //                       fontSize: 16,
                  //                       fontWeight: FontWeight.w600,
                  //                       color: Colors.white),
                  //                 )
                  //               ],
                  //             )
                  //           : const Center(
                  //               child: CircularProgressIndicator(
                  //                   backgroundColor: Colors.white),
                  //             )),
                  // ),
                  // const SizedBox(
                  //   height: 15,
                  // ),
                  // Platform.isAndroid
                  //     ? Container()
                  //     : SizedBox(
                  //         height: 45,
                  //         width: MediaQuery.of(context).size.width * 0.80,
                  //         child: FlatButton(
                  //             onPressed: () {
                  //               // handleAppleSignIn();
                  //             },
                  //             color: Colors.grey[900],
                  //             shape: RoundedRectangleBorder(
                  //                 borderRadius: BorderRadius.circular(5)),
                  //             child: appleSignInStarted == false
                  //                 ? Row(
                  //                     crossAxisAlignment:
                  //                         CrossAxisAlignment.center,
                  //                     mainAxisAlignment:
                  //                         MainAxisAlignment.center,
                  //                     children: const [
                  //                       Icon(
                  //                         FontAwesomeIcons.apple,
                  //                         color: Colors.white,
                  //                       ),
                  //                       SizedBox(
                  //                         width: 10,
                  //                       ),
                  //                       Text(
                  //                         'Sign In with Apple',
                  //                         style: TextStyle(
                  //                             fontSize: 16,
                  //                             fontWeight: FontWeight.w600,
                  //                             color: Colors.white),
                  //                       )
                  //                     ],
                  //                   )
                  //                 : const Center(
                  //                     child: CircularProgressIndicator(
                  //                         backgroundColor: Colors.white),
                  //                   )),
                  //       ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05)
                ],
              )),
        ],
      ),
    );
  }
}
