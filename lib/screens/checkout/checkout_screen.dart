


import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bechdal_app/screens/checkout_lottie.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:bechdal_app/extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/locale_keys.g.dart';
import '../../provider/cart_provider.dart';
import '../../services/auth.dart';
import '../../services/user.dart';
import '../product/product_details_screen.dart';
import '../splash_screen.dart';

class CheckoutScreen extends StatefulWidget {
  static const String screenId = 'checkout_screen';

  const CheckoutScreen({Key? key}) : super(key: key);


  @override
  _CheckoutScreenState createState() => _CheckoutScreenState();
}

var deliveryAddressController = TextEditingController();

int shippingCost = 0;

class _CheckoutScreenState extends State<CheckoutScreen> {
  Auth authService = Auth();
  UserService firebaseUser = UserService();
  String companyToken = "";
  String orderETA = "";

  void sendNotification()async{

    try{
      await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String,String>{
          'Content-Type': 'application/json',
          'Authorization':'key=AAAAj8Vfbcg:APA91bFpRQQ4hQEIihQusXjexDV2bAIJdI7BPzDhu9tTjdSnRaHxKrOVL8I24MuBiULWLWNqW3aQOkezkfsJcXd0ttghk32yCwS0RavxAn5iN7h_YQ5Iq555m73LUhlpu9GhIRTyqicm'
        },
        body: jsonEncode(
          <String,dynamic>{
            'priority':'high',
            'data': <String,dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'status': 'done',
              'body':'New order created',
              'title':'New order',
            },

            "notification":<String,dynamic>{
              "title":"New order",
              "body": "New order created",
              "android_channel_id": "dbfood"
            },
            "to":companyToken
          }
        )
      );
    }catch(e){
      if(kDebugMode){
        print("error push notification");
      }

    }
  }

  @override
  void initState() {
    authService.users.doc(FirebaseAuth.instance.currentUser?.uid).get().then((value) {
      for(int i = 0;i<idList.length;i++){
        if(data['seller_uid'] == idList[i]){
          if(companiesData![i]['delivery'][value['city']] != null){
            setState(() {
              orderETA = companiesData![i]['eta'];
              companyToken = companiesData![i]['token'];
              shippingCost = int.parse(companiesData![i]['delivery'][value['city']]);
            });
          }
        }
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    var cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.08,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        title: FittedBox(
          fit: BoxFit.cover,
          child: AutoSizeText(
            LocaleKeys.checkout.tr(),
            style: TextStyle(color: Colors.grey[100],fontSize: MediaQuery.of(context).size.width*0.09),
          ),
        ),
        backgroundColor: '#80cf70'.toColor(),
        elevation: 0.5,
        // make back button black
        iconTheme: IconThemeData(
          color: Colors.grey[100],
          size: MediaQuery.of(context).size.height*0.04,
        ),
      ),
      body: FutureBuilder(
        future: firebaseUser.getUserData(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot){

      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      }

      deliveryAddressController.text = snapshot.data['address'];

      return Container(
        color: '#f9fcf7'.toColor(),
          child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(

                    children: [
                      Text(
                        '${LocaleKeys.deliveryAddress.tr()}: ',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                          child:TextField(
                        controller: deliveryAddressController,
                        decoration: InputDecoration(
                          hintText: LocaleKeys.deliveryAddressHint.tr(),
                        ),
                        onChanged: (value) {
                          snapshot.data['address'] = value;
                        },
                      )
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        '${LocaleKeys.name.tr()}: ',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        snapshot.data['name'],
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*0.045,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        '${LocaleKeys.phoneNumber.tr()}: ',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        snapshot.data['mobile'],
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: MediaQuery.of(context).size.width*0.045,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        '${LocaleKeys.paymentMethod.tr()}: ',
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        LocaleKeys.cashOnDelivery.tr(),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*0.045,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        LocaleKeys.orderSummary.tr(),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        LocaleKeys.subtotal.tr(),
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.width*0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${LocaleKeys.currency.tr()} ${cartProvider.cartDataMap['total_price']}',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: MediaQuery.of(context).size.width*0.045,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        LocaleKeys.deliveryFee.tr(),
                        style: TextStyle(

                          fontSize: MediaQuery.of(context).size.width*0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${LocaleKeys.currency.tr()} $shippingCost',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: MediaQuery.of(context).size.width*0.045,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Text(
                        LocaleKeys.orderETA.tr(),
                        style: TextStyle(

                          fontSize: MediaQuery.of(context).size.width*0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '$orderETA ${LocaleKeys.minutes.tr()} ',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: MediaQuery.of(context).size.width*0.045,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Confirm Order Button
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Flexible(
                          child:ElevatedButton(
                        onPressed: () async {
                          await cartProvider.confirmOrder();
                          sendNotification();
                          Navigator.of(context).pushNamedAndRemoveUntil(Checkout.screenId, (route) => false);
                        },
                        style:  ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: '#80cf70'.toColor(),
                          minimumSize: Size.fromHeight(MediaQuery.of(context).size.height*0.078)
                        ),
                        child: Text(
                          LocaleKeys.confirmOrder.tr(),
                          style: TextStyle(
                            color: Colors.grey.shade200,
                            fontSize: MediaQuery.of(context).size.width*0.055,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                      ),
                    ],
                  ),
                ),
              ]
          )

      );


        },
      ),
    );
  }
}




