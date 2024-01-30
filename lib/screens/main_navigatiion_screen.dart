import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/home_screen.dart';
import 'package:bechdal_app/screens/post/my_post_screen.dart';
import 'package:bechdal_app/screens/profile_screen.dart';
import 'package:dot_navigation_bar/dot_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/cart_provider.dart';
import '../services/user.dart';
import 'cart/cart_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  static const screenId = 'main_nav_screen';
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  List pages = [
    const HomeScreen(),
    const MyPostScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];
  PageController controller = PageController();
  int _index = 0;
  var cartProvider;

  _bottomNavigationBar() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
        boxShadow:[
          BoxShadow(
            color: Colors.grey.shade100,
            spreadRadius: 4,
            blurRadius: 6
          )
        ]
      ),
      height: MediaQuery.of(context).size.height*0.09,

      child: DotNavigationBar(
        backgroundColor: Colors.white,
        margin: EdgeInsets.zero,
        paddingR: EdgeInsets.zero,
        currentIndex: _index,
        dotIndicatorColor: Colors.transparent,
        enablePaddingAnimation: false,
        enableFloatingNavBar: false,
        onTap: (index) {
          setState(() {
            index != 2?
            !((index==3 || index==1) && UserService.guestUser)?
            _index = index: null:null;
          });
          index == 2 ?Navigator.push(context,MaterialPageRoute(builder: (context) => const CartScreen(),)):
          (index==3 || index==1) && UserService.guestUser? Navigator.pushNamed(context, 'login_screen'):
          controller.jumpToPage(index);
        },
        items: [
          DotNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.only(left: 7),
              child: Icon(
                Icons.home_filled,
                size: 30,
                color: _index == 0 ? '#80cf70'.toColor() : disabledColor,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              child: Icon(
                _index == 1 ? CupertinoIcons.suit_heart_fill : CupertinoIcons.suit_heart,
                color: _index == 1 ? '#80cf70'.toColor() : disabledColor,
                size: 30,
              ),
            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              child: Badge(
                label: Text(
                  '${cartProvider.cartDataMap['cart_count'] ?? 0}',
                  style: TextStyle(
                      fontFamily: 'Lato',
                      color: _index == 2 ? whiteColor : blackColor),
                ),
                backgroundColor: _index == 2 ? '#80cf70'.toColor() : whiteColor,
                child: Icon(
                  Icons.shopping_bag_rounded,
                  color: _index == 2 ? secondaryColor : disabledColor,
                  size: 30,
                ),
              )

            ),
          ),
          DotNavigationBarItem(
            icon: Container(
              padding: const EdgeInsets.only(right: 7),
              child: Icon(
                Icons.person_rounded,
                color: _index == 3 ? '#80cf70'.toColor() : disabledColor,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    cartProvider = Provider.of<CartProvider>(context, listen: true);

    return Scaffold(
        extendBody: true,
        body: PageView.builder(
          physics: const NeverScrollableScrollPhysics(),
            itemCount: pages.length,
            controller: controller,
            onPageChanged: (page) {
              setState(() {
                _index = page;
              });
            },
            itemBuilder: (context, position) {
              return pages[position];
            }),
        bottomNavigationBar: _bottomNavigationBar());
  }
}
