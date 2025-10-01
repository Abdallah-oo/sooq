import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_salla/provider/googlelogin.dart';
import 'package:market_salla/screens/Registration/forgetpassword.dart';
import 'package:market_salla/screens/Registration/signup.dart';
import 'package:market_salla/screens/Registration/verifyemail.dart';
import 'package:market_salla/shared/snackbar.dart';
import 'package:market_salla/widgets/registration/field.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isloading = false;
  bool isvisable = false;
  final emailcontroller = TextEditingController();
  final passwordcontroller = TextEditingController();
  login() async {
    setState(() {
      isloading = true;
    });
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailcontroller.text,
        password: passwordcontroller.text,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Verifyemail()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        if (e.code == 'user-not-found') {
          showSnackBar(context, 'No user found for that email.');
        } else if (e.code == 'wrong-password') {
          showSnackBar(context, 'Wrong password provided for that user.');
        } else {
          showSnackBar(context, 'ERROR!...');
        }
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          isloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final instance = Provider.of<GoogleSignInProvider>(context);
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 0, 0, 0),
          systemOverlayStyle: SystemUiOverlayStyle.light,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40),
                child: FractionallySizedBox(
                  widthFactor: 0.3,
                  child: Center(child: Image.asset('assets/img/welcom.png')),
                ),
              ),
              const SizedBox(height: 50),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(40),
                      topEnd: Radius.circular(40),
                    ),
                    color: Color.fromARGB(255, 5, 71, 6),
                  ),
                  child: Padding(
                    padding: const EdgeInsetsGeometry.fromLTRB(30, 40, 30, 20),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text(
                            'Welcom back !',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),

                          Fieldswidget(
                            controll: emailcontroller,
                            secure: false,
                            hint: 'Email',
                            keyboard: TextInputType.emailAddress,
                            shape: const Icon(Icons.email),
                          ),
                          const SizedBox(height: 20),
                          Fieldswidget(
                            controll: passwordcontroller,
                            secure: isvisable ? false : true,
                            hint: 'password',
                            keyboard: TextInputType.text,
                            shape: const Icon(Icons.lock),
                            lasticon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isvisable = !isvisable;
                                });
                              },
                              child: isvisable
                                  ? const Icon(Icons.visibility)
                                  : const Icon(Icons.visibility_off),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Padding(
                            padding: const EdgeInsets.only(right: 5),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const Forgetpassword(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forget password ?',
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 232, 241, 144),
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),
                          isloading
                              ? const CupertinoActivityIndicator(
                                  color: Colors.white,
                                  radius: 18,
                                )
                              : ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all(
                                      const Color.fromARGB(255, 255, 255, 255),
                                    ),
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    padding: WidgetStateProperty.all(
                                      const EdgeInsets.fromLTRB(0, 5, 0, 5),
                                    ),
                                  ),
                                  onPressed: () {
                                    login();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Log In',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            44,
                                            43,
                                            43,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          const SizedBox(height: 65),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Color.fromARGB(255, 133, 129, 129),
                                  thickness: 0.7,
                                ),
                              ),
                              SizedBox(width: 3),
                              Text(
                                ' OR ',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(width: 3),
                              Expanded(
                                child: Divider(
                                  color: Color.fromARGB(255, 133, 129, 129),
                                  thickness: 0.7,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    instance.googlelogin();
                                  },
                                  child: SvgPicture.asset(
                                    'assets/img/loginmethods/icons8-google.svg',
                                    height: 35,
                                  ),
                                ),
                                SvgPicture.asset(
                                  'assets/img/loginmethods/icons8-facebook.svg',
                                  height: 35,
                                ),
                                SvgPicture.asset(
                                  'assets/img/loginmethods/icons8-telegram.svg',
                                  height: 35,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Do not have an account?',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color.fromARGB(221, 245, 245, 245),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const Signup(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
