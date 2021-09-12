import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo/Helpers/DatabaseHelpers.dart';
import 'package:todo/Models/taskmodel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo/ToDoList/Components/Body.dart';
import 'package:todo/Widgets.dart/LoginForm.dart';

import '../../Login.dart';

class AddTask extends StatefulWidget {
  static String routeName = '/addTask';
  final Function? updateTaskList;
  final Task? task;
  const AddTask({Key? key, this.task, this.updateTaskList}) : super(key: key);

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

  _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      Task task =
          Task(title: _title, date: _date, priority: _priority, desc: _desc);
      if (widget.task == null) {
        task.status = 0;
        DatabaseHelper.instance.insertTask(task);
      } else {
        task.id = widget.task!.id;
        task.status = widget.task!.status;
        DatabaseHelper.instance.updateTask(task);
      }
      widget.updateTaskList!();
      Navigator.pop(context);
    }
  }

  _delete() {
    DatabaseHelper.instance.deleteTask(widget.task!.id!);
    widget.updateTaskList!();
    Navigator.pop(context);
  }

  void addTask(
      String id, String title, String desc, String date, String priority) {
    print(id);
    print(title);
    print(desc);
    print(date);
    print(priority);
    _firestore.collection('Users/$id/Tasks').add({
      "Title": title,
      "Description": desc,
      "Date": date,
      "Priority": priority
    }).then((_) {
      print('Task Added');
      widget.updateTaskList!();
      Navigator.pop(context);
    }).catchError((_) {
      print('Error');
    });
  }

  @override
  void initState() {
    if (widget.task != null) {
      _title = widget.task!.title!;
      _desc = widget.task!.desc!;
      _date = widget.task!.date!;
      _priority = widget.task!.priority!;
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
                  widget.task == null ? 'Add A Task' : 'Update Task',
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
                          addTask(LogInScreen.docId, _title, _desc,
                              _dateController.text, _priority);

                          // await _submit();
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
                              widget.task == null ? 'Add Task' : 'Update Task',
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
                      widget.task == null
                          ? SizedBox.shrink()
                          : GestureDetector(
                              onTap: _delete,
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

  void _showSnackBar(String text) {
    final snackBar = SnackBar(
      duration: const Duration(seconds: 3),
      content: Container(
        height: 40.0,
        color: Colors.transparent,
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15.0, color: Colors.black),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}
