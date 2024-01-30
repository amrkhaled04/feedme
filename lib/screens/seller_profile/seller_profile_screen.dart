

import 'package:bechdal_app/extensions.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/locale_keys.g.dart';
import '../../provider/cart_provider.dart';
import '../../provider/product_provider.dart';
import '../../services/auth.dart';
import '../../services/user.dart';
import '../product/product_details_screen.dart';

class SellerProfileScreen extends StatefulWidget {
  static const screenId = 'seller_profile_screen';




  const SellerProfileScreen({Key? key}) : super(key: key);




  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}



class _SellerProfileScreenState extends State<SellerProfileScreen> {




  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);
    var cartProvider = Provider.of<CartProvider>(context, listen: true);



    Auth auth = Auth();
    UserService firebaseUser = UserService();




    return Scaffold(
      backgroundColor: '#f9fcf7'.toColor(),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height*0.08,
        title: Text(
          LocaleKeys.sellerProfile.tr(),
          style: TextStyle(color: Colors.grey.shade200,fontSize: MediaQuery.of(context).size.width*0.08),
        ),

        backgroundColor: '#80cf70'.toColor(),
        elevation: 0.5,
        // make back button black
        iconTheme: IconThemeData(
          size: MediaQuery.of(context).size.height*0.04,
            color: Colors.grey.shade200
        ),
      ),
      body: FutureBuilder(

          future: auth.products
              .where('seller_uid', isEqualTo: productProvider.sellerDetails!['uid'])
              .orderBy('favourite_count', descending: true)
              .get(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(LocaleKeys.somethingWentWrong.tr()),
              );
            }
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data.docs.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    productProvider.setProductDetails(snapshot.data.docs[index]);
                    Navigator.pushNamed(
                        context, ProductDetail.screenId);
                  },
                  child: Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: NetworkImage(snapshot.data.docs[index]
                                ['images'][0]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          snapshot.data.docs[index]['title'],
                          style: TextStyle(
                            fontSize: MediaQuery.of(context).size.width*0.043,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${LocaleKeys.currency.tr()} ${snapshot.data.docs[index]['price']}',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: MediaQuery.of(context).size.width*0.037,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );


          }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.95,
        height: 60,


        child: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, 'cart_screen');
          },
          backgroundColor: '#80cf70'.toColor(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 10,
              ),

              Icon(
                Icons.shopping_bag_rounded,
                color: Colors.white,
                size: MediaQuery.of(context).size.width*0.06,
              ),
               Text(
                  " ${LocaleKeys.cart.tr()} ",
                  style: TextStyle(
                    fontSize: MediaQuery.of(context).size.width*0.05,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  )

              ),
              Padding(
                padding: const EdgeInsets.only(left: 5.0,top: 4),
                child: Text(
                  '${cartProvider.cartDataMap.isNotEmpty ? cartProvider.cartDataMap['cart_count'] : 0}',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: MediaQuery.of(context).size.width*0.035,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,

                    background: Paint()
                      ..color = Colors.white30.withOpacity(0.2)
                      ..strokeWidth = 4
                      ..strokeJoin = StrokeJoin.round
                      ..strokeCap = StrokeCap.butt
                      ..style = PaintingStyle.stroke




                  )
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(right: 17.0),
                child: Text(
                  '${LocaleKeys.currency.tr()} ${cartProvider.cartDataMap.isNotEmpty ? cartProvider.cartDataMap['total_price'] : 0}',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: MediaQuery.of(context).size.width*0.042,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

            ],
          )

        ),
      ),
    );

  }
}



















