import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:todo/Views/Login.dart';

import '../main.dart';
import 'LoginController.dart';

class DashboardController extends GetxController {
  int completedTaskCount = 0;
  var title;
  var documentId;
  var desc;
  var date;
  var priority;
  final firestore = FirebaseFirestore.instance;
  var loggedInUser;
  bool completed = false;

  LoginController _loginController = Get.put(LoginController());
  var docIdLocal;
  var user;

  void showNotification() {
    flutterLocalNotificationsPlugin.show(
      0,
      "Testing",
      "Test going well",
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          channel.description,
          importance: Importance.high,
          color: Colors.blue,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: IOSNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          subtitle: 'Data',
        ),
      ),
    );
  }

  getUpdatedTaskInfo() {
    firestore
        .collection("Users/" + docIdLocal + "/Tasks/")
        .where('currentStatus', isEqualTo: true)
        .get()
        .then((value) {
      completedTaskCount = value.size;
    });
  }

  @override
  void onInit() {
    print(_loginController.docId);
    print(MyApp.documentId);
    MyApp.documentId == null
        ? docIdLocal = _loginController.docId
        : docIdLocal = MyApp.documentId;

    MyApp.userFirstName == null
        ? user = _loginController.name
        : user = MyApp.userFirstName;
    getUpdatedTaskInfo();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channel.description,
              color: Colors.blue,
              playSound: true,
              icon: '@mipmap/ic_launcher',
            ),
            iOS: IOSNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('New event');
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        Get.dialog(AlertDialog(
          title: Text(notification.title.toString()),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.body.toString(),
                ),
              ],
            ),
          ),
        ));
      }
    });
    super.onInit();
  }

  onLogout() async {
    await MyApp.prefs.remove("email");
    await MyApp.prefs.remove("docId");
    await MyApp.prefs.remove("userFirstName");

    await FirebaseAuth.instance.signOut();
    Get.offAll(() => LogInScreen());
  }
}
