import 'dart:async';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/l10n/locale_keys.g.dart';
import 'package:bechdal_app/screens/main_navigatiion_screen.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/screens/orders/received_orders_screen.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../provider/cart_provider.dart';
import '../services/user.dart';

class SplashScreen extends StatefulWidget {
  static const String screenId = 'splash_screen';
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}


List<String> idList = [];
CollectionReference companies = FirebaseFirestore.instance.collection('companies');
Future<QuerySnapshot<Object?>>? orders;
List? companiesData;
String? mtoken = " ";
bool isCompany = false;

class _SplashScreenState extends State<SplashScreen> {
  Auth authService = Auth();




  var cartProvider;



  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    permissionBasedNavigationFunc();
    getToken();
    getPermission();
    getCompaniesData();
    super.initState();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
      });
    });
  }

  void getPermission()async{
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  }

  Future<void> getCompaniesData() async{
    QuerySnapshot data = await companies.get();
    setState(() {
      for (var snapshot in data.docs) {
        idList.add(snapshot.id);
      }
      // assigning orders variable to be used in splash if company logged in before
      if(authService.currentUser != null) {
        for (int i = 0; i < idList.length; i++) {
          if(authService.currentUser?.uid == idList[i]) {
            orders =
                authService.orders.where('seller_uid',
                    isEqualTo: authService.currentUser?.uid).orderBy("created_at",descending: false).get();
          }
        }
      }
      companiesData = List.from( data.docs.map((doc) => doc.data()).toList());
    });
  }

  permissionBasedNavigationFunc()  {


    Timer(const Duration(seconds: 4), () async {

      final SharedPreferences prefs = await _prefs;

      final bool guest = prefs.getBool('guest') ?? false;

      if (guest) {
        UserService.guestUser = true;
        Navigator.pushReplacementNamed(context, MainNavigationScreen.screenId);
        return;
      }

      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user == null) {

          prefs.setBool('guest', true);

          UserService.guestUser = true;

          Navigator.pushReplacementNamed(context, MainNavigationScreen.screenId);
        } else {
          cartProvider.setCartDetailsByUid(user.uid);

          for(var id in idList){
            if(id == user.uid){
              isCompany = true;
              companies.doc(id).update({
                'token':mtoken
              });
              Navigator.pushReplacementNamed(
                  context, ReceivedOrdersScreen.screenId);
              break;
            }
          }
         if (!isCompany){
           authService.users.doc(authService.currentUser?.uid).update(
             {
               'token':mtoken
             }
           );
           Navigator.pushReplacementNamed(
          context, MainNavigationScreen.screenId);
         }
        }

      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    cartProvider = Provider.of<CartProvider>(context, listen: false);

    // set app locale based on phone language
    EasyLocalization.of(context)!;
    return Scaffold(
      backgroundColor: '#f9fcf7'.toColor(),
      body: Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  LocaleKeys.appName.tr(),
                  style: TextStyle(
                      color: secondaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.height*0.04),
                ),
                Text(
                  LocaleKeys.splashScreenSlogan.tr(),
                  style: TextStyle(
                    color: blackColor,
                    fontSize: MediaQuery.of(context).size.height*0.023,
                  ),
                )
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.height*0.1),
            height: MediaQuery.of(context).size.height*0.8,
            child: Lottie.asset(
              "assets/lottie/splash_lottie.json",
              width: MediaQuery.of(context).size.width,
            ),
          ),
        ],
      ),
    );
  }
}
