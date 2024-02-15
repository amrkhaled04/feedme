import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/screens/product/product_details_screen.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/locale_keys.g.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({
    Key? key,
    required this.data,
    required this.formattedPrice,
    required this.numberFormat,
    required this.refreshCallBack,
  }) : super(key: key);

  final QueryDocumentSnapshot<Object?> data;
  final String formattedPrice;
  final NumberFormat numberFormat;
  final VoidCallback refreshCallBack;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  Auth authService = Auth();
  UserService firebaseUser = UserService();

  String address = '';
  DocumentSnapshot? sellerDetails;
  bool isLiked = false;
  List fav = [];
  @override
  void initState() {
    getSellerData();
    getFavourites();
    super.initState();
  }

  getSellerData() {
    firebaseUser.getSellerData(widget.data['seller_uid']).then((value) {
      if (mounted) {
        setState(() {
          address = value['address'];
          sellerDetails = value;
        });
      }
    });
  }

  getFavourites() {
    authService.products.doc(widget.data.id).get().then((value) {
      if (mounted) {
        setState(() {
          fav = value['favourites'];
        });
      }
      if (!UserService.guestUser && fav.contains(firebaseUser.user!.uid)) {
        if (mounted) {
          setState(() {
            isLiked = true;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            isLiked = false;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);

    Auth auth = Auth();

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        productProvider.setSellerDetails(sellerDetails);
        productProvider.setProductDetails(widget.data);
        Navigator.pushNamed(context, ProductDetail.screenId);
      },
      child: Container(
        margin: const EdgeInsets.all(5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: whiteColor,
          borderRadius: BorderRadius.circular(4),
          boxShadow: [
            BoxShadow(
               color: '#e6eedf'.toColor(),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 1)
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: '#f9fcf7'.toColor(),
                alignment: Alignment.center,
                height: MediaQuery.of(context).size.height*0.12,
                child: Image.network(
                  widget.data['images'][0],
                  fit: BoxFit.fill,
                )),
            const SizedBox(
              height: 10,
            ),
            Text(
              widget.data['title'],
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: MediaQuery.of(context).size.width*0.043,
              ),
            ),
            Text(
              '${LocaleKeys.currency.tr()} ${widget.formattedPrice}',
              style: TextStyle(
                fontFamily: 'Lato',
                fontSize: MediaQuery.of(context).size.width*0.037,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
