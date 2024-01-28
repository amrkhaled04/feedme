// import 'dart:math';
//
// import 'package:bechdal_app/components/bottom_nav_widget.dart';
// import 'package:bechdal_app/constants/colors.dart';
// import 'package:bechdal_app/services/auth.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:otp_text_field/otp_text_field.dart';
// import 'package:otp_text_field/style.dart';
// import 'package:sms_advanced/sms_advanced.dart';
//
// import '../../l10n/locale_keys.g.dart';
// import '../location_screen.dart';
//
// class PhoneOTPScreen extends StatefulWidget {
//   static const String screenId = 'phone_otp_screen';
//   final phoneNumber;
//   final verificationIdFinal;
//   const PhoneOTPScreen(
//       {Key? key, required this.phoneNumber, required this.verificationIdFinal})
//       : super(key: key);
//
//   @override
//   State<PhoneOTPScreen> createState() => _PhoneOTPScreenState();
// }
//
// class _PhoneOTPScreenState extends State<PhoneOTPScreen> {
//   bool isPinEntered = false;
//   String smsCode = "";
//
//   Auth authService = Auth();
//
//   String otp = Random().nextInt(999999).toString();
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     otp = otp.padLeft(6 - otp.length, '0');
//     SmsSender sender = SmsSender();
//     print(otp);
//     SmsMessage message = SmsMessage(widget.phoneNumber, 'Your Feed Up OTP is $otp');
//     message.onStateChanged.listen((state) {
//       if (state == SmsMessageState.Sent) {
//         print("SMS is sent!");
//
//
//       } else if (state == SmsMessageState.Delivered) {
//         print("SMS is delivered!");
//       }
//     });
//     // sender.sendSms(message);
//     return Scaffold(
//       appBar: AppBar(
//           iconTheme: IconThemeData(color: blackColor),
//           backgroundColor: whiteColor,
//           elevation: 0.5,
//           title: Text(
//             LocaleKeys.verifyOtp.tr(),
//             style: TextStyle(color: blackColor),
//           )),
//       body: SingleChildScrollView(child: _body(context)),
//       bottomNavigationBar: BottomNavigationWidget(
//         buttonText: LocaleKeys.next.tr(),
//         onPressed: validateOTP,
//         validator: isPinEntered,
//       ),
//     );
//   }
//
//   Future<void> validateOTP() async {
//     if (kDebugMode) {
//       print('sms code is : $smsCode');
//     }
//     await authService.signInwithPhoneNumber(
//         widget.verificationIdFinal, smsCode, context);
//
//     // if(smsCode == otp) {
//     //   // check if user exists
//     //   authService.users.where('mobile', isEqualTo: widget.phoneNumber).get().then((value) {
//     //
//     //     if(value.docs.length > 0) {
//     //       // user exists
//     //       Navigator.pushNamed(context, LocationScreen.screenId );
//     //     } else {
//     //       Navigator.pushReplacementNamed(context, LocationScreen.screenId);
//     //       return authService.users.add({
//     //
//     //         'mobile': widget.phoneNumber,
//     //         'email': "",
//     //         'name': '',
//     //         'address': ''
//     //       }).then((value) {
//     //
//     //
//     //
//     //         authService.users.doc(value.id).update({
//     //           'uid': value.id
//     //         });
//     //
//     //         if (kDebugMode) {
//     //           print('user added successfully');
//     //         }
//     //         // ignore: invalid_return_type_for_catch_error, avoid_print
//     //       }).catchError((error) => print("Failed to add user: $error"));
//     //     }
//     //   });
//     // }
//
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
//             radius: 30,
//             backgroundColor: whiteColor,
//             child: Icon(
//               CupertinoIcons.person_alt_circle,
//               color: secondaryColor,
//               size: 60,
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//           Text(
//             LocaleKeys.otpSentToNumber.tr(),
//             style: TextStyle(
//               color: blackColor,
//               fontSize: 15,
//             ),
//           ),
//           const SizedBox(
//             height: 5,
//           ),
//           Row(mainAxisAlignment: MainAxisAlignment.center, children: [
//             Text(
//               widget.phoneNumber,
//               style: TextStyle(
//                 color: blackColor,
//                 fontSize: 15,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(
//               width: 5,
//             ),
//             InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Icon(
//                   Icons.edit,
//                   size: 18,
//                 ))
//           ]),
//           const SizedBox(
//             height: 20,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 10,
//               vertical: 10,
//             ),
//             child: OTPTextField(
//                 length: 6,
//                 width: MediaQuery.of(context).size.width,
//                 textFieldAlignment: MainAxisAlignment.spaceAround,
//                 fieldWidth: 45,
//                 fieldStyle: FieldStyle.box,
//                 outlineBorderRadius: 15,
//                 style: const TextStyle(fontSize: 17),
//                 onChanged: (value) {
//                   if (value.length < 6) {
//                     setState(() {
//                       isPinEntered = false;
//                     });
//                   }
//                 },
//                 onCompleted: (pin) {
//                   print("Completed: " + pin);
//                   setState(() {
//                     smsCode = pin;
//                     isPinEntered = true;
//                   });
//                 }),
//           ),
//           const SizedBox(
//             height: 0,
//           ),
//           Text(
//             LocaleKeys.enterOtp.tr(),
//             style: TextStyle(
//               color: greyColor,
//               fontSize: 12,
//             ),
//           ),
//           const SizedBox(
//             height: 20,
//           ),
//         ],
//       ),
//     );
//   }
// }
