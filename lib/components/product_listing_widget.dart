import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/screens/product/product_card.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_keys.g.dart';

class ProductListing extends StatefulWidget {
  final bool? isProductByCategory;

  const ProductListing({Key? key, this.isProductByCategory}) : super(key: key);

  @override
  State<ProductListing> createState() => _ProductListingState();
}

class _ProductListingState extends State<ProductListing> {
  Auth authService = Auth();
  List sellers = [];


  void refreshScreen() {
    // force refresh screen
    setState(() {});


  }

  // get sellers selling products of selected category

  Future<void> getSellers() async {
    var categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    var productProvider = Provider.of<ProductProvider>(context, listen: false);
    List sellerIds = [];
    QuerySnapshot data = await authService.products.where('category', isEqualTo: categoryProvider.selectedCategory!['english_category_name']).get();
    setState(() {
      sellerIds = List.from(data.docs.map((doc) => doc['seller_uid']).toList());

      // get seller details
      for(int i = 0; i<sellerIds.length;i++){
        authService.users.doc(sellerIds[i]).get().then((value) {
          sellers.add(value);
        });
      }

    });
  }



  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);
    var categoryProvider = Provider.of<CategoryProvider>(context);

    final numberFormat = NumberFormat('##,##,###.##');
    return FutureBuilder<QuerySnapshot>(
        future: (widget.isProductByCategory == true)
            ? categoryProvider.selectedCategory!['english_category_name'] == 'Cars'
                ? authService.products
                    .orderBy('posted_at')
                    .where('category',
                        isEqualTo: categoryProvider.selectedCategory!['english_category_name'])
                    .get()
                : authService.products
                    .orderBy('posted_at')
                    .where('category',
                        isEqualTo: categoryProvider.selectedCategory!['english_category_name'])
                    .where('subcategory',
                        isEqualTo: categoryProvider.selectedSubCategory!['english_subcategory_name'])
                    .get()
            : authService.products.orderBy('posted_at').get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(LocaleKeys.somethingWentWrong.tr()));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          }
          return (snapshot.data!.docs.isEmpty)
              ? SizedBox(
                  height: MediaQuery.of(context).size.height - 50,
                  child: Center(
                    child: Text(LocaleKeys.noProductsFound.tr()),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      (widget.isProductByCategory != null)
                          ? const SizedBox()
                          : Container(
                              child: Column(
                                children: [
                                  Text(
                                    LocaleKeys.homePageRecommendation.tr(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: blackColor,
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
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.82,
                          ),
                          itemCount: snapshot.data!.size,
                          itemBuilder: (BuildContext context, int index) {
                            var data = snapshot.data!.docs[index];
                            var price = double.parse(data['price']);
                            String formattedPrice = numberFormat.format(price);
                            return Container(
                              margin: const EdgeInsets.all(5),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: [
                                  BoxShadow(
                                    color: '#e6eedf'.toColor(),
                                    spreadRadius: 1,
                                    blurRadius: 2,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: ProductCard(
                                data: data,
                                formattedPrice: formattedPrice,
                                numberFormat: numberFormat,
                                refreshCallBack: refreshScreen,
                              ),
                            );
                          }),
                    ],
                  ),
                );
        });
  }
}
