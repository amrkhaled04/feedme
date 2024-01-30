import 'package:bechdal_app/constants/colors.dart';
import 'package:bechdal_app/constants/validators.dart';
import 'package:bechdal_app/constants/widgets.dart';
import 'package:bechdal_app/extensions.dart';
import 'package:bechdal_app/l10n/locale_keys.g.dart';
import 'package:bechdal_app/screens/auth/register_screen.dart';
import 'package:bechdal_app/services/auth.dart';
import 'package:bechdal_app/services/user.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LogInForm extends StatefulWidget {
  const LogInForm({
    Key? key,
  }) : super(key: key);

  @override
  State<LogInForm> createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  Auth authService = Auth();

  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailNode;
  late final FocusNode _passwordNode;
  final _formKey = GlobalKey<FormState>();
  bool obsecure = true;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailNode = FocusNode();
    _passwordNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  focusNode: _emailNode,
                  controller: _emailController,
                  validator: (value) {
                    return validateEmail(
                        value, EmailValidator.validate(_emailController.text),context.locale.toString().contains('ar'));
                  },
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: LocaleKeys.email.tr(),
                      labelStyle: TextStyle(
                        fontSize: MediaQuery.of(context).size.width*0.04
                      ),
                      hintText: LocaleKeys.emailHint.tr(),
                      hintStyle: TextStyle(
                        color: greyColor,
                        fontSize: MediaQuery.of(context).size.width*0.04,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                const SizedBox(
                  height: 15,
                ),
                TextFormField(
                  focusNode: _passwordNode,
                  controller: _passwordController,
                  validator: (value) {
                    return validatePassword(value, _passwordController.text, context.locale.toString().contains('ar'));
                  },
                  obscureText: obsecure,
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
                        fontSize: MediaQuery.of(context).size.width*0.04
                      ),
                      hintText: LocaleKeys.passwordHint.tr(),
                      hintStyle: TextStyle(
                        color: greyColor,
                        fontSize: MediaQuery.of(context).size.width*0.04,
                      ),
                      contentPadding: const EdgeInsets.all(20),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                ),
                // Container(
                //   alignment: Alignment.centerRight,
                //   padding: const EdgeInsets.only(
                //     top: 10,
                //     right: 5,
                //   ),
                //   child: InkWell(
                //     onTap: () {
                //       Navigator.pushNamed(
                //           context, ResetPasswordScreen.screenId);
                //     },
                //     child: Text(
                //       LocaleKeys.forgotPassword.tr(),
                //       style: TextStyle(
                //         color: blackColor,
                //         fontSize: 13,
                //         fontWeight: FontWeight.bold,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(
                  height: 50,
                ),
                roundedButton(
                    context: context,
                    bgColor: '#80cf70'.toColor(),
                    borderColor: '#80cf70'.toColor(),
                    text: LocaleKeys.login.tr(),
                    textColor: whiteColor,
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await authService.getAdminCredentialEmailAndPassword(
                            context: context,
                            email: _emailController.text,
                            password: _passwordController.text,
                            isLoginUser: true);

                        final SharedPreferences prefs = await _prefs;

                        prefs.setBool('guestUser', false);

                        UserService.guestUser = false;




                      }
                    }),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 20,
        ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(LocaleKeys.dontHaveAccount.tr(),
                style: TextStyle(
                  fontFamily: 'Oswald',
                  fontSize: MediaQuery.of(context).size.width*0.04,
                  color: greyColor,
                ),),
              GestureDetector(
                onTap: (){
                  Navigator.pushNamed(context, RegisterScreen.screenId);
                },
                child: Text(' ${LocaleKeys.createAccount.tr()}',
                  style: TextStyle(
                    fontFamily: 'Oswald',
                    decoration: TextDecoration.underline,
                    fontSize: MediaQuery.of(context).size.width*0.04,
                    color: secondaryColor,
                  ),
                ),
              )
            ],

          ),
        // LoginInButtons(),
      ],
    );
  }
}
