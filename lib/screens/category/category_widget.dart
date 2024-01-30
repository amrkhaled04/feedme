import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/l10n/locale_keys.g.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/screens/category/category_list_screen.dart';
import 'package:bechdal_app/screens/category/product_by_category_screen.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'subcategory_screen.dart';

class CategoryWidget extends StatefulWidget {
  const CategoryWidget({Key? key}) : super(key: key);






  @override
  State<CategoryWidget> createState() => _CategoryWidgetState();
}

class _CategoryWidgetState extends State<CategoryWidget> {
  Auth authService = Auth();


  @override
  Widget build(BuildContext context) {

    String locale = context.locale.toString();

    String categoryName = locale.contains('en') ? 'english_category_name' : 'arabic_category_name';

    var categoryProvider = Provider.of<CategoryProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(left: 9, right: 7),
      child: FutureBuilder<QuerySnapshot>(
        future: authService.categories
            .orderBy(categoryName, descending: false)
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text(LocaleKeys.somethingWentWrong.tr());
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Container();
            // Center(
            //   child: CircularProgressIndicator( color: secondaryColor ),
            // );
          }


          return SizedBox(
              height: MediaQuery.of(context).size.height*0.19,
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => Navigator.pushNamed(
                        context, CategoryListScreen.screenId),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height*0.0075),
                          child: Text(
                            LocaleKeys.homePageCategories.tr(),
                            style: TextStyle(
                                fontSize: MediaQuery.of(context).size.height*0.03,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              LocaleKeys.seeAll.tr(),
                              style: TextStyle(
                                color: disabledColor.withOpacity(0.9),
                                fontSize: MediaQuery.of(context).size.height*0.021,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: MediaQuery.of(context).size.height*0.019,
                              color: disabledColor.withOpacity(0.9),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                        shrinkWrap: false,
                        scrollDirection: Axis.horizontal,
                        itemCount: snapshot.data!.docs.length,
                        itemBuilder: ((context, index) {
                          var doc = snapshot.data!.docs[index];
                          return InkWell(
                            onTap: () {
                              categoryProvider
                                  .setCategory({
                                'id': doc.id,
                                'english_category_name':
                                    doc['english_category_name'],
                                'arabic_category_name':
                                    doc['arabic_category_name'],
                              });
                              categoryProvider.setCategorySnapshot(doc);
                              if (doc['subcategory'] == null) {
                                Navigator.of(context)
                                    .pushNamed(ProductByCategory.screenId);
                              } else {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) =>
                                            SubCategoryScreen(doc: doc)));
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.only(top: 10),
                              margin: const EdgeInsets.only(right: 15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height*0.083,
                                    width: MediaQuery.of(context).size.height*0.088,
                                    decoration: BoxDecoration(
                                      // color: Colors.grey.shade100,
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey.shade100,
                                              spreadRadius: 1,
                                              blurRadius:0
                                          )
                                        ],
                                        borderRadius: BorderRadius.circular(100)),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.network(
                                      doc['img'],
                                      fit: BoxFit.none,
                                      cacheHeight: (MediaQuery.of(context).size.height*0.068).toInt(),
                                      cacheWidth: (MediaQuery.of(context).size.height*0.065).toInt(),
                                      // width: 70,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      doc[categoryName],
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      style: TextStyle(
                                        color: Colors.grey[900],
                                        fontSize: MediaQuery.of(context).size.height*0.021,

                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        })),
                  )
                ],
              ));
        },
      ),
    );
  }
}
