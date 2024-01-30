

import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/orders/past_order_details.dart';
import 'package:bechdal_app/screens/orders/received_orders_item.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/locale_keys.g.dart';
import '../../provider/order_provider.dart';
import '../../services/auth.dart';
import '../splash_screen.dart';

class ReceivedOrdersScreen extends StatefulWidget {
  static const screenId = 'received_orders_screen';

  const ReceivedOrdersScreen({Key? key}) : super(key: key);

  @override
  _ReceivedOrdersScreenState createState() => _ReceivedOrdersScreenState();


}
//used to update order status
String receivedOrderDocID = "";
class _ReceivedOrdersScreenState extends State<ReceivedOrdersScreen> {

  TextEditingController etaController = TextEditingController();
  Auth authService = Auth();
  UserService firebaseUser = UserService();
  bool isOpen = true;

  updateSellerOpenStatus(bool isOpen) async{
    authService.companies.where("__name__",isEqualTo: firebaseUser.user?.uid).get().then((value) {
      if(value.docs.isNotEmpty){
        setState(() {
          this.isOpen = isOpen;
        });
        authService.companies.doc(value.docs[0].id).update({
          'open':isOpen
        });
      }
    });
  }

  updateETA(String eta) async{
    await authService.companies.doc(firebaseUser.user?.uid).update( {
      'eta':eta
    });
  }
  getETA() async{
    await authService.companies.doc(firebaseUser.user?.uid).get().then((value) {
      etaController = TextEditingController(text:value['eta']);
    });
  }
  @override
  void initState() {
    getCompaniesData();
    getETA();
    super.initState();
  }
// updating orders variable after getting user uid
  getCompaniesData(){
    for (int i = 0; i < idList.length; i++) {
      if(authService.currentUser!.uid == idList[i]) {
        setState(() {
        orders =
            authService.orders.where('seller_uid',
                isEqualTo: authService.currentUser?.uid,).orderBy("created_at",descending: true).get();

        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {

    var orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height*0.08,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: AutoSizeText(
                LocaleKeys.receivedOrders.tr(),
                style: TextStyle(color: Colors.grey[100],fontSize: MediaQuery.of(context).size.width*0.09),
              ),
            ),


            Row(
              children: [
                Text(
                  LocaleKeys.openLabel.tr(),
                  style: const TextStyle(color: Colors.black),
                ),
                Switch(
                  value: isOpen,
                  onChanged: (value) {
                    updateSellerOpenStatus(value);
                  },
                  activeTrackColor: Colors.lightGreenAccent,
                  activeColor: Colors.green,
                ),
              ],
            )

          ],
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
      body: RefreshIndicator(
        onRefresh: (){
          return Future.delayed(
            const Duration(seconds: 1),(){
              getCompaniesData();
              getETA();
          }
          );
        },
        child: FutureBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasError) {
              print(snapshot.error.toString());
              return Center(
                child: Text(LocaleKeys.somethingWentWrong.tr()),
              );
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // if no orders

            if (snapshot.data.docs.isEmpty) {
              return Center(
                child: Text(LocaleKeys.noOrders.tr()),
              );
            }

          return Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(padding: EdgeInsets.only(left: MediaQuery.of(context).size.width*0.05),
                    child: Text(
                      LocaleKeys.eta.tr(),
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height*0.02,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),

                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.3,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: etaController,
                      decoration: InputDecoration(
                        hintText: LocaleKeys.eta.tr(),
                        hintStyle: TextStyle(
                          fontSize: MediaQuery.of(context).size.height*0.02,
                          fontFamily: 'Lato'
                        )
                      ),

                      onTapOutside: (value) {
                        updateETA(etaController.text);
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      onSubmitted: (value) {
                        updateETA(etaController.text);
                        FocusManager.instance.primaryFocus?.unfocus();
                      },
                      onEditingComplete: () {
                        updateETA(etaController.text);
                      },
                    ),

                  ),


                ],


              ),
              Expanded(
                  child: ListView.builder(
                  itemCount: snapshot.data.docs.length,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          receivedOrderDocID = snapshot.data.docs[index].reference.id;
                          orderProvider.setOrderDetails(snapshot.data.docs[index]);
                          Navigator.pushNamed(context, PastOrderDetails.screenId);
                        },
                        child: ReceivedOrdersItem(
                          snapshot: snapshot,
                          index: index,
                        ),
                      );
                    },
                  )
              )

            ]
          );
        },
        future: orders,

        ),
    )
    );
  }
}




























