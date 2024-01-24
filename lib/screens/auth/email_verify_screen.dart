// import 'package:bechdal_app/components/custom_icon_button.dart';
// import 'package:bechdal_app/constants/colors.dart';
// import 'package:bechdal_app/constants/widgets.dart';
// import 'package:bechdal_app/screens/location_screen.dart';
// import 'package:bechdal_app/services/auth.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// import 'package:open_mail_app/open_mail_app.dart';
//
// import '../../l10n/locale_keys.g.dart';
//
// class EmailVerifyScreen extends StatefulWidget {
//   static const String screenId = 'email_otp_screen';
//   const EmailVerifyScreen({Key? key}) : super(key: key);
//
//   @override
//   State<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
// }
//
// class _EmailVerifyScreenState extends State<EmailVerifyScreen> {
//   bool isPinEntered = false;
//   String smsCode = "";
//
//   Auth authService = Auth();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: null,
//       body: _body(context),
//     );
//   }
//
//   Future<void> validateEmailOtp() async {
//     if (kDebugMode) {
//       print('sms code is : $smsCode');
//     }
//   }
//
//   Widget _body(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         SizedBox(
//           width: double.infinity,
//           height: 250,
//           child: Padding(
//             padding: const EdgeInsets.only(top: 100, left: 25),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   LocaleKeys.verifyEmail.tr(),
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 35,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 Text(
//                   LocaleKeys.checkYourEmailForVerification.tr(),
//                   style: TextStyle(
//                     color: blackColor,
//                     fontSize: 18,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         Expanded(
//           child: Column(children: [
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
//               child: Lottie.asset(
//                 'assets/lottie/verify_lottie.json',
//                 width: double.infinity,
//                 height: 350,
//               ),
//             ),
//             InkWell(
//               onTap: () async {
//                 var result = await OpenMailApp.openMailApp();
//                 if (!result.didOpen && !result.canOpen) {
//                   customSnackBar(
//                       context: context, content: LocaleKeys.noMailAppsInstalled.tr());
//                 } else if (!result.didOpen && result.canOpen) {
//                   showDialog(
//                     context: context,
//                     builder: (_) {
//                       return MailAppPickerDialog(
//                         mailApps: result.options,
//                       );
//                     },
//                   );
//                   Navigator.pushReplacementNamed(
//                       context, LocationScreen.screenId);
//                 }
//               },
//               child: CustomIconButton(
//                   text: LocaleKeys.verifyEmail.tr(),
//                   bgColor: secondaryColor,
//                   icon: Icons.verified_user,
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 15, horizontal: 15)),
//             )
//           ]),
//         ),
//       ],
//     );
//   }
// }
