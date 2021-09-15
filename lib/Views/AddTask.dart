import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';
import 'package:todo/Controllers/AddUpdateTaskController.dart';
import 'package:todo/Controllers/DashboardController.dart';

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
  DashboardController _dashboardController = Get.find();
  AddUpdateTaskController _taskController = Get.put(AddUpdateTaskController());
  final _formKey = GlobalKey<FormState>();

  final DateFormat _dateFormatter = DateFormat('MMM dd, yyyy');
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  _handleDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: _taskController.date,
      firstDate: DateTime(2021),
      lastDate: DateTime(2030),
    );
    if (date != null && date != _taskController.date) {
      setState(() {
        _taskController.date = date;
      });
      _taskController.dateController.text = _dateFormatter.format(date);
    }
  }

  String formatTimeOfDay(TimeOfDay tod) {
    final now = new DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    final format = DateFormat.jm(); //"6:00 AM"

    return format.format(dt);
  }

  _handleTimePicker() async {
    final TimeOfDay? timeOfDay = await showTimePicker(
        context: context, initialTime: _taskController.time);
    if (timeOfDay != null && timeOfDay != _taskController.time) {
      setState(() {
        _taskController.time = timeOfDay;
      });
      _taskController.timeController.text =
          _taskController.time.format(context);
      formatTimeOfDay(timeOfDay);
    }
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
              _taskController.onTapClose();
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _dashboardController.documentId == null
                      ? 'Add A Task'
                      : 'Update Task',
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
                        onSaved: (input) => _taskController.title = input!,
                        initialValue: _taskController.title,
                        onChanged: (value) {
                          _taskController.title = value;
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
                        onSaved: (input) => _taskController.desc = input!,
                        onChanged: (value) {
                          _taskController.desc = value;
                        },
                        initialValue: _taskController.desc,
                      ),
                      SizedBox(
                        height: windowHeight * 0.03,
                      ),
                      TextFormField(
                        readOnly: true,
                        controller: _taskController.dateController,
                        onTap: _handleDatePicker,
                        style: TextStyle(fontSize: 18),
                        onChanged: (value) {
                          _taskController.date = value as DateTime;
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
                        controller: _taskController.timeController,
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
                          labelText: _dashboardController.priority == null
                              ? 'Priority'
                              : _dashboardController.priority,
                          labelStyle: TextStyle(fontSize: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        validator: (input) => _taskController.priority == null
                            ? 'Please select a priority level'
                            : null,
                        onChanged: (value) {
                          setState(() {
                            _taskController.priority = value.toString();
                          });
                        },
                      ),
                      SizedBox(
                        height: windowHeight * 0.2,
                      ),
                      GestureDetector(
                        onTap: () async {
                          _dashboardController.documentId == null
                              ? await _taskController.addTask(
                                  _dashboardController.docIdLocal,
                                  _taskController.title,
                                  _taskController.desc,
                                  _taskController.date,
                                  _taskController.priority,
                                  false,
                                  _taskController.taskId)
                              : await _taskController.updateTake(
                                  _taskController.title,
                                  _taskController.desc,
                                  _taskController.date,
                                  _taskController.priority,
                                  false);
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
                              _dashboardController.documentId == null
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
                      _dashboardController.documentId == null
                          ? SizedBox.shrink()
                          : GestureDetector(
                              onTap: () {
                                _taskController.deleteTask();
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
    );
  }
}
