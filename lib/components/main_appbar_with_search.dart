import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/l10n/locale_keys.g.dart';
import 'package:bechdal_app/models/product_model.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:bechdal_app/services/search.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/seller_model.dart';

class MainAppBarWithSearch extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  const MainAppBarWithSearch({
    required this.controller,
    required this.focusNode,
    Key? key,
  }) : super(key: key);

  @override
  State<MainAppBarWithSearch> createState() => _MainAppBarWithSearchState();
}

String buyerName = "";
String buyerMobile = "";
GeoPoint? buyerLoc;
class _MainAppBarWithSearchState extends State<MainAppBarWithSearch> {
  static List<Products> products = [];
  static List<Sellers> sellers = [];
  Auth authService = Auth();
  Search searchService = Search();
  String address = '';
  UserService firebaseUser = UserService();
  DocumentSnapshot? sellerDetails;
  @override
  void initState() {
    FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).get().then(
            (value) {
              buyerName = value['name'];
              buyerMobile = value['mobile'];
              buyerLoc = value['location'];
            });
    authService.products.get().then(((QuerySnapshot snapshot) {
      for (var doc in snapshot.docs) {
        products.add(Products(
            document: doc,
            title: doc['title'],
            description: doc['description'],
            category: doc['category'],
            subcategory: doc['subcategory'],
            price: doc['price']));
        getSellerAddress(doc['seller_uid']);
      }

      authService.users.where('status', isEqualTo: 'seller').get().then((value) {
        for (var doc in value.docs) {

          double rating = 0;

          authService.reviews.where('seller_uid',isEqualTo: doc['uid']).get().then((value) {
            if (mounted) {

                double rating = 0;
                for (var i = 0; i < value.docs.length; i++) {
                  rating = rating + value.docs[i]['rating'];
                }
                rating = rating / value.docs.length;

                sellers.add(Sellers(
                    document: doc,
                    rating: rating,
                    name: doc['name'],
                )
                );
            }
          });

        }
      });


    }));
    super.initState();
  }

  getSellerAddress(selledId) {
    firebaseUser.getSellerData(selledId).then((value) => {
          setState(() {
            address = value['address'];
            sellerDetails = value;
          })
        });
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<ProductProvider>(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18)),
          color: '#80cf70'.toColor()),
      height: MediaQuery.of(context).size.height*0.18,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 2.0,top: MediaQuery.of(context).size.height*0.037),
                child: Text(

                  '${LocaleKeys.hi.tr()}, $buyerName',
                  style: TextStyle(
                    color: Colors.grey[100],
                    fontSize: context.locale.languageCode == 'en'?MediaQuery.of(context).size.height*0.035:
                    MediaQuery.of(context).size.height*0.03,
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  searchService.searchQueryPage(
                      context: context,
                      products: products,
                      sellers: sellers,
                      address: address,
                      sellerDetails: sellerDetails,
                      provider: provider,
                      );
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: context.locale.languageCode == 'en'?
                  MediaQuery.of(context).size.height*0.009:MediaQuery.of(context).size.height*0.007,),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.009,horizontal: 8),
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(color: disabledColor.withOpacity(0.2),blurRadius: 2)
                      ],
                      borderRadius: BorderRadius.circular(15),
                      color: '#f9fcf7'.toColor(),
                    ),
                    child:  Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.search_rounded,
                            color: Colors.grey,
                            size: MediaQuery.of(context).size.height*0.03,
                          ),
                        ),
                        Text(LocaleKeys.searchMessage.tr(),style: TextStyle(color: Colors.grey,
                        fontSize: MediaQuery.of(context).size.height*0.019))
                      ]
                    )
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
