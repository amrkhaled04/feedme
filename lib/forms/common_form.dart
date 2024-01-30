// ignore_for_file: void_checks

import 'package:bechdal_app/components/bottom_nav_widget.dart';
import 'package:bechdal_app/components/image_picker_widget.dart';
import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/validators.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/forms/user_form_review.dart';
import 'package:bechdal_app/provider/category_provider.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/locale_keys.g.dart';

class CommonForm extends StatefulWidget {
  static const String screenId = 'common_form';
  const CommonForm({Key? key}) : super(key: key);

  @override
  State<CommonForm> createState() => _CommonFormState();
}

class _CommonFormState extends State<CommonForm> {
  UserService firebaseUser = UserService();
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _brandController;
  late FocusNode _brandNode;
  late TextEditingController _descriptionController;
  late FocusNode _descriptionNode;
  late TextEditingController _titleController;
  late FocusNode _titleNode;
  late TextEditingController _priceController;
  late FocusNode _priceNode;
  late TextEditingController _typeController;
  late FocusNode _typeNde;
  late TextEditingController _bedroomController;
  late FocusNode _bedroomNode;
  late TextEditingController _bathroomController;
  late FocusNode _bathroomNode;
  late TextEditingController _furnishController;
  late FocusNode _furnishNode;
  late TextEditingController _constructionController;
  late FocusNode _constructionNode;
  late TextEditingController _sqftController;
  late FocusNode _sqftNode;
  late TextEditingController _floorsController;
  late FocusNode _floorsNode;

