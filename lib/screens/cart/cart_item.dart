

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../l10n/locale_keys.g.dart';
import '../../provider/cart_provider.dart';
import '../../services/auth.dart';
import '../../services/user.dart';

class CartItem extends StatefulWidget {

  Auth authService;
  UserService firebaseUser;
  int index;
  Map<String, dynamic> snapshot;

  VoidCallback refreshCartCount;

  CartItem({Key? key, required this.authService, required this.firebaseUser, required this.index, required this.snapshot, required this.refreshCartCount}) : super(key: key);





  @override
  State<CartItem> createState() => _CartItemState(authService, firebaseUser, index, snapshot, refreshCartCount);
}

class _CartItemState extends State<CartItem> {

  Auth authService;
  UserService firebaseUser;

  int index;
  Map<String, dynamic> snapshot;

  VoidCallback refreshCartCount;

  _CartItemState(this.authService, this.firebaseUser, this.index, this.snapshot, this.refreshCartCount);

  @override
  Widget build(BuildContext context) {
    var cartProvider = Provider.of<CartProvider>(context);
    return FutureBuilder(
      future: firebaseUser.getProductDetails(
          snapshot['products'][index]['product_id']),
      builder: (BuildContext context, AsyncSnapshot productSnapshot) {
        if (productSnapshot.hasError) {
          return Center(
            child: Text(LocaleKeys.somethingWentWrong.tr()),
          );
        }
        if (productSnapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        return Container(
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: whiteColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 1,
                blurRadius: 2,
                offset: const Offset(0, 0.8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(
                        productSnapshot.data['images'][0]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productSnapshot.data['title'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      '${LocaleKeys.currency.tr()} ${productSnapshot.data['price']}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Quantity: ${snapshot['products'][index]['quantity']}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w100,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  // delete product from cart
                  authService.carts
                      .doc(cartProvider.cartData!.id)
                      .update({
                    'products': FieldValue.arrayRemove([
                      snapshot['products'][index],
                    ]),
                    'total_price': snapshot['total_price'] - double.parse(productSnapshot.data['price']) * snapshot['products'][index]['quantity'],
                    'cart_count': snapshot['cart_count'] - snapshot['products'][index]['quantity']
                      });


                  setState(() {
                    cartProvider.cartDataMap['total_price'] = cartProvider.cartDataMap['total_price'] - double.parse(productSnapshot.data['price']) * snapshot['products'][index]['quantity'];
                    cartProvider.cartDataMap['cart_count'] = cartProvider.cartDataMap['cart_count'] - snapshot['products'][index]['quantity'];
                    cartProvider.cartDataMap['products'].removeAt(index);
                  });
                  cartProvider.refresh();

                  refreshCartCount();

                  // update cart count state

                  // update cart details
                  // cartProvider.setCartBySellerId(snapshot['seller_uid']);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                  size: 30,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}