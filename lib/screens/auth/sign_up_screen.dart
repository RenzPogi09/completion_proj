import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:completion_proj/model/user_model.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final usernameCtr = TextEditingController();
  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 244, 248),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Gap(20),
              const Text(
                'Sign up',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(22),
                margin: const EdgeInsets.only(bottom: 20, top: 20),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromARGB(28, 0, 0, 0),
                      blurRadius: 1,
                      spreadRadius: 0.3,
                    ),
                  ],
                ),
                width: double.infinity,
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Username",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Gap(5),
                      TextFormField(
                        controller: usernameCtr,
                        decoration: inputStyle(
                          'Username',
                          icon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "* Username is required.";
                          }
                          return null;
                        },
                      ),
                      const Gap(16),
                      const Text(
                        "Email address",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Gap(5),
                      TextFormField(
                        controller: emailCtr,
                        decoration: inputStyle(
                          'name@example.com',
                          icon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "* Email is required.";
                          } else if (!EmailValidator.validate(value.trim())) {
                            return '* Provide a valid email.';
                          }
                          return null;
                        },
                      ),
                      const Gap(16),
                      const Text(
                        "Password",
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      const Gap(5),
                      TextFormField(
                        controller: passwordCtr,
                        obscureText: !isShow,
                        decoration: inputStyle(
                          '*******',
                          icon: const Icon(Icons.lock_outline),
                          isPassword: true,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "* Password is required.";
                          } else if (value.trim().length < 6) {
                            return "* Password should be atleast 6 characters.";
                          }
                          return null;
                        },
                      ),
                      //-------------------------------
                      const Gap(16),

                      // BUTTON SECTION----------------------------
                      SizedBox(
                        width: .infinity,
                        child: ElevatedButton(
                          onPressed: signUp,
                          style: ElevatedButton.styleFrom(
                            elevation: 2,
                            backgroundColor: const Color.fromARGB(
                              255,
                              62,
                              143,
                              243,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: .circular(10),
                            ),
                          ),
                          child: const Text('Sign up'),
                        ),
                      ),
                      const Gap(10),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 120, 120, 120),
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign in',
                                style: const TextStyle(
                                  color: const Color.fromARGB(
                                    255,
                                    62,
                                    143,
                                    243,
                                  ),
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pop(context);
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //design for textfields
  InputDecoration inputStyle(
    String hintText, {
    bool isPassword = false,
    required Widget icon,
  }) {
    return InputDecoration(
      fillColor: const Color.fromARGB(24, 163, 198, 226),
      filled: true,
      isDense: true,
      hintText: hintText,
      suffixIcon: isPassword
          ? GestureDetector(
              onTap: () => setState(() {
                isShow = !isShow;
              }),
              child: Icon(isShow ? Icons.visibility : Icons.visibility_off),
            )
          : null,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 6.0),
        child: icon,
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 32),
      hintStyle: const TextStyle(
        color: const Color.fromARGB(166, 153, 153, 153),
        fontSize: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          width: .2,
          color: Color.fromARGB(141, 155, 186, 212),
        ),
        borderRadius: .circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          width: .2,
          color: const Color.fromARGB(141, 155, 186, 212),
        ),
        borderRadius: .circular(8),
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(
          width: .2,
          color: const Color.fromARGB(129, 158, 158, 158),
        ),
      ),
    );
  }

  void signUp() {
    //Validation of textfields if there is no empty or invalid input
    if (!formKey.currentState!.validate()) {
      return;
    }

    QuickAlert.show(
      context: context,
      type: .confirm,
      title: 'Are you sure?',
      confirmBtnText: 'Yes',
      cancelBtnText: 'Cancel',
      onConfirmBtnTap: () {
        //if pass call firebase on confirm
        Navigator.pop(context);
        firebaseSignUp();
      },
    );
  }

  /* 
    actual signing up in firebase using fbase methods
  */
  void firebaseSignUp() async {
    try {
      QuickAlert.show(
        context: context,
        type: .loading,
        text: "Saving credentials",
        title: "Creating you account",
      );

      var userCreds = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailCtr.text,
            password: passwordCtr.text,
          );

      final newUser = UserModel(
        uid: userCreds.user!.uid,
        username: usernameCtr.text.trim(),
        email: emailCtr.text.trim(),
        profileImageUrl: '',
      );

      // saving all fields to firestore using toMap
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.uid)
          .set(newUser.toMap());

      //kailangan siya i logout kase nagreread na agad na may user nakalogin
      //kapag gumawa ng acc
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pop(context);
      usernameCtr.clear();
      emailCtr.clear();
      passwordCtr.clear();
      Navigator.pop(context); // Return back to SignInScreen
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! Please sign in.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (ex) {
      Navigator.pop(context);
      if (ex.code == 'email-already-in-use') {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: ex.message,
        );
      } else {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Error',
          text: ex.message,
        );
      }
    }
  }
}
