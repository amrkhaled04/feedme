import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/forms/common_form.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/screens/category/product_by_category_screen.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/colors.dart';

class SubCategoryScreen extends StatefulWidget {
  final DocumentSnapshot? doc;
  final bool? isForForm;
  static const String screenId = 'subcategory_screen';
  const SubCategoryScreen({Key? key, this.doc, this.isForForm})
      : super(key: key);

  @override
  State<SubCategoryScreen> createState() => _SubCategoryScreenState();
}

class _SubCategoryScreenState extends State<SubCategoryScreen> {
  @override
  Widget build(BuildContext context) {

    String locale = context.locale.toString();
    String categoryName = locale == 'en' ? 'english_category_name' : 'arabic_category_name';

    var categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(10),
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.08,
        backgroundColor: '#80cf70'.toColor(),
        elevation: 0.5,
        iconTheme: IconThemeData(
          color: Colors.grey.shade200,
          size: MediaQuery.of(context).size.height * 0.04,
        ),
        title: Text(
          widget.doc![categoryName] ?? '',
          style: TextStyle(color: Colors.grey.shade200,fontSize: MediaQuery.of(context).size.height*0.04),
        ),
      ),
      backgroundColor: '#f9fcf7'.toColor(),
      body: _body(widget.doc, categoryProvider, widget.isForForm),
    );
  }

  _body(args, CategoryProvider categoryProvider, bool? isForForm) {
    Auth authService = Auth();
    return FutureBuilder<DocumentSnapshot>(
        future: authService.categories.doc(args.id).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
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
          var data = snapshot.data!['subcategory'];
          return ListView.separated(
              itemCount: data.length,
              separatorBuilder: (BuildContext context, int index) =>
              const Divider(
                thickness: 0.8,
                indent: 18,
                endIndent: 18,
              ),
              itemBuilder: ((context, index) {
                return Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: ListTile(
                      trailing: ((context.locale.toString().contains('en')) ? data[index]['english_subcategory_name'] : data[index]['arabic_subcategory_name']) != null
                          ? Icon(
                        Icons.arrow_forward_ios,
                        size: MediaQuery.of(context).size.height*0.0235,
                      )
                          : null,
                      onTap: () {
                        categoryProvider.setSubCategory(data[index]);

                        if (isForForm == true) {
                          Navigator.pushNamed(context, CommonForm.screenId);
                        } else {
                          Navigator.pushNamed(
                            context,
                            ProductByCategory.screenId,
                          );
                        }
                      },
                      title: Text(
                        (context.locale.toString().contains('en')) ? data[index]['english_subcategory_name'] : data[index]['arabic_subcategory_name'],
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.0235,
                        ),
                      ),
                    ));
              }));
        });
  }
}
