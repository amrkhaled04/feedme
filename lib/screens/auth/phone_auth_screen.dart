// import 'package:bechdal_app/components/bottom_nav_widget.dart';
// import 'package:bechdal_app/constants/colors.dart';
// import 'package:bechdal_app/screens/auth/phone_otp_screen.dart';
// import 'package:bechdal_app/services/auth.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';
// import 'package:sms_advanced/sms_advanced.dart';
//
// import '../../l10n/locale_keys.g.dart';
//
// class PhoneAuthScreen extends StatefulWidget {
//   static const String screenId = 'phone_auth_screen';
//   final bool isFromLogin;
//   const PhoneAuthScreen({
//     Key? key,
//     this.isFromLogin = true,
//   }) : super(key: key);
//
//   @override
//   State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
// }
//
// class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
//   Auth authService = Auth();
//   late final TextEditingController _countryCodeController;
//   late final TextEditingController _phoneNumberController;
//   late final FocusNode _countryCodeNode;
//   late final FocusNode _phoneNumberNode;
//   String counterText = '0';
//   bool validate = false;
//   bool isLoading = true;
//   String verificationIdFinal = "";
//   @override
//   void initState() {
//     _countryCodeController = TextEditingController(text: '+20');
//     _phoneNumberController = TextEditingController();
//     _countryCodeNode = FocusNode();
//     _phoneNumberNode = FocusNode();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _countryCodeController.dispose();
//     _phoneNumberController.dispose();
//     _countryCodeNode.dispose();
//     _phoneNumberNode.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     ProgressDialog progressDialog = ProgressDialog(
//       context: context,
//       backgroundColor: whiteColor,
//       textColor: blackColor,
//       loadingText: LocaleKeys.verifyingDetails.tr(),
//       progressIndicatorColor: blackColor,
//     );
//     return Scaffold(
//       appBar: AppBar(
//           elevation: 0.5,
//           backgroundColor: whiteColor,
//           iconTheme: IconThemeData(color: blackColor),
//           title: Text(
//             widget.isFromLogin ? LocaleKeys.login.tr() : LocaleKeys.signUp.tr(),
//             style: TextStyle(color: blackColor),
//           )),
//       body: SingleChildScrollView(child: _body(context)),
//       bottomNavigationBar: BottomNavigationWidget(
//         validator: validate,
//         buttonText: LocaleKeys.next.tr(),
//         progressDialog: progressDialog,
//         onPressed: signInValidate,
//         //     (){
//         //
//         //   String address = '${_countryCodeController.text}${_phoneNumberController.text}';
//         //
//         //
//         //   Navigator.push(context,MaterialPageRoute(
//         //       builder: (builder) => PhoneOTPScreen(
//         //         phoneNumber: address,
//         //         verificationIdFinal: verificationIdFinal,
//         //       )));
//         //
//         //
//         // },
//       ),
//     );
//   }
//
//   void signInValidate() {
//     String number =
//         '${_countryCodeController.text}${_phoneNumberController.text}';
//
//     if (kDebugMode) {
//       print(number);
//     }
//     authService.verifyPhoneNumber(context, number);
//   }
//
//   Widget _body(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           const SizedBox(
//             height: 40,
//           ),
//           CircleAvatar(
//             backgroundColor: primaryColor,
//             radius: 40,
//             child: CircleAvatar(
//               backgroundColor: secondaryColor,
//               radius: 37,
//               child: Icon(
//                 CupertinoIcons.person,
//                 color: whiteColor,
//                 size: 40,
//               ),
//             ),
//           ),
//           const SizedBox(
//             height: 12,
//           ),
//           Text(
//             LocaleKeys.phoneNumberHint.tr(),
//             style: TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           Text(
//             LocaleKeys.phoneVerificationCode.tr(),
//             style: TextStyle(
//               color: greyColor,
//             ),
//           ),
//           const SizedBox(
//             height: 25,
//           ),
//           Row(
//             children: [
//               Expanded(
//                   flex: 1,
//                   child: TextFormField(
//                     focusNode: _countryCodeNode,
//                     textAlign: TextAlign.center,
//                     controller: _countryCodeController,
//                     decoration: InputDecoration(
//                         labelText: LocaleKeys.country.tr(),
//                         enabled: false,
//                         contentPadding: const EdgeInsets.all(20),
//                         border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8))),
//                   )),
//               const SizedBox(
//                 width: 10,
//               ),
//               Expanded(
//                   flex: 3,
//                   child: Container(
//                     margin: const EdgeInsets.only(top: 20),
//                     child: TextFormField(
//                       focusNode: _phoneNumberNode,
//                       maxLength: 10,
//                       onChanged: (value) {
//                         setState(() {
//                           counterText = value.length.toString();
//                         });
//                         if (value.length == 10) {
//                           setState(() {
//                             validate = true;
//                           });
//                         }
//                         if (value.length < 10) {
//                           setState(() {
//                             validate = false;
//                           });
//                         }
//                       },
//                       controller: _phoneNumberController,
//                       keyboardType: TextInputType.phone,
//                       decoration: InputDecoration(
//                           counterText: '$counterText/10',
//                           counterStyle: const TextStyle(fontSize: 10),
//                           labelText: LocaleKeys.phoneNumber.tr(),
//                           hintText: LocaleKeys.phoneNumberHint.tr(),
//                           hintStyle: TextStyle(
//                             color: greyColor,
//                             fontSize: 12,
//                           ),
//                           contentPadding: const EdgeInsets.all(20),
//                           border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8))),
//                     ),
//                   )),
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
