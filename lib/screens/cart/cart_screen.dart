import 'package:auto_size_text/auto_size_text.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/l10n/locale_keys.g.dart';
import 'package:bechdal_app/screens/cart/cart_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../provider/cart_provider.dart';
import '../../services/auth.dart';
import '../../services/user.dart';


class CartScreen extends StatefulWidget {
  static const screenId = 'cart_screen';
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {

  Auth authService = Auth();
  UserService firebaseUser = UserService();
  CollectionReference companies = FirebaseFirestore.instance.collection('companies');

  var cartProvider;
  int cartCount = 0;

  void getCartCount() async {
    setState(() {
      cartCount -= cartCount;

      cartProvider.refresh();



    });
  }

  @override
  Widget build(BuildContext context) {

    cartProvider = Provider.of<CartProvider>(context, listen: false);

    // getCartCount();




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
            LocaleKeys.cart.tr(),
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
      body:

            (cartProvider.cartDataMap.isEmpty || cartProvider.cartDataMap['cart_count'] == 0) ?
                 Center(
                  child: Column(
                      children: [
                        const Spacer(flex: 1,),
                        Image.asset("assets/EmptyCartState.png",width: MediaQuery.of(context).size.height*0.35),
                        Text(LocaleKeys.emptyCart.tr(),
                            style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: MediaQuery.of(context).size.height*0.02),
                            textAlign: TextAlign.center,maxLines: 3),
                        const Spacer(flex: 4,)
                      ]
                  )
                )
              :
               Column(
                 children: [
                   Expanded(
                     child: ListView.builder(
                          itemCount: cartProvider.cartDataMap['products'] == null?0 :cartProvider.cartDataMap['products'].length,
                          itemBuilder: (BuildContext context, int index) {
                            return CartItem(authService: authService, firebaseUser: firebaseUser, index: index, snapshot: cartProvider.cartDataMap, refreshCartCount: getCartCount,);
                          },
                        ),
                   ),
                   Container(
                     margin: const EdgeInsets.all(10),
                     padding: const EdgeInsets.all(10),
                     decoration: BoxDecoration(
                       color: (cartProvider.sellerOpen) ? whiteColor : Colors.grey[300],
                       borderRadius: BorderRadius.circular(10),
                       boxShadow: [
                         BoxShadow(
                           color: Colors.grey.withOpacity(0.5),
                           spreadRadius: 1,
                           blurRadius: 5,
                           offset: const Offset(0, 3),
                         ),
                       ],
                     ),
                     child: Row(

                       children: [
                         Expanded(
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Text(
                                 LocaleKeys.totalPrice.tr(),
                                 style: const TextStyle(
                                   fontSize: 20,
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                               const SizedBox(
                                 height: 10,
                               ),
                               Text(
                                 '${LocaleKeys.currency.tr()} ${cartProvider.cartDataMap['total_price']}',
                                 style: const TextStyle(
                                   fontSize: 16,
                                   fontFamily: 'Lato',
                                   fontWeight: FontWeight.bold,
                                 ),
                               ),
                             ],
                           ),
                         ),
                         ElevatedButton(
                           onPressed: () {
                             if (!cartProvider.sellerOpen){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(LocaleKeys.closed.tr()),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                                return;
                             }
                             Navigator.pushNamed(context, 'checkout_screen');
                           },
                           style: ElevatedButton.styleFrom(
                               backgroundColor: '#80cf70'.toColor() ,
                               shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(8)
                               ),
                               minimumSize: Size(MediaQuery.of(context).size.width*0.5, MediaQuery.of(context).size.height*0.065)
                           ),
                           child: Text(LocaleKeys.checkout.tr(),style: TextStyle(
                               color: Colors.grey.shade200,
                               fontSize:MediaQuery.of(context).size.width*0.055 ),),
                         )
                       ],
                     ),
                   )
                 ],
               )













    );

  }
}

bodyWidget({required Auth authService, required UserService firebaseUser}) {



  return FutureBuilder(
    future: authService.carts
        .where('user_uid', isEqualTo: firebaseUser.user!.uid)
        .get(),
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
      if (snapshot.data.docs.length == 0) {
        return Center(
          child: Text(LocaleKeys.noItemsInCart.tr()),
        );
      }
      return ListView.builder(
        itemCount: snapshot.data.docs[0]['products'].length,
        itemBuilder: (BuildContext context, int index) {
          return FutureBuilder(
            future: firebaseUser.getProductDetails(
                snapshot.data.docs[0]['products'][index]['product_id']),
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
                      blurRadius: 5,
                      offset: const Offset(0, 3),
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
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            '${LocaleKeys.currency.tr()} ${productSnapshot.data['price']}',
                            style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            LocaleKeys.quantity.tr(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          Text(
                            '${snapshot.data.docs[0]['products'][index]['quantity']}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        // delete product from cart
                        authService.carts
                            .doc(snapshot.data.docs[0].id)
                            .update({
                          'products': FieldValue.arrayRemove([
                            snapshot.data.docs[0]['products'][index]
                          ])
                        });

                        // update total price

                        authService.carts
                            .doc(snapshot.data.docs[0].id)
                            .update({
                          'total_price': FieldValue.increment(
                              -snapshot.data.docs[0]['products'][index]
                                  ['total_price'])
                        });













                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
    },
  );
}




  );
}
