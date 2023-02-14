import 'package:chat_mobile_app_0/screens/chat_screen.dart';
import 'package:chat_mobile_app_0/screens/registration_screen.dart';
import 'package:chat_mobile_app_0/screens/welcome_screen.dart';
import 'package:chat_mobile_app_0/widgets/my_button.dart';
import 'package:chat_mobile_app_0/widgets/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Signin_Screen extends StatefulWidget {
  static const String screenRoute = 'signin_screen';

  Signin_Screen({Key? key}) : super(key: key);

  @override
  _Signin_ScreenState createState() {
    return _Signin_ScreenState();
  }
}

class _Signin_ScreenState extends State<Signin_Screen> {
  final _auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();
  late String _email;
  late String _password;
  bool isloaded = false;

  void signIn() async {
    GoogleSignInAccount? account = await googleSignIn.signIn();
    GoogleSignInAuthentication authentication = await account!.authentication;
    AuthCredential credential = GoogleAuthProvider.credential(
        idToken: authentication.idToken,
        accessToken: authentication.accessToken);
    _auth.signInWithCredential(credential);
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isloaded,
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 130),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Hero(
                  tag: 'logo',
                  child: SizedBox(
                    height: 180,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
                TextField(
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (value) {
                    _email = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter you\'r Email',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.yellow[800]!, width: 1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(13))),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blue[800]!, width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(13))),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextField(
                  obscureText: true,
                  onChanged: (value) {
                    _password = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Enter you\'r Password',
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 20),
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(13))),
                    enabledBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.yellow[800]!, width: 1),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(13))),
                    focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.blue[800]!, width: 2),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(13))),
                  ),
                ),
                const SizedBox(
                  height: 13,
                ),
                My_Button(
                  color: Colors.yellow[800]!,
                  title: 'Sign In',
                  onPressed: () async {
                    setState(() {
                      isloaded = true;
                    });
                    try {
                      final user = await _auth.signInWithEmailAndPassword(
                          email: _email, password: _password);
                      if (user != null) {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          Chat_Screen.screenRoute,
                          (route) => false,
                        );
                      }
                      setState(() {
                        isloaded = false;
                      });
                    } catch (e) {
                      print(e);
                    }
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don\'t have an account?',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                            context, Registration_Screen.screenRoute);
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 60,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      Welcome_Screen.screenRoute,
                    );
                  },
                  icon: const Icon(
                    Icons.home,
                  ),
                  splashColor: Colors.yellow[800],
                  color: Colors.blue[800],
                  iconSize: 70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
