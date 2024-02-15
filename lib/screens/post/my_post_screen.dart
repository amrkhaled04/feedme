import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/product/product_card.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../l10n/locale_keys.g.dart';

class MyPostScreen extends StatefulWidget {
  static const screenId = 'my_post_screen';
  const MyPostScreen({Key? key}) : super(key: key);

  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  Auth authService = Auth();
  UserService firebaseUser = UserService();

  bool refresh = false;


  void refreshScreen() {
    setState(() {
      refresh = !refresh;
    });
  }


  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
          toolbarHeight: MediaQuery.of(context).size.height*0.08,
          backgroundColor: '#80cf70'.toColor(),
          elevation: 0.5,
          title: Text(
            LocaleKeys.favourites.tr(),
            style: TextStyle(color: Colors.grey.shade200, fontSize: MediaQuery.of(context).size.height*0.04),
          ),
        ),
        backgroundColor: '#f9fcf7'.toColor(),
        body: bodyWidget(authService: authService, firebaseUser: firebaseUser, context: context, ref: refreshScreen ),
      ),
    );
  }
}

bodyWidget({required Auth authService, required UserService firebaseUser, required BuildContext context, required VoidCallback ref}) {


  // number format for price in decimal
  var numberFormat = NumberFormat('#,##,###.##');

  return
  TabBarView(children: [
    StreamBuilder<QuerySnapshot>(
        stream: authService.products
            .where('favourites', arrayContains: firebaseUser.user!.uid)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(LocaleKeys.errorLoadingProducts.tr()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          }
          if (snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                LocaleKeys.noFavourites.tr(),
                style: TextStyle(
                  color: blackColor,
                ),
              ),
            );
          }
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 5, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: GridView.builder(
                      scrollDirection: Axis.vertical,
                      gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 200,
                        childAspectRatio: 2/2,
                        mainAxisExtent: 250,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: snapshot.data!.size,
                      itemBuilder: (BuildContext context, int index) {
                        var data = snapshot.data!.docs[index];
                        var price = double.parse(data['price']);
                        String formattedPrice = numberFormat.format(price);
                        return ProductCard(
                          data: data,
                          formattedPrice: formattedPrice,
                          numberFormat: numberFormat,
                          refreshCallBack: ref,
                        );
                      }),
                ),
              ],
            ),
          );
        }),
  ]);
}
