
import 'dart:io';

import 'package:bechdal_app/services/user.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../services/auth.dart';
import '../utils.dart';

class ChangeProfilePhoto extends StatefulWidget {
  const ChangeProfilePhoto({Key? key}) : super(key: key);

  @override
  _ChangeProfilePhotoState createState() => _ChangeProfilePhotoState();
}

class _ChangeProfilePhotoState extends State<ChangeProfilePhoto> {

  Auth auth = Auth();

  UserService firebaseUser = UserService();





  @override
  Widget build(BuildContext context) {

    // return 2 circles, one to delete the current profile photo, and one to add a new one

    return SizedBox(


      height: MediaQuery.of(context).size.height * 0.25,

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Profile Photo'
          , style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold
          ),
          ),
          const SizedBox(height: 20,),
          Row(


            mainAxisAlignment: MainAxisAlignment.spaceEvenly,

            crossAxisAlignment: CrossAxisAlignment.center,





            children: [
              Column(



                children: [
                  GestureDetector(
                    onTap: () async {
                        deleteProfilePhoto(context, firebaseUser.user!.photoURL.toString());
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        CupertinoIcons.delete,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Text('Delete'),
                ],
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () async {


                      FilePickerResult? result = await FilePicker.platform.pickFiles(
                        type: FileType.custom,
                        allowedExtensions: ['jpg', 'png', 'jpeg'],
                      );

                      if (result != null) {
                        String filePath = result.files.single.path.toString();
                        String fileName = DateTime.now().microsecondsSinceEpoch.toString();

                        File file = File(filePath);

                        // upload the file to firebase storage

                        FirebaseStorage.instance.ref('profile_images/$fileName').putFile(file).then((value) async {
                          String downloadUrl = await FirebaseStorage.instance.ref('profile_images/$fileName').getDownloadURL();
                          await firebaseUser.updateProfilePicture(context, downloadUrl);
                          Navigator.pop(context);
                        });

                      }



                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(
                        CupertinoIcons.pencil,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Text('Change'),
                ],
              ),
            ],
          )
        ]
      )


    );



  }


}