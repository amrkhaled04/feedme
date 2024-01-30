
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

import '../screens/checkout/checkout_screen.dart';
import '../services/auth.dart';

class CartProvider with ChangeNotifier {

  Auth authService = Auth();
  User? user = FirebaseAuth.instance.currentUser;

  DocumentSnapshot? cartData;
  DocumentSnapshot? sellerDetails;
  DocumentSnapshot? userData;
  String seller_uid = '';

  Map<String, dynamic> cartDataMap = {};

  bool firstSave = true;

  bool sellerOpen = false;


  setCartDetailsByUid(uid) async {
    print('uid: $uid');
    await authService.carts.where(
        'user_uid', isEqualTo: uid).get().then((value) {
      setCartDetails(value.docs[0]);
    });
  }


  setCartDetails(details) {

    cartData = details;

    // set seller details

    authService.users.doc(cartData!['seller_uid']).get().then((value) {
      setSellerDetails(value);
      notifyListeners();
    });



    if (cartData != null) {
      cartDataMap = cartData?.data() as Map<String, dynamic>;
    }else{
      cartDataMap = {};
    }

    notifyListeners();
  }

  updateCartCountAndTotalPrice(int count, double totalPrice){

    cartData!.reference.update({
      'total_price': totalPrice,
      'cart_count': count,
    });

    print('cart count: ${cartData!['cart_count']}, total price: ${cartData!['total_price']}');
    notifyListeners();
  }

  setSellerDetails(details) {
    sellerDetails = details;
    notifyListeners();
  }

  setUserData(details) {
    userData = details;
    notifyListeners();
  }

  setCartBySellerId(sellerUid){

    if (UserService.guestUser){

      // set to empty document

      cartData = null;
      return;
    }

    seller_uid = sellerUid;

    if (user == null) {
      return;
    }

    authService.carts
        .where('user_uid', isEqualTo: user!.uid)
        .where('seller_uid', isEqualTo: sellerUid)
        .get()
        .then((value) {
          if (value.docs.isNotEmpty) {
            setCartDetails(value.docs[0]);

            cartDataMap = cartData!.data() as Map<String, dynamic>;


          } else {
            setCartDetails(null);

          }
          notifyListeners();
    });

    notifyListeners();
  }

  confirmOrder() async {
    /**
     * 1. Add order to orders collection
     */

    // print all fields of cartData
    print(cartDataMap);

    authService.orders.add({
      'user_uid': cartDataMap['user_uid'],
      // 'cart_uid': cartData!.id,
      'total_price': cartDataMap['total_price'] + shippingCost,
      'delivery_fee': shippingCost,
      'products': cartDataMap['products'],
      'seller_uid': cartDataMap['products'][0]['seller'],
      'payment_method': 'cash on delivery',
      'order_status': 'pending',
      'created_at': DateTime.now(),
      'address': deliveryAddressController.text,
      'seller_name':cartDataMap['seller_name'],
      'buyer_name':cartDataMap['buyer_name'],
      'buyer_mobile':cartDataMap['buyer_mobile'],
      'buyer_loc':cartDataMap['buyer_loc']
    });

    /**
     * 2. Delete cart
     */
    cartDataMap = {};

    // authService.carts.doc(cartData!.id).delete();
    //
    // setCartDetails(null);
    notifyListeners();

  }

  refresh(){
    notifyListeners();
  }

  checkCartForDiffSeller(currentSellerId){
    if(cartData != null){
      if(cartData!['seller_uid'] != currentSellerId){
        setCartDetails(null);
      }
    }
    return cartData!['seller_uid'] != currentSellerId;
  }

  saveCart(){
    if(cartData != null){
      cartData!.reference.update({
        'products': cartDataMap['products'],
        'total_price': cartDataMap['total_price'],
        'cart_count': cartDataMap['cart_count'],
      });
    }else{


    if (firstSave) {
        firstSave = false;
        authService.carts.add({
          'user_uid': user!.uid,
          'seller_uid': seller_uid,
          'products': cartDataMap['products'],
          'total_price': cartDataMap['total_price'],
          'cart_count': cartDataMap['cart_count'],
          'created_at': DateTime.now(),
        }).then((value) {
          setCartDetails(value);
          notifyListeners();
        });
      }
    }
  }

  setSellerOpen(bool value){
    sellerOpen = value;
    notifyListeners();
  }



}









