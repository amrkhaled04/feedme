import 'package:bechdal_app/components/large_heading_widget.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/forms/reset_form.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_keys.g.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String screenId = 'reset_password_screen';
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LargeHeadingWidget(
                heading: LocaleKeys.forgotPassword.tr(),
                subHeading: LocaleKeys.emailHint.tr(),
                headingTextSize: 35,
                subheadingTextSize: 20,
              ),
              const ResetForm(),
            ]),
      ),
    );
  }
}
