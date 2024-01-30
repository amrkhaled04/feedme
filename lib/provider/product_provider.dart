import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';

class ProductProvider with ChangeNotifier {
  Auth authService = Auth();
  DocumentSnapshot? productData;
  DocumentSnapshot? sellerDetails;
  DocumentSnapshot? reviews;
  double avgRating = 0;
  setProductDetails(details) {
    productData = details;


    // Calculate average rating
    var totalRating = 0.0;
    var totalUsers = 0.0;

    authService.reviews.where('seller_uid', isEqualTo: sellerDetails?.id).get().then((value) {
      for (var element in value.docs) {
        totalRating += element['rating'];
        totalUsers += 1;
      }
      avgRating = totalRating / totalUsers;
      if (avgRating.isNaN) {
        avgRating = 0;
      }
      print('avgRating: $avgRating');
      notifyListeners();
    });


    // notifyListeners();

  }

  setSellerDetails(details) {
    sellerDetails = details;
    notifyListeners();
  }

  setReviews(details) {
    reviews = details;
    notifyListeners();
  }
}
