


import 'package:auto_size_text/auto_size_text.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/provider/order_provider.dart';
import 'package:bechdal_app/screens/orders/past_order_details.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../l10n/locale_keys.g.dart';
import '../../services/auth.dart';
import '../../services/user.dart';

class PastOrdersScreen extends StatefulWidget {
  static const String screenId = 'past_orders';

  const PastOrdersScreen({Key? key}) : super(key: key);

  @override
  _PastOrdersScreenState createState() => _PastOrdersScreenState();
}



class _PastOrdersScreenState extends State<PastOrdersScreen> {

  Auth authService = Auth();
  UserService firebaseUser = UserService();


  @override
  Widget build(BuildContext context) {

    /*
    * Get orders using user uid from firebase
    * load orders in listview
    * */

    var orderProvider = Provider.of<OrderProvider>(context);


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
            LocaleKeys.pastOrders.tr(),
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
      body: UserService.guestUser ?
      Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, 'login_screen');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: secondaryColor,
            shadowColor: Colors.transparent,
          ),
          child: Text(LocaleKeys.pleaseLoginToSeePastOrders.tr()),
        ),
      )
          :
       FutureBuilder(
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(LocaleKeys.somethingWentWrong.tr()),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // check if there is no orders
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(LocaleKeys.noOrders.tr()),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var data = snapshot.data!.docs[index];


              var date = data['created_at'].toDate();

              return Column(
                children: [
                  ListTile(
                    onTap: () {

                      orderProvider.setOrderDetails(data);
                      Navigator.pushNamed(context, PastOrderDetails.screenId);

                    },
                    // leading: CircleAvatar(
                    //   radius: 30,
                    //   backgroundImage: NetworkImage(data['image']),
                    // ),
                    title: Text(
                      data['seller_name'],
                      style: const TextStyle(
                        fontFamily: 'Lato',
                          color: Colors.black, fontWeight: FontWeight.bold)
                    ),
                    subtitle: Text(
                      '${LocaleKeys.currency.tr()} ${NumberFormat('##,##,##0').format(data['total_price'])}',
                      style: const TextStyle(
                          fontFamily: 'Lato',
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    trailing: Text(
                      '${date.day}/${date.month}/${date.year}',
                      style: const TextStyle(
                        fontFamily: 'Lato',
                          color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(
                    thickness: 1,
                  )
                ],
              );
            },
          );
        },
        future: authService.orders
            .where('user_uid', isEqualTo: firebaseUser.user!.uid)
            .get(),

      )
      ,

    );
  }
}





