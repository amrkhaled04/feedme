



import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/seller_profile/seller_profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';

import '../../l10n/locale_keys.g.dart';
import '../../provider/cart_provider.dart';
import '../../provider/product_provider.dart';
import '../../services/auth.dart';
import '../../services/user.dart';

class ProfileCard extends StatefulWidget {
  const ProfileCard({Key? key,required this.data}) : super(key: key);

  final QueryDocumentSnapshot<Object?> data;

  @override
  State<ProfileCard> createState() => _ProfileCardState(data:data);
}
String companyImage = "";


class _ProfileCardState extends State<ProfileCard> {
  _ProfileCardState({required this.data});

  final QueryDocumentSnapshot<Object?> data;

  double rating = 0;
  Auth authService = Auth();
  UserService firebaseUser = UserService();

  bool isOpen = false;

  DocumentSnapshot? sellerDetails;

  @override
  void initState() {
    getSellerData();
    getRating();
    getStatus();
    super.initState();
  }

  getStatus(){
    authService.companies.where("__name__",isEqualTo: widget.data['uid']).get().then((value) {
      if(value.docs.isNotEmpty){
        if(value.docs[0]['open'] == true){
          setState(() {
            isOpen = true;
          });
        }
      }
    });
  }

  getSellerData() {
    firebaseUser.getSellerData(widget.data['uid']).then((value) {
      if (mounted) {
        setState(() {

          sellerDetails = value;
        });
      }
    });
  }

  getRating(){
    authService.reviews.where('seller_uid',isEqualTo: widget.data['uid']).get().then((value) {
      if (mounted) {
        setState(() {
          rating = 0;
          for (var i = 0; i < value.docs.length; i++) {
            rating += double.parse(value.docs[i]['rating'].toString());
          }
          rating = rating / value.docs.length;
        });
      }
    });
  }

  getProfileImage() {

    if (sellerDetails == null) {
      return Image.asset(
        'assets/avatar.png',
        fit: BoxFit.fill,
      );
    } else {

      if ((sellerDetails!.data() as Map).containsKey('profile_picture') &&
          (sellerDetails!.data() as Map)['profile_picture'] != null && (sellerDetails!.data() as Map)['profile_picture'] != '') {
        companyImage = (sellerDetails!.data() as Map)['profile_picture'].toString();
        return Image.network(
          (sellerDetails!.data() as Map)['profile_picture'].toString(),
          fit: BoxFit.fill,
        );
      } else {
        return Image.asset(
          'assets/avatar.png',
          fit: BoxFit.fill,
        );
      }
    }

  }



  @override
  Widget build(BuildContext context) {
    var productProvider = Provider.of<ProductProvider>(context);
    var cartProvider = Provider.of<CartProvider>(context);

    return InkWell(
      onTap: () {

        // check if seller id is the same as doc id in companies table



        productProvider.setSellerDetails(sellerDetails);
        productProvider.setProductDetails(widget.data);
        // cartProvider.setCartBySellerId(widget.data['uid']);
        cartProvider.setSellerOpen(isOpen);
        Navigator.pushNamed(context, SellerProfileScreen.screenId);



      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        shadowColor: '#e6eedf'.toColor(),
        color: (isOpen)?'#ffffff'.toColor(): Colors.black12,
        elevation: 2,
        child: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      alignment: Alignment.center,
                      height: MediaQuery.of(context).size.height*0.11,
                      child: ClipRRect(
                        clipBehavior: Clip.antiAlias,
                        borderRadius: BorderRadius.circular(7),
                        child: getProfileImage(),
                      )),
                  Center(
                    child: Text(
                      widget.data['name'],
                      style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height*0.024),
                    ),
                  ),

                  Center(
                    child: RatingBar.builder(
                      initialRating: rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 20,
                      itemPadding: const EdgeInsets.symmetric(horizontal: 0),
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                      ignoreGestures: true,
                    ),
                  ),



                ],
              ),
              Text(
                (isOpen)?'':LocaleKeys.closedLabel.tr(),

                style: TextStyle(
                    color: Colors.black54,
                    fontSize: MediaQuery.of(context).size.height*0.03,
                    fontWeight: FontWeight.bold),

              ),

            ],
          ),
        ),
      ),
    );
  }
}