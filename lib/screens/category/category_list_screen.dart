import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/forms/sell_car_form.dart';
import 'package:bechdal_app/l10n/locale_keys.g.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/screens/category/product_by_category_screen.dart';
import 'package:bechdal_app/screens/category/subcategory_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';
import '../../services/auth.dart';

class CategoryListScreen extends StatelessWidget {
  final bool? isForForm;
  static const String screenId = 'category_list_screen';
  const CategoryListScreen({Key? key, this.isForForm}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      backgroundColor: '#f9fcf7'.toColor(),
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height*0.08,
        backgroundColor: '#80cf70'.toColor(),
        elevation: 0.5,
        iconTheme: IconThemeData(color: Colors.grey.shade200,size: MediaQuery.of(context).size.height*0.04,),
        title: Text(
          isForForm == true
              ? LocaleKeys.selectCategory.tr()
              : LocaleKeys.category.tr(),
          style: TextStyle(
              color: Colors.grey.shade200,
              fontSize: MediaQuery.of(context).size.height * 0.04),
        ),
      ),
      body: _body(categoryProvider: categoryProvider, context: context),
    );
  }

  _body(
      {required CategoryProvider categoryProvider,
      required BuildContext context}) {
    Auth authService = Auth();
    String locale = context.locale.toString();
    String categoryName =
        locale == 'en' ? 'english_category_name' : 'arabic_category_name';

    return FutureBuilder<QuerySnapshot>(
        future: authService.categories.get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Container();
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: secondaryColor,
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: ListView.separated(
              itemCount: snapshot.data?.docs.length ?? 0,
              itemBuilder: ((context, index) {
                var doc = snapshot.data?.docs[index];
                return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      onTap: () {
                        categoryProvider.setCategory({
                          'id': doc!.id,
                          'english_category_name': doc['english_category_name'],
                          'arabic_category_name': doc['arabic_category_name'],
                        });
                        categoryProvider.setCategorySnapshot(doc);
                        if (isForForm == true) {
                          if (doc['subcategory'] == null) {
                            Navigator.of(context)
                                .pushNamed(SellCarForm.screenId);
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => SubCategoryScreen(
                                        doc: doc, isForForm: true)));
                          }
                        } else {
                          if (doc['subcategory'] == null) {
                            Navigator.of(context)
                                .pushNamed(ProductByCategory.screenId);
                          } else {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => SubCategoryScreen(
                                          doc: doc,
                                        )));
                          }
                        }
                      },
                      leading: Container(
                          width: MediaQuery.of(context).size.height * 0.07,
                          height: MediaQuery.of(context).size.height * 0.17,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4)),
                          clipBehavior: Clip.antiAlias,
                          child: Image.network(
                            doc!['img'],
                            fit: BoxFit.fill,
                          )),
                      title: Text(
                        doc[categoryName],
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.0235,
                        ),
                      ),
                      trailing: doc['subcategory'] != null
                          ? Icon(
                              Icons.arrow_forward_ios,
                              size: MediaQuery.of(context).size.height*0.0235,
                            )
                          : null,
                    ));
              }),
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                thickness: 0.8,
                indent: 18,
                endIndent: 18,
              ),
            ),
          );
        });
  }
}
