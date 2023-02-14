import 'package:chat_mobile_app_0/screens/chat_screen.dart';
import 'package:chat_mobile_app_0/screens/registration_screen.dart';
import 'package:chat_mobile_app_0/screens/signin_screen.dart';
import 'package:chat_mobile_app_0/widgets/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class Welcome_Screen extends StatefulWidget {
  static const String screenRoute = 'welcome_screen';

  Welcome_Screen({Key? key}) : super(key: key);

  @override
  _Welcome_ScreenState createState() {
    return _Welcome_ScreenState();
  }
}

class _Welcome_ScreenState extends State<Welcome_Screen>
    with SingleTickerProviderStateMixin {

  bool isloaded = false;
  Duration duration = Duration(seconds: 2);

  @override
  void initState() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if(user != null){
        Navigator.pushNamedAndRemoveUntil(context, Chat_Screen.screenRoute, (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: isloaded,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                children: [
                  Hero(
                    tag: 'logo',
                    child: SizedBox(
                      height: 180,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                  const Text(
                    'Chat App',
                    style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Color(0xff2e386b)),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              My_Button(
                color: Colors.yellow[800]!,
                title: 'Sign in',
                onPressed: () {
                  setState(() {
                    isloaded = true;
                  });
                  Navigator.pushNamed(context, Signin_Screen.screenRoute);
                  setState(() {
                    isloaded = false;
                  });
                },
              ),
              My_Button(
                color: Colors.blue[800]!,
                title: 'Register',
                onPressed: () {
                  setState(() {
                    isloaded = true;
                  });
                  Navigator.pushNamed(context, Registration_Screen.screenRoute);
                  setState(() {
                    isloaded = false;
                  });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
