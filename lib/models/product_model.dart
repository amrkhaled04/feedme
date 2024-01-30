import 'package:bechdal_app/models/search_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Products extends SearchModel{
  String? title;
  String? description;
  String? category;
  String? subcategory;
  String? price;
  num? postDate;
  @override
  DocumentSnapshot? document;
  Products(
      {this.title,
      this.description,
      this.category,
      this.subcategory,
      this.price,
      this.postDate,
      this.document});
}
