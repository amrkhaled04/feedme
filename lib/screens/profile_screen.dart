import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/welcome_screen.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../components/change_profile_photo.dart';
import '../components/image_picker_widget.dart';
import '../l10n/locale_keys.g.dart';
import '../services/auth.dart';

class ProfileScreen extends StatefulWidget {
  static const screenId = 'profile_screen';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserService firebaseUser = UserService();


  Auth auth = Auth();
  //
  // int productCount = 0;
  // int orderCount = 0;
  // double balance = 0;
  //
  // void getUserProducts() async {
  //   setState(() {
  //     productCount = 0;
  //   });
  // }

  ImageProvider getProfileImage() {
    if (FirebaseAuth.instance.currentUser!.photoURL != null) {
      return Image.network(
        FirebaseAuth.instance.currentUser!.photoURL.toString(),

      ).image;
    } else {
      return AssetImage('assets/avatar.png');
    }
  }




  @override
  Widget build(BuildContext context) {

    // if (!UserService.guestUser) {
    //     firebaseUser.getUsePosts().then((value) {
    //       setState(() {
    //         productCount = value!.docs.length;
    //       });
    //     });
    //
    //     auth.orders
    //         .where('seller_uid',
    //             isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    //         .get()
    //         .then((value) {
    //       setState(() {
    //         orderCount = value.docs.length;
    //         balance = 0;
    //         for (var i = 0; i < value.docs.length; i++) {
    //           balance += double.parse(value.docs[i]['total_price'].toString());
    //         }
    //       });
    //   });
    // }

    return
    Container(
      color: '#f9fcf7'.toColor(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Spacer(flex: 4,),
          Column(
            children: [
              InkWell(
                onTap: () async {

                  // ask user to delete profile image

                  return openBottomSheet(
                      context: context, child: ChangeProfilePhoto()
                  );



                },
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.height*0.075,
                  backgroundImage: getProfileImage(),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                FirebaseAuth.instance.currentUser!.email.toString(),
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height*0.025,
                    fontWeight: FontWeight.bold,
                    color: blackColor),
              ),
              const SizedBox(
                height: 20,
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Column(
              //       children: [
              //         Text(
              //           balance.toString(),
              //           style: TextStyle(
              //               fontSize: MediaQuery.of(context).size.height*0.025,
              //               fontWeight: FontWeight.bold,
              //               color: blackColor),
              //         ),
              //         Text(
              //           LocaleKeys.balance.tr(),
              //           style: TextStyle(
              //               fontSize: MediaQuery.of(context).size.height*0.025,
              //               fontWeight: FontWeight.bold,
              //               color: blackColor),
              //         ),
              //       ],
              //     ),
              //     const SizedBox(
              //       width: 20,
              //     ),
              //     Column(
              //       children: [
              //         Text(
              //           orderCount.toString(),
              //           style: TextStyle(
              //               fontSize: MediaQuery.of(context).size.height*0.025,
              //               fontWeight: FontWeight.bold,
              //               color: blackColor),
              //         ),
              //         Text(
              //           LocaleKeys.orders.tr(),
              //           style: TextStyle(
              //               fontSize: MediaQuery.of(context).size.height*0.025,
              //               fontWeight: FontWeight.bold,
              //               color: blackColor),
              //         ),
              //       ],
              //     ),
              //
              //
              //   ],
              // ),

            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.08,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pushNamed('past_orders');
                  },
                  child: Text(LocaleKeys.previousOrders.tr(),
                      style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.02)),
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      backgroundColor: '#80cf70'.toColor(),
                      minimumSize: Size(MediaQuery.of(context).size.width*0.8, MediaQuery.of(context).size.height*0.075)
                  ),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
              onPressed: (){
                String locale = context.locale.toString();

                if (locale.contains('en')) {
                  context.setLocale(const Locale('ar'));
                } else {
                  context.setLocale(const Locale('en'));
                }

              },
              child: Text(LocaleKeys.switchLanguage.tr(),
                  style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.02)),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: '#80cf70'.toColor(),
                  minimumSize: Size(MediaQuery.of(context).size.width*0.8, MediaQuery.of(context).size.height*0.075)
              ),
          ),
          SizedBox(
            height: 15,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: '#80cf70'.toColor(),
                  minimumSize: Size(MediaQuery.of(context).size.width*0.8, MediaQuery.of(context).size.height*0.075)
              ),
              onPressed: () async {
                loadingDialogBox(context, 'Signing Out');


                await googleSignIn.signOut();

                await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      WelcomeScreen.screenId, (route) => false);
                });
              },
              child: Text(
                LocaleKeys.signOut.tr(),
                  style: TextStyle(fontSize: MediaQuery.of(context).size.height*0.02)
              )
          ),
          Spacer(flex: 4,),
        ],
      ),
    );
  }
}
