import 'package:completion_proj/screens/auth/sign_up_screen.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:quickalert/models/quickalert_type.dart';
import 'package:quickalert/widgets/quickalert_dialog.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final emailCtr = TextEditingController();
  final passwordCtr = TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool isShow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 239, 244, 248),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisAlignment: .center,
            crossAxisAlignment: .start,
            mainAxisSize: .max,
            children: [
              Text(
                'Sign in',
                style: TextStyle(fontSize: 28, fontWeight: .bold),
              ),
              Center(
                child: Container(
                  padding: const .all(22),
                  margin: const .only(bottom: 20, top: 20),
                  decoration: const BoxDecoration(
                    borderRadius: .all(Radius.circular(16)),
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
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      const Text(
                        "Email address",
                        style: TextStyle(fontWeight: .w500),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: emailCtr,
                        decoration: inputStyle('name@example.com'),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "* Email is required.";
                          } else if (!EmailValidator.validate(value)) {
                            return '* Provide a valid email.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Password",
                        style: TextStyle(fontWeight: .w500),
                      ),
                      const SizedBox(height: 5),
                      TextFormField(
                        controller: passwordCtr,
                        obscureText: !isShow,
                        decoration: inputStyle('*******', isPassword: true),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "* Password is required.";
                          } else if (value.trim().length < 6) {
                            return "* Password should be atleast 6 characters.";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: .infinity,
                        child: ElevatedButton(
                          onPressed: signIn,
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
                          child: const Text('Sign in'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'Don\'t have an account? ',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 120, 120, 120),
                            ),
                            children: [
                              TextSpan(
                                text: 'Sign up',
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 62, 143, 243),
                                  fontWeight: FontWeight.w600,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const SignUpScreen(),
                                      ),
                                    );
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
  InputDecoration inputStyle(String hintText, {isPassword = false}) {
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
        child: Icon(
          isPassword ? Icons.lock_outline_rounded : Icons.email_outlined,
        ),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 32),
      hintStyle: const TextStyle(
        color: const Color.fromARGB(166, 153, 153, 153),
        fontSize: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          width: .2,
          color: const Color.fromARGB(141, 155, 186, 212),
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

  void signIn() {
    //Validation of textfields if there is no empty or invalid nput
    if (!formKey.currentState!.validate()) {
      return;
    }

    //if pass call firebase
    firebaseSignIn();
  }

  /* 
    actual signing in in firebase using fbase methods
  */
  void firebaseSignIn() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailCtr.text.trim(),
        password: passwordCtr.text.trim(),
      );
    } on FirebaseAuthException catch (ex) {
      // Navigator.pop(context); // Dismiss loading dialog
      var errorMsg = 'An error occurred. Please try again.';
      if (ex.code == 'invalid-credential' ||
          ex.code == 'wrong-password' ||
          ex.code == 'user-not-found') {
        errorMsg = 'Incorrect entered email or password';
      } else if (ex.code == 'user-disabled') {
        errorMsg = 'Your account is disabled.';
      } else if (ex.message != null && ex.message!.isNotEmpty) {
        errorMsg = ex.message!;
      }
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Error',
        text: errorMsg,
      );
    }
  }
}
