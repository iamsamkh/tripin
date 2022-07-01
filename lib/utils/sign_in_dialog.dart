import 'package:flutter/material.dart';
import '../pages/sign_in.dart';
import '../utils/next_screen.dart';
import 'package:easy_localization/easy_localization.dart';

openSignInDialog(context) {
  return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Not Signed In').tr(),
          content: const Text('Please login to your account to continue').tr(),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  nextScreenPopup(
                      context,
                      const SignInPage(
                        tag: 'popup',
                      ));
                },
                child: const Text('sign in').tr()),
            TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('cancel').tr())
          ],
        );
      });
}
