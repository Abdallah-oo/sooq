import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market_salla/screens/Registration/login.dart';
import 'package:market_salla/shared/snackbar.dart';
import 'package:market_salla/widgets/registration/field.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  final _formKey = GlobalKey<FormState>();
  final emailcontroller = TextEditingController();
  bool status = true;
  restpass() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailcontroller.text,
      );
      if (mounted) {
        showSnackBar(context, 'check your email to reset password.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    } finally {
      setState(() {
        status = false;
      });
    }
  }

  @override
  void dispose() {
    emailcontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: status
              ? Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Enter your email to reset password',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Padding(
                          padding: const EdgeInsetsGeometry.symmetric(
                            horizontal: 20,
                          ),
                          child: Fieldswidget(
                            validation: (value) {
                              return value != null &&
                                      !EmailValidator.validate(value)
                                  ? 'Enter a valid email'
                                  : null;
                            },
                            secure: false,
                            controll: emailcontroller,
                            hint: 'Email',
                            keyboard: TextInputType.emailAddress,
                            shape: const Icon(Icons.email),
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              status = false;
                            });
                            restpass();
                          } else {
                            showSnackBar(context, 'Invalid Email or Pasword');
                          }
                        },
                        style: ButtonStyle(
                          padding: WidgetStateProperty.all(
                            const EdgeInsets.fromLTRB(13, 10, 13, 10),
                          ),
                          backgroundColor: WidgetStateProperty.all(
                            const Color.fromARGB(255, 4, 85, 11),
                          ),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadiusGeometry.circular(11),
                            ),
                          ),
                        ),

                        child: const Text(
                          'RESET',
                          style: TextStyle(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : const CupertinoActivityIndicator(
                  color: Colors.white,
                  radius: 18,
                ),
        ),
      ),
    );
  }
}
