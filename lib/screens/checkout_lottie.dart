import 'package:bechdal_app/screens/main_navigatiion_screen.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Checkout extends StatefulWidget {
  static const screenId = 'checkout_lottie';
  const Checkout({Key? key}) : super(key: key);


  @override
  State<Checkout> createState() => _CheckoutState();
}


class _CheckoutState extends State<Checkout> {
  @override
  void initState(){

    Future.delayed(const Duration(milliseconds: 6000),() {
    Navigator.of(context).pushNamedAndRemoveUntil(MainNavigationScreen.screenId, (route) => false);
    },);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Lottie.asset(
          "assets/lottie/confirm_order.json",fit: BoxFit.fill,height: MediaQuery.of(context).size.height*0.5,
          width: MediaQuery.of(context).size.width),
    );
  }
}



