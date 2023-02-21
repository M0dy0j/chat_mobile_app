import 'package:chat_mobile_app_0/screens/chat_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Notification_Screen extends StatelessWidget {
  static const String screenRoute = 'notification_screen';

  const Notification_Screen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    List<RemoteNotification?> notifications =
        ModalRoute.of(context)!.settings.arguments as List<RemoteNotification?>;
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
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
            const Text('Notifications')
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacementNamed(
                    context, Chat_Screen.screenRoute,);
              },
              icon: Icon(
                Icons.chat,
                color: Colors.blue[800],
              )),
          SizedBox(width: 10,),
        ],
      ),
      body: notifications.isNotEmpty
          ? SafeArea(
              child: ListView.builder(
                padding: EdgeInsets.all(10),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  if (notifications[index] != null) {
                    return Container(
                      color: Colors.black.withOpacity(.1),
                      margin: EdgeInsets.all(5),
                      child: ListTile(
                        title: Row(
                          children: [
                            // if(notifications.){};
                            Text('message from : ', style: TextStyle(color: Colors.yellow[800], fontWeight: FontWeight.w600),),
                            Text('${notifications[index]?.title}', style: TextStyle(color: Colors.blue[800],fontWeight: FontWeight.w600),),
                          ],
                        ),
                        subtitle: Text('${notifications[index]?.body}', style: TextStyle(fontWeight: FontWeight.w500),),
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            )
          : Center(
              child: Text(
                'There is no notifications',
                style: TextStyle(fontSize: 20,),
              ),
            ),
    );
  }
}
