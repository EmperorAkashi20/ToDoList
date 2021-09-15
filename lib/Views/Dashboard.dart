import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:todo/Controllers/DashboardController.dart';
import 'package:todo/Views/AddTask.dart';
import 'package:todo/Controllers/LoginController.dart';
import 'package:todo/Views/Login.dart';
import 'package:todo/main.dart';

class Dashboard extends StatefulWidget {
  static var title;
  static var documentId;
  static var desc;
  static var date;
  static var priority;
  static var docIdLocal;
  static var user;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  LoginController _loginController = Get.put(LoginController());
  final _firestore = FirebaseFirestore.instance;
  var loggedInUser;
  bool completed = false;
  int completedTaskCount = 0;

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
    _firestore
        .collection("Users/" + Dashboard.docIdLocal + "/Tasks/")
        .where('currentStatus', isEqualTo: true)
        .get()
        .then((value) {
      completedTaskCount = value.size;
    });
  }

  @override
  void initState() {
    MyApp.documentId == '0'
        ? Dashboard.docIdLocal = _loginController.docId
        : Dashboard.docIdLocal = MyApp.documentId;

    MyApp.userFirstName == '0'
        ? Dashboard.user = _loginController.name
        : Dashboard.user = MyApp.userFirstName;
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
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
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
              );
            });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        elevation: 10,
        onPressed: () {
          // showNotification();
          Get.to(() => AddTask());
        },
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () async {
              await MyApp.prefs.remove("email");
              await MyApp.prefs.remove("docId");
              await MyApp.prefs.remove("userFirstName");
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => LogInScreen(),
                ),
              );
            },
            icon: Icon(Icons.power_settings_new, color: Colors.black),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Users/' + Dashboard.docIdLocal + '/Tasks')
            .orderBy('Date')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.data == null) {
            return Container(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LoadingDoubleFlipping.circle(
                      borderColor: Color(0xFF5B16D0),
                      borderSize: 2.0,
                      size: 40.0,
                      backgroundColor: Color(0xFF5B16D0),
                    ),
                    Text('Loading...'),
                  ],
                ),
              ),
            );
          } else if (snapshot.data!.docs.length == 0) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Dashboard.user + "'s Tasks",
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "No Tasks added",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Dashboard.user + "'s Tasks",
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: windowHeight * 0.01,
                    ),
                    Text(
                      'Next 7 Days',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    // Text(
                    //   '$completedTaskCount out of ${snapshot.data!.docs.length}',
                    //   style: TextStyle(
                    //     color: Colors.grey,
                    //     fontSize: 20,
                    //     fontWeight: FontWeight.w500,
                    //   ),
                    // ),
                    // SizedBox(
                    //   height: windowHeight * 0.03,
                    // ),
                    Expanded(
                      child: ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          DateFormat _dateFormat = DateFormat('y-MM-d');
                          String formattedDate =
                              _dateFormat.format(data['Date'].toDate());
                          // if(data['Date'].toDate().isBefore(DateTime.now())){}
                          var diff =
                              data['Date'].toDate().difference(DateTime.now());
                          var a = diff
                              .inDays; // use is for showing the task for next 7 days
                          return Column(
                            children: [
                              if (a < 7)
                                Card(
                                  elevation: 0,
                                  child: ListTile(
                                    leading: data['Priority'] == 'High'
                                        ? Text(
                                            '!!!',
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : data['Priority'] == 'Medium'
                                            ? Text(
                                                '!!',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              )
                                            : Text(
                                                '!',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                    isThreeLine: true,
                                    title: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            data['Title'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              decoration:
                                                  data['currentStatus'] == false
                                                      ? TextDecoration.none
                                                      : TextDecoration
                                                          .lineThrough,
                                            ),
                                          ),
                                          Text(
                                            data['Description'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              decoration:
                                                  data['currentStatus'] == false
                                                      ? TextDecoration.none
                                                      : TextDecoration
                                                          .lineThrough,
                                            ),
                                          ),
                                          // if (data['Date']
                                          //     .toDate()
                                          //     .isBefore(DateTime.now()))
                                          //   Text('Overdue'),
                                        ]),
                                    subtitle: Text(
                                      "$formattedDate * ${data['Priority']}",
                                    ),
                                    trailing: Checkbox(
                                      checkColor: Colors.white,
                                      activeColor: Colors.redAccent,
                                      value: data['currentStatus'],
                                      onChanged: (value) async {
                                        setState(() {
                                          data['currentStatus'] = value!;
                                          _firestore
                                              .doc("Users/" +
                                                  Dashboard.docIdLocal +
                                                  "/Tasks/" +
                                                  document.id)
                                              .update({
                                                'currentStatus':
                                                    data['currentStatus']
                                              })
                                              .then((value) =>
                                                  print('Status updated'))
                                              .catchError(
                                                  (error) => print(error));
                                          getUpdatedTaskInfo();
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        Dashboard.title = data['Title'];
                                        Dashboard.documentId = document.id;
                                        Dashboard.desc = data['Description'];
                                        Dashboard.priority = data['Priority'];
                                        Dashboard.date = DateTime.parse(
                                            data['Date'].toDate().toString());
                                      });
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddTask(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              if (a < 7) Divider(thickness: 1.5),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
