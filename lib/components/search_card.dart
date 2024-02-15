import 'package:bechdal_app/constants/validators.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/models/product_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../l10n/locale_keys.g.dart';
import '../models/search_model.dart';
import '../models/seller_model.dart';
import '../services/auth.dart';

class SearchCard extends StatefulWidget {
  final String address;
  final SearchModel item;

  const SearchCard({
    required this.address,
    required this.item,
    Key? key,
  }) : super(key: key);
  @override
  State<SearchCard> createState() => _SearchCardState(address: address, item: item);

}

class _SearchCardState extends State<SearchCard> {
  final String address;
  final SearchModel item;
  Auth authService = Auth();
  bool isOpen = false;


  _SearchCardState({required this.address, required this.item});

  @override
  void initState() {

    if(item is Sellers){
      getStatus((item as Sellers).document);
    }

    super.initState();
  }

  @override
  getStatus(sellerDetails){

    authService.companies.where("__name__",isEqualTo: sellerDetails['uid']).get().then((value) {
      if(value.docs.isNotEmpty){
        if(value.docs[0]['open'] == true){

          setState(() {
            isOpen = true;
          });

        }
      }

    });
  }

  getProfileImage(sellerDetails) {

    if (sellerDetails == null) {
      return Image.asset(
        'assets/avatar.png',
        fit: BoxFit.fill,
      );
    } else {

      if ((sellerDetails!.data() as Map).containsKey('profile_picture') &&
          (sellerDetails!.data() as Map)['profile_picture'] != null && (sellerDetails!.data() as Map)['profile_picture'] != '') {
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
    return Container(
      height: MediaQuery.of(context).size.width*0.34,
      margin: const EdgeInsets.all(5),
      width: MediaQuery.of(context).size.width,
      child: Card(
        color: Colors.white,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: (item is Products) ? Row(

            children: [
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15)
                ),
                width: MediaQuery.of(context).size.width*0.3,
                height: MediaQuery.of(context).size.width*0.35,
                child: Image.network((item as Products).document!['images'][0],fit: BoxFit.fill,),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          (item as Products).title ?? '',
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width*0.042,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${LocaleKeys.currency.tr()} ${(item as Products).price != null ? intToStringFormatter((item as Products).price) : ''}',
                          maxLines: 1,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: MediaQuery.of(context).size.width*0.034,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      (item as Products).description ?? '',
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width*0.034,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              )
            ],
          ) :
          Container(

            child: Row(

              children: [
                Container(
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15)
                    ),
                    width: MediaQuery.of(context).size.width*0.3,
                    height: MediaQuery.of(context).size.width*0.35,
                    child: Stack(
                      children:
                      [
                        Container(
                          width: MediaQuery.of(context).size.width*0.3,
                          height: MediaQuery.of(context).size.width*0.35,
                          child: Image.network(
                            ((item as Sellers).document!.data() as Map)['profile_picture'].toString(),
                            fit: BoxFit.fill,
                          ),
                        ),
                        (!isOpen) ? Container(
                          width: MediaQuery.of(context).size.width*0.3,
                          height: MediaQuery.of(context).size.width*0.3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7),
                            color: Colors.black.withOpacity(0.5),
                          ),
                          child: Center(
                            child: Text(
                              LocaleKeys.closedLabel.tr(),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: MediaQuery.of(context).size.height*0.02
                              ),
                            ),
                          ),
                        ) : Container(),



                      ]
                    )
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            (item as Sellers).name ?? '',
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: MediaQuery.of(context).size.width*0.042,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RatingBar.builder(
                        initialRating: (item as Sellers).rating,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: MediaQuery.of(context).size.width*0.05,
                        itemPadding: const EdgeInsets.symmetric(horizontal: 0.5),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                        ignoreGestures: true,
                      ),




                    ],
                  ),
                )
              ],
            ),
          )
          ,
        ),
      ),
    );
  }
}
