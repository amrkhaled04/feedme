

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

//the tapped useruid for dashboard to be used for getting token
String userUid = "";
class OrderProvider with ChangeNotifier{

  DocumentSnapshot? orderData;

  setOrderDetails(details){
    userUid = details['user_uid'];
    orderData = details;
    notifyListeners();
  }
}











