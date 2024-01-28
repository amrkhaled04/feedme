import 'package:flutter/material.dart';
// import 'package:legacy_progress_dialog/legacy_progress_dialog.dart';

import '../constants/colors.dart';

class BottomNavigationWidget extends StatelessWidget {
  final bool validator;
  final Function()? onPressed;
  final String buttonText;
  // final ProgressDialog? progressDialog;
  const BottomNavigationWidget({
    Key? key,
    required this.validator,
    this.onPressed,
    required this.buttonText,
    // this.progressDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: whiteColor,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*0.02, vertical: MediaQuery.of(context).size.height*0.025),
          child: AbsorbPointer(
            absorbing: !validator,
            child: ClipRRect(
              clipBehavior: Clip.antiAlias,
              borderRadius: BorderRadius.circular(15),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: validator
                        ? MaterialStateProperty.all(blackColor)
                        : MaterialStateProperty.all(disabledColor)),
                onPressed: onPressed,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height*0.02),
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: whiteColor,
                      fontSize: MediaQuery.of(context).size.height*0.028,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
