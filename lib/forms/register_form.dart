import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/validators.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/l10n/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/auth.dart';
import '../services/user.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({
    Key? key,
  }) : super(key: key);

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}
String phoneNum ='';

class _RegisterFormState extends State<RegisterForm> {
  bool obsecure = true;
  Auth authService = Auth();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final TextEditingController _phoneNumberController;
  late final FocusNode _firstNameNode;
  late final FocusNode _lastNameNode;
  late final FocusNode _emailNode;
  late final FocusNode _passwordNode;
  late final FocusNode _confirmPasswordNode;
  final _formKey = GlobalKey<FormState>();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _firstNameNode = FocusNode();
    _lastNameNode = FocusNode();
    _emailNode = FocusNode();
    _passwordNode = FocusNode();
    _confirmPasswordNode = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameNode.dispose();
    _lastNameNode.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    _confirmPasswordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: '#f9fcf7'.toColor(),
      ),
      height: MediaQuery.of(context).size.height - 220,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextFormField(
                          focusNode: _firstNameNode,
                          validator: (value) {
                            return checkNullEmptyValidation(
                                value, LocaleKeys.firstName.tr(), context.locale.toString().contains('ar'));
                          },
                          controller: _firstNameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              labelText: LocaleKeys.firstName.tr(),
                              labelStyle: TextStyle(
                                color: greyColor,
                                fontSize: MediaQuery.of(context).size.width*0.04,
                              ),
                              hintText: LocaleKeys.firstNameHint.tr(),
                              hintStyle: TextStyle(
                                color: greyColor,
                                fontSize: MediaQuery.of(context).size.width*0.04,
                              ),
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: TextFormField(
                          focusNode: _lastNameNode,
                          validator: (value) {
                            return checkNullEmptyValidation(value, LocaleKeys.lastName.tr(), context.locale.toString().contains('ar') );
                          },
                          controller: _lastNameController,
                          keyboardType: TextInputType.name,
                          decoration: InputDecoration(
                              labelText: LocaleKeys.lastName.tr(),
                              labelStyle: TextStyle(
                                color: greyColor,
                                fontSize: MediaQuery.of(context).size.width*0.04,
                              ),
                              hintText: LocaleKeys.lastNameHint.tr(),
                              hintStyle: TextStyle(
                                color: greyColor,
                                fontSize: MediaQuery.of(context).size.width*0.04,
                              ),
                              contentPadding: const EdgeInsets.all(15),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Align(
                        alignment: const AlignmentDirectional(0.0, 0.0),
                        child: IntlPhoneField(
                          keyboardType: const TextInputType.numberWithOptions(),
                          controller: _phoneNumberController,
                          decoration: InputDecoration(
                            labelText: LocaleKeys.phoneNumber.tr(),
                            enabledBorder: OutlineInputBorder(
                              // borderSide: BorderSide(
                              //   color: FlutterFlowTheme.of(context).alternate,
                              //   width: 2.0,
                              // ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              // borderSide: BorderSide(
                              //   color: FlutterFlowTheme.of(context).primary,
                              //   width: 2.0,
                              // ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            errorBorder: OutlineInputBorder(
                              // borderSide: BorderSide(
                              //   color: FlutterFlowTheme.of(context).error,
                              //   width: 2.0,
                              // ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                              //   color: FlutterFlowTheme.of(context).error,
                              //   width: 2.0,
                              ),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          initialCountryCode: 'EG',
                          onChanged: (phone) {
                            phoneNum = phone.completeNumber;
                            print((phone.completeNumber).replaceRange(0, 3, '0'));
                          },
                        )),
                  ),
                  TextFormField(
                    focusNode: _emailNode,
                    controller: _emailController,
                    validator: (value) {
                      return validateEmail(value,
                          EmailValidator.validate(_emailController.text),context.locale.toString().contains('ar'));
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                        labelText: LocaleKeys.email.tr(),
                        labelStyle: TextStyle(
                          color: greyColor,
                          fontSize: MediaQuery.of(context).size.width*0.04,
                        ),
                        hintText: LocaleKeys.emailHint.tr(),
                        hintStyle: TextStyle(
                          color: greyColor,
                          fontSize: MediaQuery.of(context).size.width*0.04,
                        ),
                        contentPadding: const EdgeInsets.all(15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    focusNode: _passwordNode,
                    obscureText: obsecure,
                    controller: _passwordController,
                    validator: (value) {
                      return validatePassword(value, _passwordController.text, context.locale.toString().contains('ar'));
                    },
                    decoration: InputDecoration(
                        suffixIcon: IconButton(
                            icon: Icon(
                              Icons.remove_red_eye_outlined,
                              color: obsecure ? greyColor : blackColor,
                            ),
                            onPressed: () {
                              setState(() {
                                obsecure = !obsecure;
                              });
                            }),
                        labelText: LocaleKeys.password.tr(),
                        labelStyle: TextStyle(
                          color: greyColor,
                          fontSize: MediaQuery.of(context).size.width*0.04,
                        ),
                        hintText: LocaleKeys.passwordHint.tr(),
                        hintStyle: TextStyle(
                          color: greyColor,
                          fontSize: MediaQuery.of(context).size.width*0.04,
                        ),
                        contentPadding: const EdgeInsets.all(15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFormField(
                    focusNode: _confirmPasswordNode,
                    obscureText: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      return validateSamePassword(
                          value, _passwordController.text, context.locale.toString().contains('ar'));
                    },
                    decoration: InputDecoration(
                        labelText: LocaleKeys.confirmPassword.tr(),
                        labelStyle: TextStyle(
                          color: greyColor,
                          fontSize: MediaQuery.of(context).size.width*0.04,
                        ),
                        hintText: LocaleKeys.confirmPasswordHint.tr(),
                        hintStyle: TextStyle(
                          color: greyColor,
                          fontSize: MediaQuery.of(context).size.width*0.04,
                        ),
                        contentPadding: const EdgeInsets.all(15),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8))),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  roundedButton(
                      context: context,
                      bgColor: '#80cf70'.toColor(),
                      borderColor: '#80cf70'.toColor(),
                      text: LocaleKeys.signUp.tr(),
                      textColor: whiteColor,
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          await authService.getAdminCredentialEmailAndPassword(
                              context: context,
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                              email: _emailController.text,
                              password: _passwordController.text,
                              isLoginUser: false).then((value) async {
                              print('signed up');
                                await authService.getAdminCredentialEmailAndPassword(
                                    context: context,
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    isLoginUser: true);

                                final SharedPreferences prefs = await _prefs;

                                prefs.setBool('guestUser', false);

                                UserService.guestUser = false;

                          });
                        }
                      }),
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            child: Text(
              LocaleKeys.signUpConfirm.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: greyColor,
              ),
            ),
          ),
          // const SignUpButtons(),
        ],
      ),
    );
  }
}
