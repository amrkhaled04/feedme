import 'dart:async';

import 'package:bechdal_app/components/main_appbar_with_search.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/auth/login_screen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cherry_toast/cherry_toast.dart';
import 'package:cherry_toast/resources/arrays.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'dart:ui' as ui;
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/screens/chat/user_chat_screen.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart' as launcher;
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/widgets.dart';
import '../../l10n/locale_keys.g.dart';
import '../../provider/cart_provider.dart';
import '../seller_profile/seller_profile_screen.dart';

class ProductDetail extends StatefulWidget {
  static const screenId = 'product_details_screen';
  const ProductDetail({Key? key}) : super(key: key);

  @override
  State<ProductDetail> createState() => _ProductDetailState();
}
var data;
class _ProductDetailState extends State<ProductDetail> {
  late GoogleMapController _mapController;

  Auth authService = Auth();
  UserService firebaseUser = UserService();
  bool _loading = true;
  final int _index = 0;
  bool isLiked = false;
  List fav = [];

  @override
  void initState() {
    Timer(const Duration(seconds: 2), () {
      setState(() {
        _loading = false;
      });
    });
    super.initState();
  }

  addToCart(CartProvider cartProvider) async {
    /*
      * 1. Get the product id
      * 2. Get the product details
      * Get cart of the current user
      * if user does not have a cart, then create a cart
      * Check if the product is already in the cart
      * If yes, then update the quantity
      * If no, then add the product to the cart
      *
    */



    final Future<SharedPreferences> prefs0 = SharedPreferences.getInstance();

    final SharedPreferences prefs = await prefs0;

    if (prefs.getBool('guest') == true) {
      // pop everything from navigator

      Navigator.popUntil(context, (route) => route.isFirst);

      Navigator.pushNamed(context, LoginScreen.screenId);
      return;
    }




    var productProvider = Provider.of<ProductProvider>(context, listen: false);





    var product = productProvider.productData;


    // check if there already existes a cart for another seller

    // if (cartProvider.cartData != null) {
    //   if (cartProvider.cartData!['seller_uid'] != product!['seller_uid']) {
    //     customOkCancelDialogBox(
    //         context: context,
    //         title: LocaleKeys.createNewCart.tr(),
    //         content: LocaleKeys.clearCart.tr() + cartProvider.sellerDetails!['name'],
    //         onPressed: () {
    //           // delete cart
    //
    //           authService.carts
    //               .doc(cartProvider.cartData!.id)
    //               .delete()
    //               .then((value) {
    //             cartProvider.setCartDetails(null);
    //             cartProvider.updateCartCountAndTotalPrice(0, 0);
    //           }).catchError((error) {
    //             customSnackBar(
    //               context: context,
    //               content: LocaleKeys.somethingWentWrong.tr(),
    //             );
    //           });
    //         });
    //     return;
    //   }
    // }

    Map<String, dynamic> cart = cartProvider.cartDataMap;
    // await authService.carts
    //     .where('user_uid', isEqualTo: firebaseUser.user!.uid)
    //     .where('seller_uid', isEqualTo: product!['seller_uid'])
    //     .get();
    if (cart.isEmpty ) {
      // Create a cart
      Map<String, dynamic> cartData = {
        'user_uid': firebaseUser.user!.uid,
        'products': [
          {
            'product_id': product!.id,
            'quantity': 1,
            'product_img': product['images'][0],
            'price': product['price'],
            'title': product['title'],
            'seller': product['seller_uid'],
          }
        ],
        "seller_uid": product['seller_uid'],
        'total_price': double.parse(product['price']),
        'created_at': DateTime.now().microsecondsSinceEpoch,
        'cart_count': 1,
        'seller_name':product['seller_name'],
        'buyer_name': buyerName,
        'buyer_mobile': buyerMobile,
        'buyer_loc': buyerLoc
      };

      // add cart to cartDataMap

      cartProvider.cartDataMap = cartData;
      cartProvider.refresh();

      cartProvider.cartData?.reference.set(cartData).then((value) {
        // update cart provider

        cartProvider.updateCartCountAndTotalPrice(1, double.parse(product['price']));
        // customSnackBar(
        //   context: context,
        //   content: LocaleKeys.addedToCart.tr(),
        // );
        cartProvider.refresh();
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pushNamed(context, SellerProfileScreen.screenId);
      }).catchError((error) {
        customSnackBar(
            context: context,
            content: LocaleKeys.somethingWentWrong.tr());
      });
    } else {
      // Check if the product is already in the cart
      var productInCart = cart['products'].where((element) {
        return element['product_id'] == product!.id;
      });

      Map<String, dynamic> cartData;
      if (productInCart.length == 0) {
        // Add the product to the cart
        cartData = {
          'product_id': product?.id,
          'quantity': 1,
          'product_img': product?['images'][0],
          'price': product?['price'],
          'title': product?['title'],
          'seller': product?['seller_uid'],
        };

        cart['products'].add(cartData);
        cart['cart_count'] = cart['cart_count'] + 1;
        cart['total_price'] =
            cart['total_price'] + double.parse(product?['price']);

        // cart.reference.update({
        //   'products': FieldValue.arrayUnion([cartData]),
        //   'cart_count': FieldValue.increment(1),
        //   'total_price': FieldValue.increment(double.parse(product?['price'])),
        // }).then((value) {
        //   // update cart provider
        //
        //   cartProvider.updateCartCountAndTotalPrice(cart['cart_count']+1, cart['total_price']+double.parse(product?['price']));
        //   customSnackBar(
        //     context: context,
        //     content: LocaleKeys.addedToCart.tr(),
        //   );
        //   Navigator.pop(context);
        //   Navigator.pop(context);
        //   Navigator.pushNamed(context, SellerProfileScreen.screenId);
        // }).catchError((error) {
        //   customSnackBar(
        //     context: context,
        //     content: LocaleKeys.somethingWentWrong.tr(),
        //   );
        // });
      } else {
        // Update the quantity
        cartData = {
          'product_id': product?.id,
          'quantity': productInCart.first['quantity'] + 1,
          'product_img': product?['images'][0],
          'price': product?['price'],
          'title': product?['title'],
          'seller': product?['seller_uid'],
        };

        cart['cart_count'] = cart['cart_count'] + 1;
        cart['total_price'] =
            cart['total_price'] + double.parse(product?['price']);

        cart['products'].remove(productInCart.first);
        cart['products'].add(cartData);

        // remove the product from the cart
        // cart.reference.update({
        //   'products': FieldValue.arrayRemove([productInCart.first]),
        //
        // }).then((value) {
        //   // add the product to the cart
        //   cart.reference.update({
        //     'products': FieldValue.arrayUnion([cartData]),
        //     'cart_count': FieldValue.increment(1),
        //     'total_price': FieldValue.increment(double.parse(product?['price'])),
        //   }).then((value) {
        //     // update cart provider
        //     cartProvider.setCartDetails(cart);
        //     cartProvider.updateCartCountAndTotalPrice(cart['cart_count']+1, cart['total_price']+double.parse(product?['price']));
        //     customSnackBar(
        //       context: context,
        //       content: LocaleKeys.addedToCart.tr(),
        //     );
        //
        //     Navigator.pop(context);
        //     Navigator.pop(context);
        //     Navigator.pushNamed(context, SellerProfileScreen.screenId);
        //
        //
        //   }).catchError((error) {
        //     customSnackBar(
        //       context: context,
        //       content: LocaleKeys.somethingWentWrong.tr(),
        //     );
        //   });
        // }).catchError((error) {
        //   customSnackBar(
        //     context: context,
        //     content: LocaleKeys.somethingWentWrong.tr(),
        //   );
        // });
        cartProvider.refresh();
      }

    }

    CherryToast.success(
            animationDuration: const Duration(milliseconds: 800),
            toastDuration: const Duration(milliseconds: 1250),
            toastPosition: Position.top,
            title: Text(LocaleKeys.addedToCart.tr(),
                style: const TextStyle(color: Colors.black)))
        .show(context);

    Navigator.pop(context);
    Navigator.pop(context);
    Navigator.pushNamed(context, SellerProfileScreen.screenId);
  }

