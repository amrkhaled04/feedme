import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/welcome_screen.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:bechdal_app/utils.dart';
import '../components/change_profile_photo.dart';
import '../l10n/locale_keys.g.dart';
import '../services/auth.dart';

class ProfileScreen extends StatefulWidget {
  static const screenId = 'profile_screen';
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  UserService firebaseUser = UserService();

  String errorString = "";

  Auth auth = Auth();
  //
  // int productCount = 0;
  // int orderCount = 0;
  // double balance = 0;
  //
  // void getUserProducts() async {
  //   setState(() {
  //     productCount = 0;
  //   });
  // }

  ImageProvider getProfileImage() {
    if (FirebaseAuth.instance.currentUser!.photoURL != null) {
      return Image.network(
        FirebaseAuth.instance.currentUser!.photoURL.toString(),

      ).image;
    } else {
      return const AssetImage('assets/avatar.png');
    }
  }
  late GoogleMapController googleMapController;

  CameraPosition initialCameraPosition = const CameraPosition(target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

  Set<Marker> markers = {};

  openLocationBottomsheet(BuildContext context) {

    bool firstLaunch = true;
    String countryValue = '';
    String stateValue = '';
    String cityValue = '';
    String address = '';
    String manualAddress = '';
    loadingDialogBox(context, LocaleKeys.fetchingDetails.tr());
    getLocationAndAddress(context).then((location) {
      if (location != null) {
        Navigator.pop(context);
        setState(() {
          address = location;
        });
        showModalBottomSheet(
            isScrollControlled: true,
            enableDrag: false,
            context: context,
            backgroundColor: '#f9fcf7'.toColor(),
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  firstLaunch?
                  getCurrentLocation(
                      context, serviceEnabled, permission)
                      .then((value) {
                    if (value != null) {
                      initialCameraPosition = CameraPosition(target: LatLng(value.latitude, value.longitude), zoom: 14);
                      firebaseUser.updateFirebaseUser(context, {
                        'location':
                        GeoPoint(value.latitude, value.longitude),
                        'address': address
                      }).then((value) {
                        customSnackBar(context: context, content: LocaleKeys.locationUpdatedSuccessfully.tr());
                      });
                    }
                    setState((){
                      googleMapController
                          .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(value.latitude, value.longitude), zoom: 14)));
                      markers.clear();
                      markers.add(Marker(markerId: const MarkerId('currentLocation'),position: LatLng(value.latitude, value.longitude)));

                    });
                  }):null;
                  firstLaunch = false;
                  return Container(
                    color: whiteColor,
                    child: Column(
                      children: [
                        Container(
                          height: 30,
                          color:'#80cf70'.toColor(),
                        ),
                        AppBar(
                          toolbarHeight: MediaQuery.of(context).size.height*0.08,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(10),
                            ),
                          ),
                          automaticallyImplyLeading: false,
                          iconTheme: IconThemeData(
                            color: Colors.grey[100],
                            size: MediaQuery.of(context).size.height*0.04,
                          ),
                          backgroundColor: '#80cf70'.toColor(),
                          elevation: 0.5,
                          title: Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    icon: const Icon(
                                      Icons.clear,
                                    )),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  LocaleKeys.chooseLocation.tr(),
                                  style: TextStyle(color: Colors.grey[100],fontSize: MediaQuery.of(context).size.width*0.09),
                                )
                              ]),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(
                        //       vertical: 10, horizontal: 10),
                        //   child: TextFormField(
                        //     decoration: InputDecoration(
                        //         suffixIcon: const Icon(Icons.search),
                        //         hintText: LocaleKeys.selectCityAreaOrNeighbourhood.tr(),
                        //         hintStyle: TextStyle(
                        //           color: greyColor,
                        //           fontSize: 12,
                        //         ),
                        //         contentPadding: const EdgeInsets.all(20),
                        //         border: OutlineInputBorder(
                        //             borderRadius: BorderRadius.circular(8))),
                        //   ),
                        // ),
                        // ListTile(
                        //   onTap: () async {
                        //     customSnackBar(context: context, content: LocaleKeys.fetchingLocation.tr());
                        //     await getCurrentLocation(
                        //         context, serviceEnabled, permission)
                        //         .then((value) {
                        //       if (value != null) {
                        //         _initialcameraposition = LatLng(value.latitude, value.logitude);
                        //         firebaseUser.updateFirebaseUser(context, {
                        //           'location':
                        //           GeoPoint(value.latitude, value.longitude),
                        //           'address': address
                        //         }).then((value) {
                        //
                        //           customSnackBar(context: context, content: LocaleKeys.locationUpdatedSuccessfully.tr());
                        //
                        //           return (countryValue.isEmpty || cityValue.isEmpty || stateValue.isEmpty || address.isEmpty )  ? null   : (widget.onlyPop == true)
                        //               ? (widget.popToScreen.isNotEmpty)
                        //               ? Navigator.of(context)
                        //               .pushNamedAndRemoveUntil(
                        //               widget.popToScreen,
                        //                   (route) => false)
                        //               : Navigator.of(context)
                        //               .pushNamedAndRemoveUntil(
                        //               MainNavigationScreen.screenId,
                        //                   (route) => false)
                        //               : Navigator.of(context)
                        //               .pushNamedAndRemoveUntil(
                        //               MainNavigationScreen.screenId,
                        //                   (route) => false);
                        //         });
                        //       }
                        //     });
                        //   },
                        //   horizontalTitleGap: 0,
                        //   leading: Icon(
                        //     Icons.my_location,
                        //     color: secondaryColor,
                        //   ),
                        //   title: Text(
                        //     LocaleKeys.useCurrentLocation.tr(),
                        //     style: TextStyle(
                        //       color: secondaryColor,
                        //       fontWeight: FontWeight.bold,
                        //     ),
                        //   ),
                        //   subtitle: Text(
                        //     address == '' ? LocaleKeys.fetchCurrentLocation.tr() : address,
                        //     style: TextStyle(
                        //       color: greyColor,
                        //       fontSize: 10,
                        //     ),
                        //   ),
                        // ),

                        SizedBox(
                          width: MediaQuery.of(context).size.width*0.95,
                          height: MediaQuery.of(context).size.height*0.45,
                          child: Stack(
                              children: [
                                Container(
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15)
                                  ),
                                  child: GoogleMap(
                                    initialCameraPosition: initialCameraPosition,
                                    markers: markers,
                                    zoomControlsEnabled: false,
                                    zoomGesturesEnabled: true,
                                    mapType: MapType.normal,
                                    onTap: (LatLng x){
                                      setState((){
                                        firstLaunch = false;
                                        markers.clear();
                                        markers.add(Marker(markerId: const MarkerId('currentLocation'),position: LatLng(x.latitude, x.longitude)));

                                      });
                                      firebaseUser.updateFirebaseUser(context, {
                                        'location':GeoPoint(x.latitude, x.longitude)
                                      }
                                      );
                                    },
                                    onMapCreated: (GoogleMapController controller) {
                                      googleMapController = controller;
                                    },
                                  ),
                                ),
                                Positioned(
                                  right: 5,
                                  bottom: 5,
                                  child: FloatingActionButton.extended(
                                    onPressed: () async {
                                      customSnackBar(context: context, content: LocaleKeys.fetchingLocation.tr());
                                      await getCurrentLocation(
                                          context, serviceEnabled, permission)
                                          .then((value) {
                                        if (value != null) {
                                          initialCameraPosition = CameraPosition(target: LatLng(value.latitude, value.longitude), zoom: 14);
                                          firebaseUser.updateFirebaseUser(context, {
                                            'location':
                                            GeoPoint(value.latitude, value.longitude),
                                            'address': address
                                          }).then((value) {
                                            customSnackBar(context: context, content: LocaleKeys.locationUpdatedSuccessfully.tr());
                                          });
                                        }
                                        setState((){
                                          firstLaunch = false;
                                          googleMapController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(value.latitude, value.longitude), zoom: 14)));
                                          markers.clear();
                                          markers.add(Marker(markerId: const MarkerId('currentLocation'),position: LatLng(value.latitude, value.longitude)));

                                        });
                                      });
                                    },
                                    backgroundColor: '#80cf70'.toColor(),
                                    label: const Text("Current Location"),
                                    icon: const Icon(Icons.location_history),
                                  ),
                                ),
                              ]
                          ),
                        ),

                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Text(
                            LocaleKeys.chooseCity.tr(),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                color: blackColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: CSCPicker(
                            layout: Layout.vertical,
                            defaultCountry: CscCountry.Egypt,
                            flagState: CountryFlag.DISABLE,
                            dropdownDecoration:
                            const BoxDecoration(shape: BoxShape.rectangle),
                            onCountryChanged: (value) async {
                              setState(() {
                                countryValue = value;
                              });
                            },
                            onStateChanged: (value) async {
                              setState(() {
                                if (value != null) {
                                  stateValue = value;
                                }
                              });
                            },
                            onCityChanged: (value) async {
                              setState(() {
                                if (value != null) {
                                  cityValue = value;
                                  manualAddress = "$cityValue, $stateValue";
                                  print(manualAddress);
                                }
                              });
                              if (value != null) {
                                firebaseUser.updateFirebaseUser(context, {
                                  'address': address,
                                  'state': stateValue,
                                  'city': cityValue,
                                  'country': countryValue
                                }).then((value) {
                                  if (kDebugMode) {
                                    print(
                                        '${manualAddress}inside manual selection');
                                  }

                                  if (countryValue.isEmpty || cityValue.isEmpty || stateValue.isEmpty || address.isEmpty )  {
                                    customSnackBar(context: context, content: LocaleKeys.mustFillAllFieldsError.tr());
                                  } else {
                                    customSnackBar(context: context, content: LocaleKeys.locationUpdatedSuccessfully.tr());
                                    return Navigator.pop(context);
                                  }
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            });
      } else {
        Navigator.pop(context);
      }
    });
  }



  @override
  Widget build(BuildContext context) {

    // if (!UserService.guestUser) {
    //     firebaseUser.getUsePosts().then((value) {
    //       setState(() {
    //         productCount = value!.docs.length;
    //       });
    //     });
    //
    //     auth.orders
    //         .where('seller_uid',
    //             isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    //         .get()
    //         .then((value) {
    //       setState(() {
    //         orderCount = value.docs.length;
    //         balance = 0;
    //         for (var i = 0; i < value.docs.length; i++) {
    //           balance += double.parse(value.docs[i]['total_price'].toString());
    //         }
    //       });
    //   });
    // }

    return
    Container(
      color: '#f9fcf7'.toColor(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 4,),
          Column(
            children: [
              InkWell(
                onTap: () async {

                  // ask user to delete profile image

                  return openBottomSheet(
                      context: context, child: const ChangeProfilePhoto()
                  );



                },
                child: CircleAvatar(
                  radius: MediaQuery.of(context).size.height*0.075,
                  backgroundImage: getProfileImage(),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.transparent,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              Text(
                FirebaseAuth.instance.currentUser!.email.toString(),
                style: TextStyle(
                    fontSize: MediaQuery.of(context).size.height*0.025,
                    fontWeight: FontWeight.bold,
                    color: blackColor),
              ),
              const SizedBox(
                height: 20,
              ),

              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Column(
              //       children: [
              //         Text(
              //           balance.toString(),
              //           style: TextStyle(
              //               fontSize: MediaQuery.of(context).size.height*0.025,
              //               fontWeight: FontWeight.bold,
              //               color: blackColor),
              //         ),
              //         Text(
              //           LocaleKeys.balance.tr(),
              //           style: TextStyle(
              //               fontSize: MediaQuery.of(context).size.height*0.025,
              //               fontWeight: FontWeight.bold,
              //               color: blackColor),
              //         ),
              //       ],
              //     ),
              //     const SizedBox(
              //       width: 20,
              //     ),
              //     Column(
              //       children: [
              //         Text(
              //           orderCount.toString(),
              //           style: TextStyle(
              //               fontSize: MediaQuery.of(context).size.height*0.025,
              //               fontWeight: FontWeight.bold,
              //               color: blackColor),
              //         ),
              //         Text(
              //           LocaleKeys.orders.tr(),
              //           style: TextStyle(
              //               fontSize: MediaQuery.of(context).size.height*0.025,
              //               fontWeight: FontWeight.bold,
              //               color: blackColor),
              //         ),
              //       ],
              //     ),
              //
              //
              //   ],
              // ),

            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height*0.08,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pushNamed('past_orders');
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      backgroundColor: '#80cf70'.toColor(),
                      minimumSize: Size(MediaQuery.of(context).size.width*0.8, MediaQuery.of(context).size.height*0.075)
                  ),
                  child: Text(LocaleKeys.previousOrders.tr(),
                      style: TextStyle(
                          color: Colors.grey.shade200,
                          fontSize: MediaQuery.of(context).size.height*0.02)),
              ),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
              onPressed: (){
                String locale = context.locale.toString();

                if (locale.contains('en')) {
                  context.setLocale(const Locale('ar'));
                } else {
                  context.setLocale(const Locale('en'));
                }

              },
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: '#80cf70'.toColor(),
                  minimumSize: Size(MediaQuery.of(context).size.width*0.8, MediaQuery.of(context).size.height*0.075)
              ),
              child: Text(LocaleKeys.switchLanguage.tr(),
                  style: TextStyle(
                      color: Colors.grey.shade200,
                      fontSize: MediaQuery.of(context).size.height*0.02)),
          ),
          const SizedBox(
            height: 15,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: '#80cf70'.toColor(),
                  minimumSize: Size(MediaQuery.of(context).size.width*0.8, MediaQuery.of(context).size.height*0.075)
              ),
              onPressed: (){
                openLocationBottomsheet(context);

              },
              child: Text(LocaleKeys.changeAddress.tr(),
                  style: TextStyle(
                      color: Colors.grey.shade200,
                      fontSize: MediaQuery.of(context).size.height*0.02)),

          ),
          const SizedBox(
          height: 15,

          ),

          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  backgroundColor: '#80cf70'.toColor(),
                  minimumSize: Size(MediaQuery.of(context).size.width*0.8, MediaQuery.of(context).size.height*0.075)
              ),
              onPressed: () async {
                loadingDialogBox(context, 'Signing Out');


                await googleSignIn.signOut();

                await FirebaseAuth.instance.signOut().then((value) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                      WelcomeScreen.screenId, (route) => false);
                });
              },
              child: Text(
                LocaleKeys.signOut.tr(),
                  style: TextStyle(
                      color: Colors.grey.shade200,
                      fontSize: MediaQuery.of(context).size.height*0.02)
              )
          ),
          const Spacer(flex: 4,),
        ],
      ),
    );
  }
}
