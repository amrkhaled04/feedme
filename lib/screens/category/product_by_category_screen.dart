import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../seller_profile/profile_listing.dart';

class ProductByCategory extends StatelessWidget {
  static const String screenId = 'product_by_category';
  const ProductByCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    String categoryName = context.locale.toString() == 'en' ? categoryProvider.selectedCategory!['english_category_name'] : categoryProvider.selectedCategory!['arabic_category_name'];
    String subcategoryName =
        context.locale.toString() == 'en' ? categoryProvider.selectedSubCategory!['english_subcategory_name'] : categoryProvider.selectedSubCategory!['arabic_subcategory_name'];
    return Scaffold(
        appBar: AppBar(
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(10),
            ),
          ),
          toolbarHeight: MediaQuery.of(context).size.height * 0.08,
          backgroundColor: '#80cf70'.toColor(),
          elevation: 0.5,
          iconTheme: IconThemeData(
            color: Colors.grey.shade200,
            size: MediaQuery.of(context).size.height * 0.04,
          ),
          title: Text(
            (categoryProvider.selectedSubCategory == null)
                ? 'Cars'
                : '$categoryName ${'> $subcategoryName'}',
            style: TextStyle(
              fontSize: MediaQuery.of(context).size.width*0.08,
              color: Colors.grey.shade200,
            ),
          ),
        ),
        backgroundColor: '#f9fcf7'.toColor(),
        body: SingleChildScrollView(
            child: ProfileListing(
          isProductByCategory: true,
        )));
  }
}
