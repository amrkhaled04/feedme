// import 'package:bechdal_app/components/custom_icon_button.dart';
// import 'package:bechdal_app/constants/colors.dart';
// import 'package:bechdal_app/l10n/locale_keys.g.dart';
// import 'package:bechdal_app/screens/auth/phone_auth_screen.dart';
// import 'package:bechdal_app/services/auth.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
//
// class SignUpButtons extends StatefulWidget {
//   const SignUpButtons({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   State<SignUpButtons> createState() => _SignUpButtonsState();
// }
//
// class _SignUpButtonsState extends State<SignUpButtons> {
//   Auth authService = Auth();
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: () {
//             Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                     builder: (builder) => const PhoneAuthScreen(
//                           isFromLogin: false,
//                         )));
//           },
//           child: CustomIconButton(
//             text: LocaleKeys.phoneSignUp.tr(),
//             imageIcon: 'assets/phone.png',
//             bgColor: greyColor,
//             imageOrIconColor: whiteColor,
//             imageOrIconRadius: 20,
//           ),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//         InkWell(
//           onTap: () async {
//             User? user = await Auth.signInWithGoogle(context: context);
//             if (user != null) {
//               authService.getAdminCredentialPhoneNumber(context, user);
//             }
//           },
//           child: CustomIconButton(
//             text: LocaleKeys.googleSignUp.tr(),
//             imageIcon: 'assets/google.png',
//             bgColor: whiteColor,
//           ),
//         ),
//         const SizedBox(
//           height: 10,
//         ),
//       ],
//     );
//   }
// }
