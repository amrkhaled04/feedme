import 'package:bechdal_app/models/search_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Sellers extends SearchModel{
  String? name;

  double rating = 0;

  @override
  DocumentSnapshot? document;
  Sellers(
      {
        required this.name,
        required this.rating,
        required this.document
      });
}
