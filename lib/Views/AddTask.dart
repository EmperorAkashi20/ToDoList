import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:todo/Views/Dashboard.dart';

class AddTask extends StatefulWidget {
  static String routeName = '/addTask';

  static bool showSpinner = false;
  const AddTask({
    Key? key,
  }) : super(key: key);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _desc = "";
  String _priority = "";
  DateTime _date = DateTime.now();
  TimeOfDay _time = TimeOfDay.now();
  final _firestore = FirebaseFirestore.instance;
  var taskId;

  TextEditingController _dateController = new TextEditingController();
  TextEditingController _timeController = new TextEditingController();
  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2021),
      lastDate: DateTime(2030),
    );
    if (date != null && date != _date) {
      setState(() {
        _date = date;
      });
      _dateController.text = _dateFormatter.format(date);
    }
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"

    return format.format(dt);
  }

  _handleTimePicker() async {
    final TimeOfDay? timeOfDay =
        await showTimePicker(context: context, initialTime: _time);
    if (timeOfDay != null && timeOfDay != _time) {
      setState(() {
        _time = timeOfDay;
      });
      _timeController.text = _time.format(context);
      formatTimeOfDay(timeOfDay);
    }
  }

  addTask(String id, String title, String desc, DateTime date, String priority,
      bool completed, String taskId) {
    _firestore.collection('Users/$id/Tasks').add({
      "Title": title,
      "Description": desc,
      "Date": date,
      "Priority": priority,
      "currentStatus": completed,
      "TaskId": taskId,
    }).then((_) {
      print('Task Added');
      // widget.updateTaskList!();

      Get.back();
      Get.snackbar(title, 'Task Added');
    }).catchError((_) {
      print('Error');
    });
  }

  updateTake(String title, String desc, DateTime date, String priority,
      bool completed) {
    _firestore
        .doc("Users/" + Dashboard.docIdLocal + "/Tasks/" + Dashboard.documentId)
        .update({
      "Title": title,
      "Description": desc,
      "Date": date,
      "Priority": priority,
      "currentStatus": completed,
    }).then((value) {
      print('Status updated');

      Get.back();
      Get.snackbar(title, 'Task Updated');
    }).catchError((error) {
      print(error);
    });
  }

  @override
  void initState() {
    if (Dashboard.documentId != null) {
      _title = Dashboard.title;
      _desc = Dashboard.desc;
      _date = Dashboard.date;
      _priority = Dashboard.priority;
    }
    _dateController.text = _dateFormatter.format(_date);

    super.initState();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double windowHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 5,
        automaticallyImplyLeading: false,
        actions: [
          CloseButton(
            color: Colors.black,
            onPressed: () {
              setState(() {
                Dashboard.title = null;
                Dashboard.date = DateTime.now();
                Dashboard.desc = null;
                Dashboard.documentId = null;
                Navigator.pop(context);
              });
            },
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: AddTask.showSpinner,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 40.0, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Dashboard.documentId == null ? 'Add A Task' : 'Update Task',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    height: windowHeight * 0.1,
                  ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Title',
                            labelStyle: TextStyle(
                              fontSize: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (input) => input!.trim().isEmpty
                              ? 'Please Enter a Task Title'
                              : null,
                          onSaved: (input) => _title = input!,
                          initialValue: _title,
                          onChanged: (value) {
                            _title = value;
                          },
                        ),
                        SizedBox(
                          height: windowHeight * 0.03,
                        ),
                        TextFormField(
                          maxLength: 100,
                          style: TextStyle(fontSize: 18, color: Colors.black),
                          decoration: InputDecoration(
                            labelText: 'Description',
                            labelStyle: TextStyle(
                              fontSize: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (input) => input!.trim().isEmpty
                              ? 'Please Enter a Task Description'
                              : null,
                          onSaved: (input) => _desc = input!,
                          onChanged: (value) {
                            _desc = value;
                          },
                          initialValue: _desc,
                        ),
                        SizedBox(
                          height: windowHeight * 0.03,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: _dateController,
                          onTap: _handleDatePicker,
                          style: TextStyle(fontSize: 18),
                          onChanged: (value) {
                            _date = value as DateTime;
                          },
                          decoration: InputDecoration(
                            labelText: 'Date',
                            labelStyle: TextStyle(fontSize: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: windowHeight * 0.03,
                        ),
                        TextFormField(
                          readOnly: true,
                          controller: _timeController,
                          onTap: _handleTimePicker,
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            labelText: 'Time',
                            labelStyle: TextStyle(fontSize: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: windowHeight * 0.03,
                        ),
                        DropdownButtonFormField(
                          items: _priorities.map((String priority) {
                            return DropdownMenuItem(
                              value: priority,
                              child: Text(
                                priority,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            );
                          }).toList(),
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                            labelText: 'Priority',
                            labelStyle: TextStyle(fontSize: 18),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          validator: (input) => _priority == null
                              ? 'Please select a priority level'
                              : null,
                          onChanged: (value) {
                            setState(() {
                              _priority = value.toString();
                            });
                          },
                        ),
                        SizedBox(
                          height: windowHeight * 0.2,
                        ),
                        GestureDetector(
                          onTap: () async {
                            setState(() {
                              var time = DateTime.now().toString();
                              var titleTask = _title.substring(0, 2);
                              taskId = (titleTask + time).toString();
                              AddTask.showSpinner = true;
                            });
                            Dashboard.documentId == null
                                ? await addTask(Dashboard.docIdLocal, _title,
                                    _desc, _date, _priority, false, taskId)
                                : await updateTake(
                                    _title, _desc, _date, _priority, false);
                            setState(() {
                              Dashboard.title = null;
                              Dashboard.date = DateTime.now();
                              Dashboard.desc = null;
                              Dashboard.documentId = null;
                              AddTask.showSpinner = false;
                            });
                          },
                          child: Container(
                            height: windowHeight * 0.065,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: Text(
                                Dashboard.documentId == null
                                    ? 'Add Task'
                                    : 'Update Task',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: windowHeight * 0.03,
                        ),
                        Dashboard.documentId == null
                            ? SizedBox.shrink()
                            : GestureDetector(
                                onTap: () {
                                  _firestore
                                      .doc("Users/" +
                                          Dashboard.docIdLocal +
                                          "/Tasks/" +
                                          Dashboard.documentId)
                                      .delete()
                                      .then((value) => print('Deleted'))
                                      .catchError((error) => print(error));
                                  setState(() {
                                    Dashboard.title = null;
                                    Dashboard.date = DateTime.now();
                                    Dashboard.desc = null;
                                    Dashboard.documentId = null;
                                    Get.back();
                                    Get.snackbar(
                                      _title,
                                      'Task Deleted Successfully',
                                    );
                                  });
                                },
                                child: Container(
                                  height: windowHeight * 0.065,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Delete Task',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // void _showSnackBar(String text) {
  //   final snackBar = SnackBar(
  //     duration: const Duration(seconds: 3),
  //     content: Container(
  //       height: 40.0,
  //       color: Colors.transparent,
  //       child: Center(
  //         child: Text(
  //           text,
  //           style: const TextStyle(fontSize: 15.0, color: Colors.black),
  //           textAlign: TextAlign.center,
  //         ),
  //       ),
  //     ),
  //     backgroundColor: Colors.white,
  //   );
  //   ScaffoldMessenger.of(context)
  //     ..hideCurrentSnackBar()
  //     ..showSnackBar(snackBar);
  // }
}
