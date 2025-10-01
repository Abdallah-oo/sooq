import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market_salla/screens/Registration/login.dart';
import 'package:market_salla/screens/routing/main_screen.dart';
import 'package:market_salla/shared/snackbar.dart';
class Verifyemail extends StatefulWidget {
  const Verifyemail({super.key});

  @override
  State<Verifyemail> createState() => _VerifyemailState();
}
class _VerifyemailState extends State<Verifyemail> {
  final emailcontroller = TextEditingController();
  bool isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;
  sendVerificationEmail() async {
    try {
      await FirebaseAuth.instance.currentUser!.sendEmailVerification();
      if (mounted) {
        setState(() {
          canResendEmail = false;
        });
      }
      await Future.delayed(const Duration(seconds: 5));
      if (mounted) {
        setState(() {
          canResendEmail = true;
        });
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, 'ERROR => ${e.toString()}');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
        // when we click on the link that existed on yahoo
        if (mounted) {
          await FirebaseAuth.instance.currentUser!.reload();
          setState(() {
            isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
          });
        }

        // is email verified or not (clicked on the link or not) (true or false)
        if (mounted) {
          if (isEmailVerified) {
            timer.cancel();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    emailcontroller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isEmailVerified
        ? const MainScreen()
        : Scaffold(
            backgroundColor: const Color.fromARGB(255, 0, 0, 0),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              systemOverlayStyle: SystemUiOverlayStyle.light,
              elevation: 0,
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
                        child: Text(
                          'we send link to your email address',
                          style: TextStyle(
                            fontSize: 22,
                            color: Color.fromARGB(255, 252, 252, 252),
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 50),
                      canResendEmail
                          ? ElevatedButton(
                              onPressed: () {
                                canResendEmail ? sendVerificationEmail() : null;
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
                                    borderRadius: BorderRadiusGeometry.circular(
                                      11,
                                    ),
                                  ),
                                ),
                              ),

                              child: const Text(
                                'Resend Email',
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Waiting',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 5),
                                CupertinoActivityIndicator(
                                  color: Colors.white,
                                  radius: 18,
                                ),
                              ],
                            ),
                      const SizedBox(height: 5),
                      TextButton(
                        onPressed: () {
                          FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Login(),
                            ),
                          );
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 180, 8, 8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }
}
