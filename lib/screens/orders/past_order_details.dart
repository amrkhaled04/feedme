




import 'dart:convert';
import 'package:bechdal_app/screens/orders/received_orders_screen.dart';
import 'package:bechdal_app/screens/splash_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';


import '../../l10n/locale_keys.g.dart';
import '../../provider/order_provider.dart';
import '../../services/auth.dart';

class PastOrderDetails extends StatefulWidget {

  static const String screenId = 'past_order_details';

  const PastOrderDetails({Key? key}) : super(key: key);


  @override
  _PastOrderDetailsState createState() => _PastOrderDetailsState();
}




class _PastOrderDetailsState extends State<PastOrderDetails> {
  _launchCaller(String phonenum) async {
    String url = "tel:$phonenum";
    if (await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrlString(googleUrl)) {
      await launchUrlString(googleUrl,mode: LaunchMode.externalNonBrowserApplication);
    } else {
      throw 'Could not open the map.';
    }
  }

  Auth authService = Auth();
  String userToken = "";
  void sendNotification(String title,String body)async{

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
                  'body':body,
                  'title':title,
                },

                "notification":<String,dynamic>{
                  "title":title,
                  "body": body,
                  "android_channel_id": "dbfood"
                },
                "to":userToken
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
    authService.users.doc(userUid).get().then((value){
      setState(() {
        userToken = value['token'];
      });
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    var orderProvider = Provider.of<OrderProvider>(context);
    var date = orderProvider.orderData!['created_at'].toDate();

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
            LocaleKeys.orderDetails.tr(),
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
      backgroundColor: '#f9fcf7'.toColor(),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              LocaleKeys.orderDetails.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '${LocaleKeys.orderId.tr()}: ',
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: MediaQuery.of(context).size.width*0.045),
                ),
                Text(
                  orderProvider.orderData!.id,
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: MediaQuery.of(context).size.width*0.045),
                ),
              ],
            )
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '${LocaleKeys.orderDate.tr()}: ',
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: MediaQuery.of(context).size.width*0.045),
                ),
                Text(
                  '${DateFormat.yMMMd().format(date)} ${DateFormat.jm().format(date)}',
                  style: TextStyle(
                      fontFamily: 'Lato',
                      fontSize: MediaQuery.of(context).size.width*0.045),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '${LocaleKeys.orderStatus.tr()}: ',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
                ),
                (!isCompany) ? Text(
                  orderProvider.orderData!['order_status'],
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
                ) : IconButton(
                    onPressed: (){
                      sendNotification("Delivering your order", "Your order is in delivery now by the restaurant");
                      authService.orders.doc(receivedOrderDocID).update({
                        'order_status': 'done'
                      });
                    },
                    icon: const Icon(Icons.done_outline_rounded)),
                (!isCompany) ? Container() : IconButton(
                    onPressed: (){
                      sendNotification("Your order cancelled", "Your order is cancelled by the restaurant");
                      authService.orders.doc(receivedOrderDocID).update({
                        'order_status': 'cancelled'
                      });
                    },
                    icon: const Icon(Icons.cancel_outlined))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${LocaleKeys.totalPrice.tr()}: ${orderProvider.orderData!['total_price']}',
              style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: MediaQuery.of(context).size.width*0.045),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '${LocaleKeys.paymentMethod.tr()}: ',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
                ),
                Text(
                orderProvider.orderData!['payment_method'] == 'cash on delivery' ? LocaleKeys.cashOnDelivery.tr() : 'Online Payment',
                style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
                ),
              ],
            )
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '${LocaleKeys.deliveryAddress.tr()}: ',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
                ),
                const Icon(Icons.location_on_outlined),
                GestureDetector(
                  onTap: (){
                    GeoPoint loc = orderProvider.orderData!['buyer_loc'];
                    openMap(loc.latitude, loc.longitude);
                  },
                  child: Text(
                    orderProvider.orderData!['address'],
                    softWrap: false,
                    overflow: TextOverflow.fade,
                    maxLines: 2,
                    style: TextStyle(
                      overflow: TextOverflow.fade,
                        decoration: TextDecoration.underline,
                        fontSize: MediaQuery.of(context).size.width*0.037),
                  ),
                ),
                
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '${LocaleKeys.buyerName.tr()}: ',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
                ),
                Text(
                  orderProvider.orderData!['buyer_name'],
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  '${LocaleKeys.phoneNumber.tr()}: ',
                  style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
                ),
                const Icon(Icons.call_rounded),
                GestureDetector(
                  onTap: (){
                    _launchCaller(orderProvider.orderData!['buyer_mobile']);
                  },
                  child: Text(
                    orderProvider.orderData!['buyer_mobile'],
                    style: TextStyle(
                        fontFamily: 'Lato',
                        decoration: TextDecoration.underline,
                        fontSize: MediaQuery.of(context).size.width*0.045),
                  ),
                )
              ],
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     'Delivery Date: ${orderProvider.orderData!['delivery_date']}',
          //     style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     'Delivery Time: ${orderProvider.orderData!['delivery_time']}',
          //     style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Divider(
          //     thickness: 1,
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     LocaleKeys.sellerDetails.tr(),
          //     style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          //   ),
          // ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       Text(
          //         '${LocaleKeys.sellerName.tr()}: ',
          //         style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
          //       ),
          //       // Text(
          //       //   orderProvider.orderData!['seller_name'],
          //       //   style: TextStyle(fontSize: MediaQuery.of(context).size.width*0.045),
          //       // )
          //     ],
          //   ),
          // ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Divider(
              thickness: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              LocaleKeys.productDetails.tr(),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: orderProvider.orderData!['products'].length,
            itemBuilder: (BuildContext context, int index) {
              var data = orderProvider.orderData!['products'][index];
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(data['product_img']),
                    ),
                    title: Text(
                      data['title'],
                      style: const TextStyle(
                        fontFamily: 'Lato',
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${LocaleKeys.currency.tr()} ${data['price']}',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${LocaleKeys.quantity.tr()}: ',
                          style: const TextStyle(
                            fontFamily: 'Lato',
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data['quantity'].toString(),
                          style: const TextStyle(
                            fontFamily: 'Lato',
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ],
                    )
                  ),

                  const Divider(
                    thickness: 1,
                  )
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
