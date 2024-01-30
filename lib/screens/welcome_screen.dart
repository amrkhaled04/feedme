import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/l10n/locale_keys.g.dart';
import 'package:bechdal_app/screens/auth/login_screen.dart';
import 'package:bechdal_app/screens/auth/register_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user.dart';

class WelcomeScreen extends StatelessWidget {
  static const screenId = 'welcome_screen';
  WelcomeScreen({Key? key}) : super(key: key);
  UserService firebaseUser = UserService();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: null,
      backgroundColor: '#f9fcf7'.toColor(),
      body: welcomeBodyWidget(context),
    );
  }

  Widget welcomeBodyWidget(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          height: 200,
          child: Padding(
            padding: const EdgeInsets.only(top: 80, left: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.appName.tr(),
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  LocaleKeys.splashScreenSlogan.tr(),
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 25,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
              child: Lottie.asset(
                'assets/lottie/welcome_lottie.json',
                width: double.infinity,
                height: 350,
              ),
            )
          ]),
        ),
        _bottomNavigationBar(context),
      ],
    );
  }

  Widget _bottomNavigationBar(context) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
              context: context,
              bgColor: whiteColor,
              borderColor: blackColor,
              textColor: blackColor,
              text: LocaleKeys.login.tr(),
              onPressed: () {
                Navigator.pushNamed(context, LoginScreen.screenId);
              }),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: roundedButton(
              context: context,
              bgColor: '#80cf70'.toColor(),
              borderColor: '#80cf70'.toColor(),
              text: LocaleKeys.signUp.tr(),
              textColor: whiteColor,
              onPressed: () {
                Navigator.pushNamed(context, RegisterScreen.screenId);
              }),
        ),
        const SizedBox(
          height: 10,
        ),
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 15),
        //   child: roundedButton(
        //       context: context,
        //       bgColor: whiteColor,
        //       borderColor: blackColor,
        //       textColor: blackColor,
        //       text: LocaleKeys.continueAsGuest.tr(),
        //       onPressed: () async {
        //         final SharedPreferences prefs = await _prefs;
        //         await prefs.setBool('guest', true);
        //         UserService.guestUser = true;
        //         Navigator.pushNamed(context, MainNavigationScreen.screenId);
        //
        //
        //
        //       }),
        // ),
        const SizedBox(
          height: 25,
        ),

      ],
    );
  }
}
