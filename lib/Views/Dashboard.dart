import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_animations/loading_animations.dart';
import 'package:todo/CollectionNames.dart';
import 'package:todo/Controllers/DashboardController.dart';
import 'package:todo/Views/AddTask.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  DashboardController _dashboardController = Get.put(DashboardController());

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
            onPressed: () {
              _dashboardController.onLogout();
            },
            icon: Icon(Icons.power_settings_new, color: Colors.black),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dashboardController.firestore
            .collection(
                '$collectionUser/' + _dashboardController.docIdLocal + '/Tasks')
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
                    _dashboardController.user + "'s Tasks",
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
                      _dashboardController.user + "'s Tasks",
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
                          // if(data['Date'].toDate().isBefore(DateTime.now())){} //Use for showing overdue tasks
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
                                          _dashboardController.firestore
                                              .doc("$collectionUser/" +
                                                  _dashboardController
                                                      .docIdLocal +
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
                                          _dashboardController
                                              .getUpdatedTaskInfo();
                                        });
                                      },
                                    ),
                                    onTap: () {
                                      setState(() {
                                        _dashboardController.title =
                                            data['Title'];
                                        _dashboardController.documentId =
                                            document.id;
                                        _dashboardController.desc =
                                            data['Description'];
                                        _dashboardController.priority =
                                            data['Priority'];
                                        _dashboardController.date =
                                            DateTime.parse(data['Date']
                                                .toDate()
                                                .toString());
                                      });
                                      Get.to(() => AddTask());
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
