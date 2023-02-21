import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:chat_mobile_app_0/screens/notification_screen.dart';
import 'package:chat_mobile_app_0/screens/welcome_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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
  List<RemoteNotification?> notifications = [];
  String token = '';

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
      if (message.notification != null) {
        setState(() {
          notifications.add(message.notification);
        });
      }
    });
  }

  Future<void> sendNotification(String title, String body) async {
    http.Response response = await http.post(
        Uri.parse(
            'https://fcm.googleapis.com/v1/projects/messageme-a3dd7/messages:send'),
        headers: {
          HttpHeaders.contentTypeHeader: 'application/json',
          HttpHeaders.authorizationHeader: 'Bearer $token'
        },
        body: jsonEncode({
          "message": {
            "topic": "primitive",
            "notification": {"title": title, "body": body},
          }
        }));
  }

  Future<AccessToken> getAccessToken() async {
    final serviceAccount = await rootBundle.loadString(
        'assets/messageme-a3dd7-firebase-adminsdk-hcfai-bfd7fc289b.json');
    final data = await jsonDecode(serviceAccount);
    final accountCredentials = ServiceAccountCredentials.fromJson({
      "private_key_id": data['private_key_id'],
      "private_key": data['private_key'],
      "client_email": data['client_email'],
      "client_id": data['client_id'],
      "type": data['type']
    });
    final scopes = ["https://www.googleapis.com/auth/firebase.messaging"];
    final AuthClient authClient = await clientViaServiceAccount(
      accountCredentials,
      scopes,
    )
      ..close();

    return authClient.credentials.accessToken;
  }

  @override
  void initState() {
    getCurrentUser();
    getNotification();
    getAccessToken().then((value) => token = value.data);
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
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(
                      context, Notification_Screen.screenRoute,
                      arguments: notifications)
                  .then(
                (value) => setState(() {
                  notifications.clear();
                }),
              );
            },
            child: Stack(
              children: [
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.notifications,
                    color: Colors.blue[800],
                    size: 25,
                  ),
                ),
                notifications.isNotEmpty
                    ? Container(
                        margin:
                            EdgeInsets.all(notifications.length > 9 ? 5 : 8.5),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        child: Text(
                          '${notifications.isEmpty ? '' : notifications.length > 9 ? '+9' : notifications.length}',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      )
                    : Container()
              ],
            ),
          ),
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
                        padding: const EdgeInsets.only(
                            right: 12, left: 12, bottom: 5),
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
                                    style: const TextStyle(
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
                                padding: const EdgeInsets.only(left: 15),
                                color: Colors.yellow[800],
                                child: Text(
                                    '${users[index]['user']}    is typing'));
                          }
                          return const SizedBox();
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
                            Timer(const Duration(milliseconds: 520), () async {
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
                        sendNotification('${signInUser.email}', '${controller.text}');
                        controller.text = '';
                        Future.delayed(const Duration(seconds: 1), () {
                          if (typingId != null) {
                            _firestore
                                .collection('user_typing')
                                .doc(typingId)
                                .delete();
                            typingId = null;
                          }
                        });
                      },
                      icon: Icon(
                        Icons.send_outlined,
                        color: Colors.blue[800],
                        size: 30,
                      )),
                  const SizedBox(
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