  getReviews() async {
    var productProvider = Provider.of<ProductProvider>(context, listen: false);
    var reviews = await authService.reviews
        .where('seller_uid', isEqualTo: productProvider.sellerDetails!['uid'])
        .get();
    if (reviews.docs.isNotEmpty) {
      productProvider.setReviews(reviews.docs);
    }
  }

  getFavourites({required ProductProvider productProvider}) {
    authService.products
        .doc(productProvider.productData!.id)
        .get()
        .then((value) {
      if (mounted) {
        setState(() {
          fav = value['favourites'];
        });
      }
      if (fav.contains(firebaseUser.user!.uid)) {
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
  void didChangeDependencies() {
    var productProvider = Provider.of<ProductProvider>(context);
    getFavourites(productProvider: productProvider);
    super.didChangeDependencies();
  }

  _mapLauncher(location) async {
    final availableMaps = await launcher.MapLauncher.installedMaps;
    await availableMaps.first.showMarker(
      coords: launcher.Coords(location.latitude, location.longitude),
      title: "Seller Location is here..",
    );
  }

  Future<void> _callLauncher(number) async {
    if (!await launchUrl(number)) {
      throw 'Could not launch $number';
    }
  }

  _createChatRoom(ProductProvider productProvider) {
    Map product = {
      'product_id': productProvider.productData!.id,
      'product_img': productProvider.productData!['images'][0],
      'price': productProvider.productData!['price'],
      'title': productProvider.productData!['title'],
      'seller': productProvider.productData!['seller_uid'],
    };
    List<String> users = [
      productProvider.sellerDetails!['uid'],
      firebaseUser.user!.uid,
    ];
    String chatroomId =
        '${productProvider.sellerDetails!['uid']}.${firebaseUser.user!.uid}${productProvider.productData!.id}';
    Map<String, dynamic> chatData = {
      'users': users,
      'chatroomId': chatroomId,
      'read': false,
      'product': product,
      'lastChat': null,
      'lastChatTime': DateTime.now().microsecondsSinceEpoch,
    };
    firebaseUser.createChatRoom(data: chatData);
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (builder) => UserChatScreen(
                  chatroomId: chatroomId,
                )));
  }

  reviewsHandling(double rating, {required ProductProvider productProvider}) {
    /*
                                        * Check if user already rated product
                                        * if yes, update rating
                                        * if no add rating
                                        * */

    var ratingData = {
      'user_uid': firebaseUser.user!.uid,
      'rating': rating,
      'seller_uid': productProvider.sellerDetails!['uid'],
    };

    var reviewed = authService.reviews
        .where('user_uid', isEqualTo: firebaseUser.user!.uid)
        .where('seller_uid', isEqualTo: productProvider.sellerDetails!['uid'])
        .get();
    reviewed.then((value) {
      if (value.docs.isEmpty) {
        // Add rating
        authService.reviews.add(ratingData).then((value) {
          customSnackBar(
            context: context,
            content: LocaleKeys.ratingAddedSuccessfully.tr(),
          );
        }).catchError((error) {
          customSnackBar(
            context: context,
            content: LocaleKeys.somethingWentWrong.tr(),
          );
        });
      } else {
        // Update rating
        authService.reviews
            .doc(value.docs[0].id)
            .update(ratingData)
            .then((value) {
          customSnackBar(
            context: context,
            content: LocaleKeys.ratingUpdatedSuccessfully.tr(),
          );
        }).catchError((error) {
          customSnackBar(
            context: context,
            content: LocaleKeys.somethingWentWrong.tr(),
          );
        });
      }
    });
  }

  _body({
    required DocumentSnapshot<dynamic> data,
    required String formattedDate,
    required ProductProvider productProvider,
    required CartProvider cartProvider,
    required String formattedPrice,
    // required GeoPoint location,
    required NumberFormat numberFormat,
    required double avgRating,
  }) {
    print(data.data()?['bathroom']);
    return SingleChildScrollView(
      child: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height*0.39,
                        color: Colors.transparent,
                        child: _loading
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: secondaryColor,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      LocaleKeys.loading.tr(),
                                    )
                                  ],
                                ),
                              )
                            : Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(10)),
                                clipBehavior: Clip.antiAlias,
                                child: CarouselSlider.builder(
                                  itemCount: data['images'].length,
                                  options: CarouselOptions(
                                    enableInfiniteScroll: false,
                                    autoPlayCurve: Curves.fastOutSlowIn,
                                    viewportFraction: 1.07,
                                    enlargeCenterPage: true,
                                    autoPlay: false,
                                    height: MediaQuery.of(context).size.height*0.37,
                                    clipBehavior: Clip.antiAlias,
                                  ),
                                  itemBuilder: (context, index, realIdx) {
                                    return Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      clipBehavior: Clip.antiAlias,
                                      width: MediaQuery.of(context).size.width,
                                      height: MediaQuery.of(context).size.height*0.1,
                                      child: Image.network(
                                        data['images'][index],
                                        fit: BoxFit.fill,
                                        height: 500,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                      ),
                      _loading
                          ? Container()
                          : Container(
                              child: Padding(
                                padding: EdgeInsets.all(MediaQuery.of(context).size.width*0.01),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          data['title'].toUpperCase(),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.023,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 5,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      '${LocaleKeys.currency.tr()} $formattedPrice',
                                      style: TextStyle(
                                        fontFamily: 'Lato',
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.0185,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      LocaleKeys.description.tr(),
                                      style: TextStyle(
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.022,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  data['description'],
                                                  style: TextStyle(
                                                      fontSize:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.022),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                // Container(
                                                //   decoration: BoxDecoration(
                                                //       color: disabledColor
                                                //           .withOpacity(0.3),
                                                //     borderRadius: BorderRadius.circular(7)
                                                //   ),
                                                //   padding: EdgeInsets.symmetric(
                                                //     horizontal: 15,
                                                //     vertical: 10,
                                                //   ),
                                                //   width: MediaQuery.of(context)
                                                //       .size
                                                //       .width,
                                                //
                                                //   child:
                                                //   Text(
                                                //     '${LocaleKeys.postedAt.tr()}: ${formattedDate}',
                                                //     style: TextStyle(
                                                //       color: blackColor,
                                                //       fontSize: MediaQuery.of(context).size.height*0.016
                                                //     ),
                                                //   ),
                                                // ),
                                                Divider(
                                                  color: blackColor,
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                // check of nutrition facts are available
                                                // if yes, then show nutrition facts
                                                // if no, then show nothing
                                                (data.data()['calories'] != null && data['calories'] != "") ? Directionality(
                                                  textDirection: ui.TextDirection.ltr,
                                                  child: PieChart(
                                                    dataMap: { "Calories": double.parse(data['calories'].toString()),
                                                      "Protein": double.parse(data['protein'].toString()),
                                                      "Carb": double.parse(data['carb'].toString()),
                                                      "Fats": double.parse(data['fats'].toString()),},
                                                    animationDuration: const Duration(milliseconds: 1050),
                                                    chartLegendSpacing: 50,
                                                    chartRadius: MediaQuery.of(context).size.width / 3.2,
                                                    colorList: const [
                                                      Color(0xfffdcb6e),
                                                      Color(0xff0984e3),
                                                      Color(0xfffd79a8),
                                                      Color(0xffe17055),
                                                      Color(0xff6c5ce7),
                                                    ],
                                                    initialAngleInDegree: 0,
                                                    chartType: ChartType.ring,
                                                    ringStrokeWidth: 16,
                                                    centerText: "Nutrients",
                                                    legendOptions: const LegendOptions(
                                                      showLegendsInRow: false,
                                                      legendPosition: LegendPosition.right,
                                                      showLegends: true,
                                                      legendShape: BoxShape.circle,
                                                      legendTextStyle: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    chartValuesOptions: ChartValuesOptions(
                                                      chartValueStyle: TextStyle(
                                                          fontSize: 14,
                                                          color: blackColor,
                                                          fontWeight: FontWeight.bold
                                                      ),
                                                      showChartValueBackground:false ,
                                                      showChartValues: true,
                                                      showChartValuesInPercentage: false,
                                                      showChartValuesOutside: true,
                                                      decimalPlaces: 1,
                                                    ),
                                                    // gradientList: ---To add gradient colors---
                                                    // emptyColorGradient: ---Empty Color gradient---
                                                  ),
                                                ) : Container(
                                                  child: Text(
                                                    LocaleKeys.noNutritionFacts.tr(),
                                                    style: TextStyle(
                                                        fontSize: MediaQuery.of(context).size.height*0.018
                                                    ),
                                                  ),
                                                ),

                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: blackColor,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        addToCart(cartProvider);
                                      },
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.grey.shade200,
                                        backgroundColor: '#80cf70'.toColor(),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        fixedSize: Size(
                                            MediaQuery.of(context).size.width -
                                                20,
                                            MediaQuery.of(context).size.height*0.065),
                                        minimumSize: Size(
                                            MediaQuery.of(context).size.width -
                                                20,
                                            25),
                                      ),
                                      child: Text(LocaleKeys.addToCart.tr(),style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.height * 0.022
                                      ),),
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 30,
                                          backgroundColor: Colors.transparent,
                                          foregroundImage: (productProvider.sellerDetails != null && (productProvider.sellerDetails?.data() as Map<String,dynamic>).containsKey('profile_picture'))
                                              ? NetworkImage(
                                              productProvider.sellerDetails![
                                              'profile_picture'])
                                              : const AssetImage(
                                              'assets/avatar.png'
                                          )
                                                  as ImageProvider,
                                        ),
                                        Expanded(
                                          child: ListTile(
                                            title: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(left:MediaQuery.of(context).size.width*0.005),
                                                  child: Text(
                                                    productProvider
                                                        .sellerDetails!['name']
                                                        .toUpperCase(),
                                                    style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: MediaQuery.of(context).size.height*0.019,
                                                        overflow:
                                                            TextOverflow.ellipsis),
                                                  ),
                                                ),
                                                ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pushNamed(
                                                          context,
                                                          SellerProfileScreen
                                                              .screenId,
                                                          arguments: {
                                                            'seller_uid':
                                                            productProvider
                                                                .sellerDetails![
                                                            'uid']
                                                          });
                                                      cartProvider.setCartBySellerId(
                                                          productProvider
                                                              .sellerDetails![
                                                          'uid']);
                                                    },
                                                    style:
                                                    ElevatedButton.styleFrom(
                                                      backgroundColor: Colors.transparent,
                                                      shadowColor:
                                                      Colors.transparent,
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Text(
                                                          LocaleKeys.viewProfile.tr(),
                                                          style: TextStyle(
                                                            fontSize: MediaQuery.of(context).size.height*0.018,
                                                            color: disabledColor.withOpacity(0.9),
                                                            fontWeight:
                                                            FontWeight.bold,
                                                          ),
                                                        ),
                                                        Icon(
                                                          Icons.arrow_forward_ios,
                                                          size: MediaQuery.of(context).size.height*0.018,
                                                          color: disabledColor.withOpacity(0.9),
                                                        ),
                                                      ],
                                                    )),

                                              ],
                                            ),
                                            subtitle: RatingBar.builder(
                                              initialRating:
                                                  productProvider.avgRating,
                                              itemSize: 25,
                                              minRating: 1,
                                              direction: Axis.horizontal,
                                              allowHalfRating: true,
                                              itemCount: 5,
                                              itemPadding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4.0),
                                              itemBuilder: (context, _) =>
                                                  const Icon(
                                                Icons.star,
                                                color: Colors.amber,
                                              ),
                                              onRatingUpdate: (rating) {
                                                reviewsHandling(rating,
                                                    productProvider:
                                                        productProvider);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Divider(
                                      color: blackColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // _bottomSheet({required ProductProvider productProvider}) {
  //   return BottomAppBar(
  //     child: Padding(
  //       padding: (productProvider.productData!['seller_uid'] ==
  //               firebaseUser.user!.uid)
  //           ? EdgeInsets.zero
  //           : EdgeInsets.all(16),
  //       child: (productProvider.productData!['seller_uid'] ==
  //               firebaseUser.user!.uid)
  //           ? null
  //           : Row(children: [
  //               Expanded(
  //                 child: ElevatedButton(
  //                     style: ButtonStyle(
  //                         backgroundColor:
  //                             MaterialStateProperty.all(secondaryColor)),
  //                     onPressed: () {
  //                       _createChatRoom(productProvider);
  //                     },
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(10),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Icon(
  //                             Icons.chat_bubble,
  //                             size: 16,
  //                             color: whiteColor,
  //                           ),
  //                           SizedBox(
  //                             width: 10,
  //                           ),
  //                           Text(
  //                             'Chat',
  //                           )
  //                         ],
  //                       ),
  //                     )),
  //               ),
  //               SizedBox(
  //                 width: 20,
  //               ),
  //               Expanded(
  //                 child: ElevatedButton(
  //                     style: ButtonStyle(
  //                         backgroundColor:
  //                             MaterialStateProperty.all(secondaryColor)),
  //                     onPressed: () async {
  //                       var phoneNo = Uri.parse(
  //                           'tel:${productProvider.sellerDetails!['mobile']}');
  //                       await _callLauncher(phoneNo);
  //                     },
  //                     child: Padding(
  //                       padding: const EdgeInsets.all(10),
  //                       child: Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         mainAxisAlignment: MainAxisAlignment.center,
  //                         children: [
  //                           Icon(
  //                             Icons.call,
  //                             size: 16,
  //                             color: whiteColor,
  //                           ),
  //                           SizedBox(
  //                             width: 10,
  //                           ),
  //                           Text(
  //                             'Call',
  //                           )
  //                         ],
  //                       ),
  //                     )),
  //               )
  //             ]),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);
    var cartProvider = Provider.of<CartProvider>(context);
    final numberFormat = NumberFormat('##,##,###.#');
    // assigned to global variable to be used in delivery fee
    data = productProvider.productData;
    var price = double.parse(data!['price']);
    var formattedPrice = numberFormat.format(price);
    var date = DateTime.fromMicrosecondsSinceEpoch(data['posted_at']);
    var formattedDate = DateFormat.yMMMd().format(date);
    var rating = productProvider.avgRating;



    // GeoPoint _location = productProvider.sellerDetails!['location'];
    return Scaffold(
      backgroundColor: '#f9fcf7'.toColor(),
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
          LocaleKeys.productDetails.tr(),
          style: TextStyle(
              color: Colors.grey.shade200,
              fontSize: MediaQuery.of(context).size.height * 0.04),
        ),
        actions: [

          IconButton(
              iconSize: MediaQuery.of(context).size.height * 0.04,
              onPressed: () {
                setState(() {
                  isLiked = !isLiked;
                });
                firebaseUser.updateFavourite(
                  context: context,
                  isLiked: isLiked,
                  productId: data.id,
                );
              },
              color: Colors.grey.shade200,
              icon: Icon(
                isLiked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              ))
        ],
      ),
      body: _body(
          data: data,
          formattedDate: formattedDate,
          productProvider: productProvider,
          cartProvider: cartProvider,
          formattedPrice: formattedPrice,
          // location: _location,
          numberFormat: numberFormat,
          avgRating: rating),
      // bottomSheet: _loading
      //     ? SizedBox()
      //     : _bottomSheet(productProvider: productProvider)
    );
  }
}
