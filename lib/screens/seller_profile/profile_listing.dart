

import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/seller_profile/profile_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/locale_keys.g.dart';
import '../../provider/category_provider.dart';
import '../../services/auth.dart';
import '../../services/user.dart';

class ProfileListing extends StatefulWidget {

  bool? isProductByCategory = false;
  ProfileListing({Key? key, this.isProductByCategory}) : super(key: key);

  @override
  _ProfileListingState createState() => _ProfileListingState();
}

class _ProfileListingState extends State<ProfileListing> {

  Auth authService = Auth();
  UserService firebaseUser = UserService();


  Future<QuerySnapshot<Object?>> getSellers() async {
    var categoryProvider = Provider.of<CategoryProvider>(context, listen: false);



    QuerySnapshot categoryProducts = await authService.products.where('category', isEqualTo: categoryProvider.selectedCategory!['english_category_name']).where('subcategory', isEqualTo: categoryProvider.selectedSubCategory!['english_subcategory_name']).get();

    // get seller data selling these products

    QuerySnapshot data = await authService.users.where('status', isEqualTo: 'seller').where('uid',whereIn: List.from(categoryProducts.docs.map((doc) => doc['seller_uid']).toList())).get();

    return data;

  }
  


  @override
  Widget build(BuildContext context) {


    return FutureBuilder(
      future: (widget.isProductByCategory == true) ? getSellers() : authService.users.where('status', isEqualTo: 'seller').get(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(LocaleKeys.somethingWentWrong.tr()));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container();
          //   const Center(
          //   child: CircularProgressIndicator( color: secondaryColor ),
          // );
        }


        return (snapshot.data!.docs.isEmpty)
            ? SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Center(
                  child: Text(LocaleKeys.noRestaurantsFound.tr()),
                ),
              )
            : Container(
              decoration: BoxDecoration(color: '#f9fcf7'.toColor()),
              padding: const EdgeInsets.only(left: 8,right: 6),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      child: Column(
                        children: [
                          Text(
                            (widget.isProductByCategory == true) ? "" : LocaleKeys.homePageRecommendation.tr(),
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height*0.027,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    GridView.builder(
                        physics: const ScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        shrinkWrap: true,
                        gridDelegate:
                        SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: MediaQuery.of(context).size.width*0.48,
                          childAspectRatio: 2,
                          mainAxisExtent: MediaQuery.of(context).size.height*0.23,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: snapshot.data!.size,
                        itemBuilder: (BuildContext context, int index) {
                          QueryDocumentSnapshot<Object?> data = snapshot.data!.docs[index];

                          return ProfileCard(
                            data: data,
                          );
                        })
                  ]
        ),
            );
      },
    );
  }
}