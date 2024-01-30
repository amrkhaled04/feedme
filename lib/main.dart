import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/forms/common_form.dart';
import 'package:bechdal_app/forms/sell_car_form.dart';
import 'package:bechdal_app/forms/user_form_review.dart';
import 'package:bechdal_app/provider/cart_provider.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/provider/order_provider.dart';
import 'package:bechdal_app/provider/product_provider.dart';
import 'package:bechdal_app/screens/auth/email_verify_screen.dart';
import 'package:bechdal_app/screens/auth/login_screen.dart';
import 'package:bechdal_app/screens/auth/phone_auth_screen.dart';
import 'package:bechdal_app/screens/auth/phone_otp_screen.dart';
import 'package:bechdal_app/screens/auth/register_screen.dart';
import 'package:bechdal_app/screens/cart/cart_screen.dart';
import 'package:bechdal_app/screens/category/product_by_category_screen.dart';
import 'package:bechdal_app/screens/category/subcategory_screen.dart';
import 'package:bechdal_app/screens/chat/user_chat_screen.dart';
import 'package:bechdal_app/screens/checkout/checkout_screen.dart';
import 'package:bechdal_app/screens/checkout_lottie.dart';
import 'package:bechdal_app/screens/error_widget.dart';
import 'package:bechdal_app/screens/home_screen.dart';
import 'package:bechdal_app/screens/location_screen.dart';
import 'package:bechdal_app/screens/main_navigatiion_screen.dart';
import 'package:bechdal_app/screens/orders/past_order_details.dart';
import 'package:bechdal_app/screens/orders/past_orders_screen.dart';
import 'package:bechdal_app/screens/orders/received_orders_screen.dart';
import 'package:bechdal_app/screens/post/my_post_screen.dart';
import 'package:bechdal_app/screens/product/product_details_screen.dart';
import 'package:bechdal_app/screens/profile_screen.dart';
import 'package:bechdal_app/screens/seller_profile/seller_profile_screen.dart';
import 'package:bechdal_app/screens/splash_screen.dart';
import 'package:bechdal_app/screens/welcome_screen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'l10n/locale_keys.g.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/category/category_list_screen.dart';
import 'screens/chat/chat_screen.dart';
import 'package:easy_localization/easy_localization.dart';

void main() async {
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   FlutterError.dumpErrorToConsole(details);
  //   runApp(ErrorWidgetClass(details));
  // };


  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    webRecaptchaSiteKey: 'recaptcha-v3-site-key',
  );
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider(
            create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider(
            create: (_) => OrderProvider(),
        )
      ],
      child: EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          child: Main()
      ),
    ),
  );
}

class ErrorWidgetClass extends StatelessWidget {
  final FlutterErrorDetails errorDetails;
  const ErrorWidgetClass(this.errorDetails, {Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomErrorWidget(
      errorMessage: errorDetails.exceptionAsString(),
    );
  }
}

void setErrorBuilder() {
  ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
    return const Scaffold(
        body: Center(
            child: Text("Unexpected error. See console for details.")));
  };
}

class Main extends StatelessWidget with WidgetsBindingObserver {
  Main({Key? key}) : super(key: key);
  var cartProvider = CartProvider();



  @override
  Widget build(BuildContext context) {
    // setErrorBuilder();
    WidgetsBinding.instance.addObserver(this);
    cartProvider = Provider.of<CartProvider>(context, listen: true);

    return MaterialApp(
        theme: ThemeData(
          useMaterial3: false,
          primaryColor: blackColor,
          fontFamily: 'Alegreya',
          scaffoldBackgroundColor: whiteColor, //colorScheme: ColorScheme(background: whiteColor),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: SplashScreen.screenId,
        localizationsDelegates:context.localizationDelegates ,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routes: {
          SplashScreen.screenId: (context) => const SplashScreen(),
          LoginScreen.screenId: (context) => const LoginScreen(),
          // PhoneAuthScreen.screenId: (context) => const PhoneAuthScreen(),
          LocationScreen.screenId: (context) => const LocationScreen(),
          HomeScreen.screenId: (context) => const HomeScreen(),
          WelcomeScreen.screenId: (context) => WelcomeScreen(),
          RegisterScreen.screenId: (context) => const RegisterScreen(),
          // EmailVerifyScreen.screenId: (context) => const EmailVerifyScreen(),
          ResetPasswordScreen.screenId: (context) =>
              const ResetPasswordScreen(),
          CategoryListScreen.screenId: (context) => const CategoryListScreen(),
          SubCategoryScreen.screenId: (context) => const SubCategoryScreen(),
          MainNavigationScreen.screenId: (context) =>
              const MainNavigationScreen(),
          // ChatScreen.screenId: (context) => const ChatScreen(),
          MyPostScreen.screenId: (context) => const MyPostScreen(),
          ProfileScreen.screenId: (context) => const ProfileScreen(),
          SellCarForm.screenId: (context) => const SellCarForm(),
          UserFormReview.screenId: (context) => const UserFormReview(),
          CommonForm.screenId: (context) => const CommonForm(),
          ProductDetail.screenId: (context) => const ProductDetail(),
          ProductByCategory.screenId: (context) => const ProductByCategory(),
          CartScreen.screenId: (context) => const CartScreen(),
          CheckoutScreen.screenId: (context) => const CheckoutScreen(),
          PastOrdersScreen.screenId: (context) => const PastOrdersScreen(),
          SellerProfileScreen.screenId: (context) => const SellerProfileScreen(),
          PastOrderDetails.screenId: (context) => const PastOrderDetails(),
          ReceivedOrdersScreen.screenId: (context) => const ReceivedOrdersScreen(),
          Checkout.screenId: (context) => const Checkout(),
          // UserChatScreen.screenId: (context) => const UserChatScreen(),
        });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        print('Back to app');
        break;
      case AppLifecycleState.paused:
        // cartProvider.saveCart();
        break;
    }
  }
}
