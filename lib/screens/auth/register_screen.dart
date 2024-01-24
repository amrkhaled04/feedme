import 'package:bechdal_app/components/large_heading_widget.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/forms/register_form.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_keys.g.dart';

class RegisterScreen extends StatefulWidget {
  static const screenId = 'register_screen';
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: _body(),
    );
  }
}

_body() {
  return SingleChildScrollView(
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
        padding: const EdgeInsets.only(right: 10),
        child: LargeHeadingWidget(
          heading: LocaleKeys.createAccount.tr(),
          subHeading: LocaleKeys.signUpMessage.tr(),
          anotherTaglineText: '\n${LocaleKeys.alreadyHaveAccount.tr()}',
          anotherTaglineColor: secondaryColor,
          subheadingTextSize: 16,
          taglineNavigation: true,
        ),
      ),
      const RegisterForm(),
    ]),
  );
}
