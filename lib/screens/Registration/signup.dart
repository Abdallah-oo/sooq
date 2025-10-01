import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:market_salla/screens/Registration/login.dart';
import 'package:market_salla/shared/snackbar.dart';
import 'package:market_salla/widgets/registration/field.dart';
import 'package:market_salla/widgets/registration/image/pickimage.dart';
import 'package:market_salla/widgets/registration/validation/validatepassword.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final _formKey = GlobalKey<FormState>();
  final emailAddress = TextEditingController();
  final password = TextEditingController();
  final phonecontroller = TextEditingController();
  final namecontroller = TextEditingController();
  final confirmpassword = TextEditingController();
  bool iseightcharcter = false;
  bool special = true;
  bool upper = true;
  bool lower = true;
  bool onenumber = true;
  bool name = true;
  bool phone = true;
  bool checkpass = false;
  bool ismatch = false;
  bool? ispicked;
  bool isloading = false;
  bool isvisable = false;
  String? validationresult;

  signup() async {
    setState(() {
      isloading = true;
    });
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress.text,
        password: password.text,
      );

      // Sign out the user immediately after creation
      await FirebaseAuth.instance.signOut();

      showSnackBar(context, 'Account created successfully! Please log in.');
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(context, 'weak-password');
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, 'email-already-in-use');
      }
    } catch (e) {
      showSnackBar(context, '$e');
    } finally {
      setState(() {
        isloading = false;
      });
    }
  }

  requiredfield(String? value, bool field) {
    if (value == null || value.isEmpty) {
      field = false;
    } else {
      field = true;
    }
    return field
        ? validationresult = null
        : validationresult = 'required field';
  }

  reguralchanges(String? password) {
    if (password != null) {
      if (password.contains(RegExp(r'.{8,}'))) {
        setState(() {
          iseightcharcter = true;
        });
      } else {
        setState(() {
          iseightcharcter = false;
        });
      }

      if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        setState(() {
          special = false;
        });
      } else {
        setState(() {
          special = true;
        });
      }

      if (password.contains(RegExp(r'[A-Z]'))) {
        setState(() {
          upper = false;
        });
      } else {
        setState(() {
          upper = true;
        });
      }

      if (password.contains(RegExp(r'[a-z]'))) {
        setState(() {
          lower = false;
        });
      } else {
        setState(() {
          lower = true;
        });
      }

      if (password.contains(RegExp(r'[0-9]'))) {
        setState(() {
          onenumber = false;
        });
      } else {
        setState(() {
          onenumber = true;
        });
      }
    }
  }

  validpass() {
    if (iseightcharcter == true &&
        special == false &&
        upper == false &&
        lower == false &&
        onenumber == false) {
      checkpass = true;
    } else {
      checkpass = false;
    }
    return checkpass
        ? validationresult = null
        : validationresult = 'required field';
  }

  passwordmatch() {
    if (password.text.isNotEmpty && password.text != '') {
      if (confirmpassword.text.isNotEmpty && confirmpassword.text != '') {
        if (confirmpassword.text == password.text) {
          ismatch = true;
          return validationresult = null;
        } else {
          return validationresult = 'password not match';
        }
      } else {
        return validationresult = 'required field';
      }
    } else {
      return validationresult = 'Enter password first';
    }
  }

  checkallfields() {
    if (_formKey.currentState!.validate() &&
        ispicked == true &&
        ismatch == true &&
        checkpass == true &&
        name == true &&
        phone == true) {
      signup();
    } else {
      showSnackBar(context, 'Invalid input data or field required');
    }
  }

  @override
  void dispose() {
    emailAddress.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //    CupertinoActivityIndicator(color: Colors.white, radius: 15),
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Custompickimage(
              ispicked: (v) {
                ispicked = v;
              },
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
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const Text(
                            'Enter your data',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 40),
                          //name field
                          Fieldswidget(
                            controll: namecontroller,
                            validation: (value) {
                              requiredfield(value, name);
                              return validationresult;
                            },
                            secure: false,
                            hint: 'Name',
                            keyboard: TextInputType.text,
                            shape: const Icon(Icons.person),
                          ),
                          const SizedBox(height: 20),
                          //phone field
                          Fieldswidget(
                            controll: phonecontroller,
                            validation: (value) {
                              requiredfield(value, phone);
                              return validationresult;
                            },
                            secure: false,
                            hint: 'Phone',
                            keyboard: TextInputType.phone,
                            shape: const Icon(Icons.phone),
                          ),
                          const SizedBox(height: 20),
                          //email field
                          Fieldswidget(
                            validation: (value) {
                              return value != null &&
                                      !EmailValidator.validate(value)
                                  ? 'Enter a valid email'
                                  : null;
                            },
                            secure: false,
                            controll: emailAddress,
                            hint: 'Email',
                            keyboard: TextInputType.emailAddress,
                            shape: const Icon(Icons.email),
                          ),
                          const SizedBox(height: 20),
                          //password field
                          Fieldswidget(
                            onchange: (pass) {
                              reguralchanges(pass);
                            },
                            validation: (v) {
                              validpass();
                              return validationresult;
                            },
                            secure: isvisable?false:true,
                            hint: 'password',
                            keyboard: TextInputType.text,
                            controll: password,
                            shape: const Icon(CupertinoIcons.lock_fill),
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
                          const SizedBox(height: 10),
                          //chek if password validate
                          Checkpassword(
                            iseightcharcter,
                            special,
                            upper,
                            lower,
                            onenumber,
                          ),
                          const SizedBox(height: 20),
                          // confirm password
                          Fieldswidget(
                            validation: (v) {
                              passwordmatch();
                              return validationresult;
                            },
                            controll: confirmpassword,
                            secure: true,
                            hint: 'Confirm password',
                            keyboard: TextInputType.text,
                            shape: const Icon(CupertinoIcons.lock_rotation),
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
                                    checkallfields();
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Sign Up',
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
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account?',
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
                                      builder: (context) => const Login(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Log In',
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
            ),
          ],
        ),
      ),
    );
  }
}