  List accessoriesList = ['Mobile', 'Tablet'];
  List tabletList = ['IPads', 'Samsung', 'Other Tablets'];
  List appartmentList = ['Apartments', 'Farm Houses', 'Houses & Villas'];
  List bedroomList = ['1', '2', '3', '3+'];
  List bathroomList = ['1', '2', '3', '3+'];
  List furnishList = ['Full-Furnished', 'Semi-Furnished', 'Un-Furnished'];
  List constructionList = ['New Launch', 'Ready to Move', 'Under construction'];
  @override
  void initState() {
    _brandController = TextEditingController();
    _brandNode = FocusNode();
    _descriptionController = TextEditingController();
    _descriptionNode = FocusNode();
    _titleController = TextEditingController();
    _titleNode = FocusNode();
    _priceController = TextEditingController();
    _priceNode = FocusNode();
    _typeController = TextEditingController();
    _typeNde = FocusNode();
    _bedroomController = TextEditingController();
    _bedroomNode = FocusNode();
    _bathroomController = TextEditingController();
    _bathroomNode = FocusNode();
    _furnishController = TextEditingController();
    _furnishNode = FocusNode();
    _constructionController = TextEditingController();
    _constructionNode = FocusNode();
    _sqftController = TextEditingController();
    _sqftNode = FocusNode();
    _floorsController = TextEditingController();
    _floorsNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _brandController.dispose();
    _brandNode.dispose();
    _descriptionController.dispose();
    _descriptionNode.dispose();
    _titleController.dispose();
    _titleNode.dispose();
    _priceController.dispose();
    _priceNode.dispose();
    _typeController.dispose();
    _typeNde.dispose();
    _bedroomController.dispose();
    _bedroomNode.dispose();
    _bathroomController.dispose();
    _bathroomNode.dispose();
    _furnishController.dispose();
    _furnishNode.dispose();
    _constructionController.dispose();
    _constructionNode.dispose();
    _sqftController.dispose();
    _sqftNode.dispose();
    _floorsController.dispose();
    _floorsNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var categoryProvider = Provider.of<CategoryProvider>(context);
    return Scaffold(
      appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.height*0.08,
          elevation: 0.5,
          iconTheme: IconThemeData(color: blackColor,size: MediaQuery.of(context).size.height*0.04,),
          backgroundColor: whiteColor,
          title: Row(
            children: [
              Text(
                '${ (context.locale.toString().contains('en')) ? categoryProvider.selectedCategory!['english_category_name'] : categoryProvider.selectedCategory!['arabic_category_name'] } ',
                style: TextStyle(color: blackColor,fontSize: MediaQuery.of(context).size.height*0.04),
              ),
              Text(
                LocaleKeys.details.tr(),
                style: TextStyle(color: blackColor,fontSize: MediaQuery.of(context).size.height*0.04),
              ),
            ],
          )
        ),
      body: SingleChildScrollView(child: formBodyWidget(context, categoryProvider)),
      bottomNavigationBar: BottomNavigationWidget(
        buttonText: LocaleKeys.next.tr(),
        validator: true,
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            categoryProvider.formData.addAll({
              'seller_uid': firebaseUser.user!.uid,
              'category': categoryProvider.selectedCategory!['english_category_name'],
              'subcategory': categoryProvider.selectedSubCategory!['english_subcategory_name'],
              'brand': _brandController.text,
              'type': _typeController.text,
              'bedroom': _bedroomController.text,
              'bathroom': _bathroomController.text,
              'furnishing': _furnishController.text,
              'floors': _floorsController.text,
              'construction_status': _constructionController.text,
              'sqft': _sqftController.text,
              'title': _titleController.text,
              'description': _descriptionController.text,
              'price': _priceController.text,
              'images': categoryProvider.imageUploadedUrls.isEmpty
                  ? ''
                  : categoryProvider.imageUploadedUrls,
              'posted_at': DateTime.now().microsecondsSinceEpoch,
              'favourites': [],
              'favourite_count': 0,
            });
            if (categoryProvider.imageUploadedUrls.isNotEmpty) {
              Navigator.pushNamed(context, UserFormReview.screenId);
            } else {
              customSnackBar(
                  context: context,
                  content: LocaleKeys.pleaseUploadImage.tr());
            }
            print(categoryProvider.formData);
          }
        },
      ),
    );
  }

  brandBottomSheet(context, categoryProvider) {
    return openBottomSheet(
      context: context,
      appBarTitle: 'Select Brand',
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: categoryProvider.doc['brands'].length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                setState(() {
                  _brandController.text =
                      categoryProvider.doc['brands'][index]['name'];
                });
                Navigator.pop(context);
              },
              title: Text(categoryProvider.doc['brands'][index]['name']),
              leading: Image.network(
                categoryProvider.doc['brands'][index]['img'],
                width: 35,
                height: 35,
              ),
            );
          }),
    );
  }

  commonBottomsheet(context, list, controller) {
    return openBottomSheet(
      context: context,
      appBarTitle: 'Select type',
      child: ListView.builder(
          shrinkWrap: true,
          itemCount: list.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              onTap: () {
                setState(() {
                  controller.text = list[index];
                });
                Navigator.pop(context);
              },
              title: Text(list[index]),
            );
          }),
    );
  }

  formBodyWidget(BuildContext context, CategoryProvider categoryProvider) {
    return SafeArea(
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            padding:
                const EdgeInsets.only(left: 10, top: 10, right: 10, bottom: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${(context.locale.toString().contains('en')) ? categoryProvider.selectedSubCategory!['english_subcategory_name'] : categoryProvider.selectedSubCategory!['arabic_subcategory_name']}',
                  style: TextStyle(
                    color: blackColor,
                    fontWeight: FontWeight.bold,
                    fontSize: MediaQuery.of(context).size.height*0.03,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                (categoryProvider.selectedSubCategory == 'Mobile Phones')
                    ? InkWell(
                        onTap: () =>
                            brandBottomSheet(context, categoryProvider),
                        child: TextFormField(
                            focusNode: _brandNode,
                            controller: _brandController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please choose your model brand';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.name,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Brand',
                              errorStyle: const TextStyle(
                                  color: Colors.red, fontSize: 10),
                              labelStyle: TextStyle(
                                color: greyColor,
                                fontSize: 14,
                              ),
                              suffixIcon: Icon(
                                Icons.arrow_drop_down_sharp,
                                color: blackColor,
                                size: 30,
                              ),
                              hintText: 'Enter your mobile brand',
                              hintStyle: TextStyle(
                                color: greyColor,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.all(15),
                            )),
                      )
                    : const SizedBox(),
                (categoryProvider.selectedSubCategory == 'Accessories' ||
                        categoryProvider.selectedSubCategory == 'Tablets' ||
                        categoryProvider.selectedSubCategory ==
                            'For Sale: House & Apartments' ||
                        categoryProvider.selectedSubCategory ==
                            'For Rent: House & Apartments')
                    ? InkWell(
                        onTap: () {
                          if (categoryProvider.selectedSubCategory ==
                              'Accessories') {
                            return commonBottomsheet(
                                context, accessoriesList, _typeController);
                          }
                          if (categoryProvider.selectedSubCategory ==
                              'Tablets') {
                            return commonBottomsheet(
                                context, tabletList, _typeController);
                          }
                          if (categoryProvider.selectedSubCategory ==
                                  'For Sale: House & Apartments' ||
                              categoryProvider.selectedSubCategory ==
                                  'For Rent: House & Apartments') {
                            return commonBottomsheet(
                                context, appartmentList, _typeController);
                          }
                        },
                        child: TextFormField(
                            focusNode: _typeNde,
                            controller: _typeController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please choose your type';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.name,
                            enabled: false,
                            decoration: InputDecoration(
                              labelText: 'Type*',
                              errorStyle: const TextStyle(
                                  color: Colors.red, fontSize: 10),
                              labelStyle: TextStyle(
                                color: greyColor,
                                fontSize: 14,
                              ),
                              suffixIcon: Icon(
                                Icons.arrow_drop_down_sharp,
                                color: blackColor,
                                size: 30,
                              ),
                              hintText: 'Enter your type',
                              hintStyle: TextStyle(
                                color: greyColor,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.all(15),
                            )),
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                (categoryProvider.selectedSubCategory ==
                            'For Sale: House & Apartments' ||
                        categoryProvider.selectedSubCategory ==
                            'For Rent: House & Apartments')
                    ? Column(
                        children: [
                          InkWell(
                            onTap: () {
                              // ignore: void_checks
                              return commonBottomsheet(
                                  context, bedroomList, _bedroomController);
                            },
                            child: TextFormField(
                                focusNode: _bedroomNode,
                                controller: _bedroomController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please choose your bedroom';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.name,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Bedroom*',
                                  errorStyle: const TextStyle(
                                      color: Colors.red, fontSize: 10),
                                  labelStyle: TextStyle(
                                    color: greyColor,
                                    fontSize: 14,
                                  ),
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: blackColor,
                                    size: 30,
                                  ),
                                  hintText: 'Enter your bedroom',
                                  hintStyle: TextStyle(
                                    color: greyColor,
                                    fontSize: 14,
                                  ),
                                  contentPadding: const EdgeInsets.all(15),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              // ignore: void_checks
                              return commonBottomsheet(
                                  context, bathroomList, _bathroomController);
                            },
                            child: TextFormField(
                                focusNode: _bathroomNode,
                                controller: _bathroomController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please choose your bathroom';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.name,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Bathroom*',
                                  errorStyle: const TextStyle(
                                      color: Colors.red, fontSize: 10),
                                  labelStyle: TextStyle(
                                    color: greyColor,
                                    fontSize: 14,
                                  ),
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: blackColor,
                                    size: 30,
                                  ),
                                  hintText: 'Enter your bathroom',
                                  hintStyle: TextStyle(
                                    color: greyColor,
                                    fontSize: 14,
                                  ),
                                  contentPadding: const EdgeInsets.all(15),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              return commonBottomsheet(
                                  context, furnishList, _furnishController);
                            },
                            child: TextFormField(
                                focusNode: _furnishNode,
                                controller: _furnishController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please choose your furnish type';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.name,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Furnishing*',
                                  errorStyle: const TextStyle(
                                      color: Colors.red, fontSize: 10),
                                  labelStyle: TextStyle(
                                    color: greyColor,
                                    fontSize: 14,
                                  ),
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: blackColor,
                                    size: 30,
                                  ),
                                  hintText: 'Enter your furnish type',
                                  hintStyle: TextStyle(
                                    color: greyColor,
                                    fontSize: 14,
                                  ),
                                  contentPadding: const EdgeInsets.all(15),
                                )),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          InkWell(
                            onTap: () {
                              return commonBottomsheet(context,
                                  constructionList, _constructionController);
                            },
                            child: TextFormField(
                                focusNode: _constructionNode,
                                controller: _constructionController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please choose your construction status';
                                  }
                                  return null;
                                },
                                keyboardType: TextInputType.name,
                                enabled: false,
                                decoration: InputDecoration(
                                  labelText: 'Construction Status*',
                                  errorStyle: const TextStyle(
                                      color: Colors.red, fontSize: 10),
                                  labelStyle: TextStyle(
                                    color: greyColor,
                                    fontSize: 14,
                                  ),
                                  suffixIcon: Icon(
                                    Icons.arrow_drop_down_sharp,
                                    color: blackColor,
                                    size: 30,
                                  ),
                                  hintText: 'Enter your Construction status',
                                  hintStyle: TextStyle(
                                    color: greyColor,
                                    fontSize: 14,
                                  ),
                                  contentPadding: const EdgeInsets.all(15),
                                )),
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                              controller: _sqftController,
                              focusNode: _sqftNode,
                              validator: (value) {
                                return checkNullEmptyValidation(value, 'sqft',false);
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Sqft*',
                                labelStyle: TextStyle(
                                  color: greyColor,
                                  fontSize: 14,
                                ),
                                errorStyle: const TextStyle(
                                    color: Colors.red, fontSize: 10),
                                contentPadding: const EdgeInsets.all(15),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: disabledColor)),
                              )),
                          const SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                              controller: _floorsController,
                              focusNode: _floorsNode,
                              validator: (value) {
                                return checkNullEmptyValidation(
                                    value, 'floors',false);
                              },
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Floors*',
                                labelStyle: TextStyle(
                                  color: greyColor,
                                  fontSize: 14,
                                ),
                                errorStyle: const TextStyle(
                                    color: Colors.red, fontSize: 10),
                                contentPadding: const EdgeInsets.all(15),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide:
                                        BorderSide(color: disabledColor)),
                              )),
                        ],
                      )
                    : const SizedBox(),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: _titleController,
                    focusNode: _titleNode,
                    maxLength: 50,
                    validator: (value) {
                      return checkNullEmptyValidation(value, LocaleKeys.title.tr(), context.locale.toString().contains('ar'));
                    },
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: '${LocaleKeys.title.tr()}*',
                      counterText:
                          LocaleKeys.descripionHelper.tr(),
                      counterStyle: TextStyle(
                        color: greyColor,
                        fontSize: MediaQuery.of(context).size.height*0.015
                      ),
                      labelStyle: TextStyle(
                        color: greyColor,
                        fontSize:  MediaQuery.of(context).size.height*0.022
                      ),
                      errorStyle:
                        TextStyle(color: Colors.red, fontSize:
                        context.locale == 'en'?MediaQuery.of(context).size.height*0.018:
                        MediaQuery.of(context).size.height*0.015),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: disabledColor)),
                    )),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                    controller: _descriptionController,
                    focusNode: _descriptionNode,
                    maxLength: 200,
                    validator: (value) {
                      return checkNullEmptyValidation(
                          value, LocaleKeys.description.tr(), context.locale.toString().contains('ar'));
                    },
                    maxLines: 3,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: '${LocaleKeys.description.tr()}*',
                      counterText: '',
                      labelStyle: TextStyle(
                        color: greyColor,
                        fontSize: MediaQuery.of(context).size.height*0.022
                      ),
                      errorStyle:
                        TextStyle(color: Colors.red, fontSize: MediaQuery.of(context).size.height*0.018),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: disabledColor)),
                    )),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                    controller: _priceController,
                    focusNode: _priceNode,
                    validator: (value) {
                      return validatePrice(value, context.locale.toString().contains('ar'));
                    },
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      prefix: Text('${LocaleKeys.currency.tr()} '),
                      labelText: '${LocaleKeys.price.tr()}*',
                      labelStyle: TextStyle(
                        color: greyColor,
                        fontSize: MediaQuery.of(context).size.height*0.022
                      ),
                      errorStyle:
                          TextStyle(color: Colors.red, fontSize: MediaQuery.of(context).size.height*0.018),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: disabledColor)),
                    )),
                const SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    if (kDebugMode) {
                      print(categoryProvider.imageUploadedUrls.length);
                    }
                    return openBottomSheet(
                        context: context, child: const ImagePickerWidget());
                  },
                  child: Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.025),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      color: Colors.grey[300],
                    ),
                    child: Text(
                      categoryProvider.imageUploadedUrls.isNotEmpty
                          ? LocaleKeys.uploadMoreImages.tr()
                          : LocaleKeys.uploadImage.tr(),
                      style: TextStyle(
                          color: blackColor, fontSize: MediaQuery.of(context).size.height*0.022),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                categoryProvider.imageUploadedUrls.isNotEmpty
                    ? GridView.builder(
                        shrinkWrap: true,
                        itemCount: categoryProvider.imageUploadedUrls.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 5,
                                mainAxisSpacing: 5),
                        itemBuilder: (BuildContext context, int index) {
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                      image: NetworkImage(
                                          categoryProvider.imageUploadedUrls[
                                              index]),
                                      fit: BoxFit.cover),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: InkWell(
                                  onTap: () {
                                    categoryProvider.imageUploadedUrls
                                        .removeAt(index);
                                    setState(() {});
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          );

                        })
                    : const SizedBox(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
