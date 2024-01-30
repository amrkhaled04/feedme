
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/category/category_widget.dart';
import 'package:bechdal_app/components/main_appbar_with_search.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/screens/seller_profile/profile_listing.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:bechdal_app/utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_keys.g.dart';
import '../provider/cart_provider.dart';

class HomeScreen extends StatefulWidget {
  static const String screenId = 'home_screen';
  const HomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController searchController;
  late CarouselController _controller;
  final int _current = 0;
  late FocusNode searchNode;
  UserService firebaseUser = UserService();
  var cartProvider;


  Future<List<String>> downloadBannerImageUrlList() async {
    List<String> bannerUrlList = [];
    final ListResult storageRef =
        await FirebaseStorage.instance.ref().child('banner').listAll();
    List<Reference> bannerRef = storageRef.items;
    await Future.forEach<Reference>(bannerRef, (image) async {

      final String fileUrl = await image.getDownloadURL();
      bannerUrlList.add(fileUrl);
    });
    return bannerUrlList;
  }

  @override
  void initState() {
    searchController = TextEditingController();
    searchNode = FocusNode();
    _controller = CarouselController();



    super.initState();
  }

  @override
  void dispose() {
    searchController.dispose();
    searchNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    cartProvider = Provider.of<CartProvider>(context, listen: true);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(MediaQuery.of(context).size.height*0.15),
        child: MainAppBarWithSearch(
            controller: searchController, focusNode: searchNode),
      ),
      body: homeBodyWidget(),
    );
  }

  lcoationAutoFetchBar(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(user!.uid).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return customSnackBar(
              context: context, content: LocaleKeys.somethingWentWrong.tr());
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return customSnackBar(
              context: context, content: LocaleKeys.somethingWentWrong.tr());
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          if (data['address'] == null) {
            Position? position = data['location'];
            getFetchedAddress(context, position).then((location) {
              return locationTextWidget(
                location: location,
              );
            });
          } else {
            return locationTextWidget(location: data['address']);
          }
          return locationTextWidget(location: LocaleKeys.updateLocation.tr());
        }
        return locationTextWidget(location: LocaleKeys.fetchingLocation.tr());
      },
    );
  }

  Widget homeBodyWidget() {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.only(right: 2,left: 2,bottom: 2,top: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(15),topRight: Radius.circular(15)),
                  color: '#f9fcf7'.toColor()),
              child: Column(
                children: [
                  const CategoryWidget(),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height*0.035,
                        top: MediaQuery.of(context).size.height*0.01,
                        left: 8,
                        right: 8),
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: '#e6eedf'.toColor(),
                              spreadRadius: 3,
                              blurRadius:4
                            )
                          ],
                          borderRadius: BorderRadius.circular(10)
                        ),
                      // clipBehavior: Clip.antiAlias,
                      height: MediaQuery.of(context).size.height*0.2,
                      width: double.infinity,
                      child: FutureBuilder(
                        future: downloadBannerImageUrlList(),
                        builder: (BuildContext context,
                            AsyncSnapshot<List<String>> snapshot) {

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Container(
                              height: 250,
                              // color: '#f9fcf7'.toColor(),
                              decoration: BoxDecoration(
                                  color: '#f9fcf7'.toColor(),
                                  boxShadow: [
                                    BoxShadow(
                                      color: '#f9fcf7'.toColor(),
                                      spreadRadius: 50,
                                      blurRadius:50
                                    )
                                  ],
                                  borderRadius: BorderRadius.circular(10)
                              ),
                              child: Center(
                                  child: CircularProgressIndicator(
                                color: secondaryColor,
                              )),
                            );
                          } else {
                            if (snapshot.hasError) {
                              return Text(
                                  LocaleKeys.bannerError.tr());
                            } else {
                              return CarouselSlider.builder(
                                itemCount: snapshot.data!.length,
                                options: CarouselOptions(
                                  autoPlay: true,
                                  viewportFraction: 1.0,
                                ),
                                itemBuilder: (context, index, realIdx) {
                                  return Container(
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color: '#f9fcf7'.toColor(),
                                              spreadRadius: 50,
                                              blurRadius:50
                                          )
                                        ],
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    width: MediaQuery.of(context).size.width,
                                    height: 0,
                                    child: CachedNetworkImage(
                                      imageUrl: snapshot.data![index],
                                      fit: BoxFit.fill,
                                    ),
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            ProfileListing()
          ],
        ),
      ),
    );
  }
}

class locationTextWidget extends StatelessWidget {
  final String? location;
  const locationTextWidget({Key? key, required this.location})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(
          Icons.pin_drop,
          size: 18,
        ),
        const SizedBox(
          width: 10,
        ),
        Text(
          location ?? '',
          style: TextStyle(
            color: blackColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
