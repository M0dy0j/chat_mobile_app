import 'package:chat_mobile_app_0/screens/chat_screen.dart';
import 'package:chat_mobile_app_0/screens/signin_screen.dart';
import 'package:chat_mobile_app_0/screens/welcome_screen.dart';
import 'package:chat_mobile_app_0/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Registration_Screen extends StatefulWidget {
  static const String screenRoute = 'registration_screen';

  Registration_Screen({Key? key}) : super(key: key);

  @override
  _Registration_ScreenState createState() {
    return _Registration_ScreenState();
  }
}

class _Registration_ScreenState extends State<Registration_Screen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  bool isloaded = false;

  void getLoginStates() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        print('User is currently signed out!');
      } else {
        print('User is signed in!');
      }
    });
  }

  @override
  void initState() {
    getLoginStates();
    super.initState();
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
                  color: Colors.blue[800]!,
                  title: 'Register',
                  onPressed: () async {
                    setState(() {
                      isloaded = true;
                    });
                    try {
                      final newUser =
                          await _auth.createUserWithEmailAndPassword(
                              email: _email, password: _password);
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Chat_Screen.screenRoute,
                        (route) => false,
                      );
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
                            context, Signin_Screen.screenRoute);
                      },
                      child: Text(
                        'Sign In',
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
                  splashColor: Colors.blue[800],
                  color: Colors.yellow[800],
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
