import 'package:bechdal_app/components/large_heading_widget.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/forms/login_form.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';

import '../../l10n/locale_keys.g.dart';

class LoginScreen extends StatefulWidget {
  static const String screenId = 'login_screen';
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: '#f9fcf7'.toColor(),
      body: _body(),
    );
  }

  _body() {
    return SingleChildScrollView(
      child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LargeHeadingWidget(
            heading: LocaleKeys.welcome.tr(), subHeading: LocaleKeys.loginToContinue.tr()),
        const LogInForm(),
      ]),
    );
  }
}
