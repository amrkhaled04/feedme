import 'package:bechdal_app/components/large_heading_widget.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/screens/auth/login_screen.dart';
import 'package:bechdal_app/screens/main_navigatiion_screen.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:bechdal_app/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csc_picker/csc_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lottie/lottie.dart' as lottie;

import '../l10n/locale_keys.g.dart';

class LocationScreen extends StatefulWidget {
  final bool? onlyPop;
  final String? popToScreen;

  static const String screenId = 'location_screen';
  const LocationScreen({
    this.popToScreen,
    this.onlyPop,

    Key? key,
  }) : super(key: key);

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: null,
        backgroundColor: '#f9fcf7'.toColor(),
        body: SingleChildScrollView(child: _body(context)),
        bottomNavigationBar: BottomLocationPermissionWidget(
            onlyPop: widget.onlyPop, popToScreen: widget.popToScreen ?? ''));
  }

  Widget _body(context) {
    return Column(
      children: [
        LargeHeadingWidget(
            heading: LocaleKeys.chooseLocation.tr(),
            subheadingTextSize: 16,
            headingTextSize: 30,
            subHeading:
                LocaleKeys.chooseLocationMessage.tr()),
        const SizedBox(
          height: 20,
        ),
        SizedBox(
          height: 300,
          width: MediaQuery.of(context).size.width*0.8,
          child: lottie.Lottie.asset(
            'assets/lottie/location_lottie.json',
          ),
        ),
      ],
    );
  }
}

class BottomLocationPermissionWidget extends StatefulWidget {
  final bool? onlyPop;
  final String popToScreen;

  const BottomLocationPermissionWidget({
    required this.popToScreen,
    this.onlyPop,


    Key? key,
  }) : super(key: key);

  @override
  State<BottomLocationPermissionWidget> createState() =>
      _BottomLocationPermissionWidgetState();
}

class _BottomLocationPermissionWidgetState
    extends State<BottomLocationPermissionWidget> {

  late GoogleMapController googleMapController;

  CameraPosition initialCameraPosition = const CameraPosition(target: LatLng(37.42796133580664, -122.085749655962), zoom: 14);

  Set<Marker> markers = {};
  UserService firebaseUser = UserService();
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: roundedButton(
          context: context,
          text: LocaleKeys.chooseLocation.tr(),
          textColor: Colors.black,
          bgColor: Colors.white,
          onPressed: () {
            openLocationBottomsheet(context);
          }),
    );
  }

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
                                  return (widget.onlyPop == true)
                                      ? (widget.popToScreen.isNotEmpty)
                                          ? Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  widget.popToScreen,
                                                  (route) => false)
                                          : Navigator.of(context)
                                              .pushNamedAndRemoveUntil(
                                                  MainNavigationScreen.screenId,
                                                  (route) => false)
                                      : Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              MainNavigationScreen.screenId,
                                              (route) => false);
                                }

                                return (widget.onlyPop == true)
                                    ? (widget.popToScreen.isNotEmpty)
                                        ? Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                    LoginScreen.screenId,
                                                (route) => false)
                                        : Navigator.of(context)
                                            .pushNamedAndRemoveUntil(
                                                LoginScreen.screenId,
                                                (route) => false)
                                    : Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                    LoginScreen.screenId,
                                            (route) => false);
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
}
