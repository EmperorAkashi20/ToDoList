import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:todo/AddTask/Components/Body.dart';
import 'package:todo/Helpers/DatabaseHelpers.dart';
import 'package:todo/Login.dart';
import 'package:todo/Models/taskmodel.dart';
import 'package:todo/main.dart';

class Body extends StatefulWidget {
  static var title;
  const Body({Key? key}) : super(key: key);

  @override
  _BodyState createState() => _BodyState();
}

class _BodyState extends State<Body> {
  final _firestore = FirebaseFirestore.instance;
  var loggedInUser;
  Future<List<Task>>? _taskList;
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  bool completed = false;

  Widget _buildTask(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        children: [
          ListTile(
              isThreeLine: true,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title!,
                    style: TextStyle(
                      fontSize: 18,
                      decoration: task.status == 0
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    task.desc!,
                    style: TextStyle(
                      fontSize: 16,
                      decoration: task.status == 0
                          ? TextDecoration.none
                          : TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
              subtitle: Text(
                '${_dateFormatter.format(task.date!)} * ${task.priority}',
                style: TextStyle(
                  fontSize: 15,
                  decoration: task.status == 0
                      ? TextDecoration.none
                      : TextDecoration.lineThrough,
                ),
              ),
              trailing: Checkbox(
                checkColor: Colors.white,
                activeColor: Colors.redAccent,
                value: task.status == 1 ? true : false,
                onChanged: (value) {
                  task.status = value! ? 1 : 0;
                  DatabaseHelper.instance.updateTask(task);
                  _updateTaskList();
                },
              ),
              onTap: () {
                setState(() {
                  Body.title = task.title;
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddTask(
                      updateTaskList: _updateTaskList,
                      task: task,
                    ),
                  ),
                );
              }),
          Divider(),
        ],
      ),
    );
  }

  _updateTaskList() {
    setState(() {
      _taskList = DatabaseHelper.instance.getTaskList();
    });
  }

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
      ),
    );
  }

  // Future getTasks() async {
  //   await _firestore
  //       .collection('Users/' + LogInScreen.docId + '/Tasks')
  //       .get()
  //       .then((QuerySnapshot querySnapshot) {
  //     querySnapshot.docs.forEach((element) {
  //       print(element['Title']);
  //     });
  //   });
  // }

  // void taskStrem() async {
  //   await for (var snapshot in _firestore
  //       .collection('Users/' + LogInScreen.docId + '/Tasks')
  //       .snapshots()) {
  //     for (var tasks in snapshot.docs) {
  //       print(tasks.id);
  //     }
  //   }
  // }

  @override
  void initState() {
    _updateTaskList();
    // getTasks();
    // taskStrem();

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
        onPressed: () {
          // showNotification();
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddTask(
                updateTaskList: _updateTaskList,
              ),
            ),
          );
        },
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Users/' + LogInScreen.docId + '/Tasks')
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
          }
          // final int completedTaskCount = snapshot.data!
          //     .where((Task task) => task.status == 1)
          //     .toList()
          //     .length;
          else {
            return SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      LogInScreen.name + "'s Tasks",
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
                      '0 out of ${snapshot.data!.docs.length}',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(
                      height: windowHeight * 0.03,
                    ),
                    Expanded(
                      child: ListView(
                        children: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          DateFormat _dateFormat = DateFormat('y-MM-d');
                          String formattedDate =
                              _dateFormat.format(data['Date'].toDate());
                          print(document.id);
                          return ListTile(
                            isThreeLine: true,
                            title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['Title'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      decoration: data['currentStatus'] == false
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                  Text(
                                    data['Description'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      decoration: data['currentStatus'] == false
                                          ? TextDecoration.none
                                          : TextDecoration.lineThrough,
                                    ),
                                  ),
                                ]),
                            subtitle:
                                Text("$formattedDate * ${data['Priority']}"),
                            trailing: Checkbox(
                              checkColor: Colors.white,
                              activeColor: Colors.redAccent,
                              value: data['currentStatus'],
                              onChanged: (value) {
                                setState(() {
                                  data['currentStatus'] = value!;

                                  _firestore
                                      .doc("Users/" +
                                          LogInScreen.docId +
                                          "/Tasks/" +
                                          document.id)
                                      .update({
                                        'currentStatus': data['currentStatus']
                                      })
                                      .then((value) => print('Status updated'))
                                      .catchError((error) => print(error));
                                });
                              },
                            ),
                            onTap: () {
                              setState(() {
                                Body.title = data['Title'];
                              });
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (_) => AddTask(
                              //       updateTaskList: _updateTaskList,
                              //       task: task,
                              //     ),
                              //   ),
                              // );
                            },
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
