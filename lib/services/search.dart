import 'package:bechdal_app/components/product_listing_widget.dart';
import 'package:bechdal_app/components/search_card.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/l10n/locale_keys.g.dart';
import 'package:bechdal_app/models/product_model.dart';
import 'package:bechdal_app/models/search_model.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/screens/product/product_details_screen.dart';
import 'package:bechdal_app/screens/seller_profile/seller_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:search_page/search_page.dart';

import '../models/seller_model.dart';

class Search {
  searchQueryPage(
      {required BuildContext context,
      required List<SearchModel> products,
      required List<SearchModel> sellers,
      required String address,
      DocumentSnapshot? sellerDetails,
      required ProductProvider provider}) {
    print('address: $address');
    showSearch(
      context: context,
      delegate: SearchPage<SearchModel>(
          barTheme: ThemeData(
              appBarTheme: AppBarTheme(
                  toolbarHeight: MediaQuery.of(context).size.height*0.08,
                  backgroundColor: whiteColor,
                  elevation: 0.5,
                  surfaceTintColor: primaryColor,
                  iconTheme: IconThemeData(color: blackColor,size: MediaQuery.of(context).size.height*0.04,),
                  actionsIconTheme: IconThemeData(color: blackColor))),
          onQueryUpdate: (s) => print(s),
          items: [...products, ...sellers],
          searchLabel: LocaleKeys.searchMessage.tr(),
          suggestion: const SingleChildScrollView(child: ProductListing()),
          failure: Center(
            child: Text(LocaleKeys.searchFailureMessage.tr()),
          ),
          filter: (item) => [
                item is Products ? item.title : item is Sellers ? item.name : '',
                item is Products ? item.description : '',
                item is Products ? item.category : '',
                item is Products ? item.subcategory : '',
              ],

          builder: (item) {
            return InkWell(
                onTap: () {
                  provider.setProductDetails(item.document);
                  provider.setSellerDetails(sellerDetails);
                  if (item is Products) {
                    Navigator.pushNamed(context, ProductDetail.screenId);
                  } else {
                    Navigator.pushNamed(context, SellerProfileScreen.screenId);
                  }

                },
                child: SearchCard(
                  item: item,
                  address: (item is Products) ? address : ''),
                );
          }),
    );
  }
}
