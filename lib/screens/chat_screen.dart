import 'dart:async';
import 'package:chat_mobile_app_0/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:intl/intl.dart';

class Chat_Screen extends StatefulWidget {
  static const String screenRoute = 'chat_screen';

  @override
  _Chat_ScreenState createState() {
    return _Chat_ScreenState();
  }
}

class _Chat_ScreenState extends State<Chat_Screen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User signInUser;
  TextEditingController controller = TextEditingController();
  dynamic messages;
  late bool isSender;
  Timer? _timer;
  String? typingId;

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        signInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  void getNotification() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message data: ${message.data}');

      if (message.notification != null) {
        print(
            'Message also contained a notification: ${message.notification!.title}');
      }
    });
  }

  @override
  void initState() {
    getCurrentUser();
    getNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        backgroundColor: Colors.yellow[800],
        title: Row(
          children: [
            Hero(
              tag: 'logo',
              child: Image.asset(
                'images/logo.png',
                height: 45,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            const Text('MassageMe')
          ],
        ),
        actions: [
          Container(
            alignment: AlignmentDirectional.center,
              child: Text(
            '${signInUser.email}',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.blue[800]),
          )),
          IconButton(
            onPressed: () {
              _auth.signOut();
              Navigator.popAndPushNamed(context, Welcome_Screen.screenRoute);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('thank\'s ${signInUser.email} ❤️❤️❤️')));
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder(
                stream: _firestore
                    .collection('messages')
                    .orderBy('time', descending: true)
                    .snapshots(),
                builder: (context, snapShot) {
                  if (snapShot.hasData) {
                    List<dynamic> messages = snapShot.data!.docs as List;
                    return Expanded(
                      child: ListView(
                        reverse: true,
                        padding:
                            EdgeInsets.only(right: 12, left: 12, bottom: 5),
                        children: [
                          for (var item in messages) ...{
                            if (signInUser.email == item['sender']) ...{
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('h:mm a')
                                        .format(
                                          DateTime.fromMicrosecondsSinceEpoch(
                                            item['time'].microsecondsSinceEpoch,
                                          ),
                                        )
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Text(
                                    '    me',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.grey),
                                  ),
                                ],
                              ),
                              BubbleSpecialThree(
                                text: '${item['text']}',
                                isSender: signInUser.email == item['sender']
                                    ? true
                                    : false,
                                color: Colors.blue[800]!,
                                textStyle: TextStyle(
                                  fontSize: 22,
                                  color: Colors.yellow[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            } else ...{
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item['sender']}    ',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Text(
                                    DateFormat('h:mm a')
                                        .format(
                                          DateTime.fromMicrosecondsSinceEpoch(
                                            item['time'].microsecondsSinceEpoch,
                                          ),
                                        )
                                        .toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              BubbleSpecialThree(
                                text: '${item['text']}',
                                isSender: signInUser.email == item['sender']
                                    ? true
                                    : false,
                                color: Colors.yellow[800]!,
                                textStyle: TextStyle(
                                  fontSize: 22,
                                  color: Colors.blue[800],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            },
                          }
                        ],
                      ),
                    );
                  }
                  return Container();
                }),
            StreamBuilder(
                stream: _firestore.collection('user_typing').snapshots(),
                builder: (context, snapShot) {
                  if (snapShot.hasData) {
                    List<dynamic> users = snapShot.data!.docs;
                    return ListView.builder(
                        reverse: true,
                        shrinkWrap: true,
                        itemCount: users.length,
                        itemBuilder: (context, index) {
                          if (users[index]['user'] != signInUser.email) {
                            return Container(
                                padding: EdgeInsets.only(left: 15),
                                color: Colors.yellow[800],
                                child: Text(
                                    '${users[index]['user']}    is typing'));
                          }
                          return SizedBox();
                        });
                  }
                  return const SizedBox();
                }),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.yellow[800]!,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: (value) async {
                        if (_timer?.isActive ?? false) _timer?.cancel();
                        _timer =
                            Timer(const Duration(milliseconds: 500), () async {
                          if (value.isNotEmpty) {
                            if (typingId == null) {
                              final ref = await _firestore
                                  .collection('user_typing')
                                  .add({'user': signInUser.email});
                              typingId = ref.id;
                            }
                          } else if (controller.text.isEmpty) {
                            _firestore
                                .collection('user_typing')
                                .doc(typingId)
                                .delete();
                            typingId = null;
                          }
                        });
                      },
                      decoration: const InputDecoration(
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          _firestore.collection('messages').add({
                            'text': controller.text,
                            'sender': signInUser.email,
                            'time': DateTime.now()
                          });
                        }
                        controller.text = '';
                        if (typingId != null) {
                          _firestore
                              .collection('typing_users')
                              .doc(typingId)
                              .delete();
                          typingId = null;
                        }
                      },
                      icon: Icon(
                        Icons.send_outlined,
                        color: Colors.blue[800],
                        size: 30,
                      )),
                  SizedBox(
                    width: 13,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
