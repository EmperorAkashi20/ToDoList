import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:intl/intl.dart';
import 'package:todo/Views/Dashboard.dart';

import '../CollectionNames.dart';
import 'DashboardController.dart';

class AddUpdateTaskController extends GetxController {
  DashboardController _dashboardController = Get.find();
  final _firestore = FirebaseFirestore.instance;
  String title = "";
  String desc = "";
  String priority = "";
  var taskId;
  late TextEditingController dateController;
  late TextEditingController timeController;
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();
  final firestore = FirebaseFirestore.instance;
  final DateFormat dateFormatter = DateFormat('MMM dd, yyyy');

  @override
  void onInit() {
    if (_dashboardController.documentId != null) {
      title = _dashboardController.title;
      desc = _dashboardController.desc;
      date = _dashboardController.date;
      priority = _dashboardController.priority;
    }

    dateController = TextEditingController(
        text: (dateFormatter.format(_dashboardController.date)).toString());
    timeController = TextEditingController();
    super.onInit();
  }

  addTask(String id, String title, String desc, DateTime date, String priority,
      bool completed, String taskId) async {
    Get.isDialogOpen ?? true
        ? Offstage()
        : Get.dialog(Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
    var time = DateTime.now().toString();
    var titleTask = title.substring(0, 2);
    taskId = (titleTask + time).toString();
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
      _dashboardController.title = null;
      _dashboardController.date = DateTime.now();
      _dashboardController.desc = null;
      _dashboardController.documentId = null;
      _dashboardController.priority = null;
      Get.offAll(() => Dashboard());

      Get.snackbar(title, 'Task Added');
    }).catchError((_) {
      print('Error');
    });
  }

  updateTake(String title, String desc, DateTime date, String priority,
      bool completed) async {
    Get.isDialogOpen ?? true
        ? Offstage()
        : Get.dialog(Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
    var time = DateTime.now().toString();
    var titleTask = title.substring(0, 2);
    taskId = (titleTask + time).toString();
    _firestore
        .doc("$collectionUser/" +
            _dashboardController.docIdLocal +
            "/Tasks/" +
            _dashboardController.documentId)
        .update({
      "Title": title,
      "Description": desc,
      "Date": date,
      "Priority": priority,
      "currentStatus": completed,
    }).then((value) {
      print('Status updated');
      _dashboardController.title = null;
      _dashboardController.date = DateTime.now();
      _dashboardController.desc = null;
      _dashboardController.documentId = null;
      _dashboardController.priority = null;

      Get.offAll(() => Dashboard());
      Get.snackbar(title, 'Task Updated');
    }).catchError((error) {
      print(error);
    });
  }

  deleteTask() async {
    Get.isDialogOpen ?? true
        ? Offstage()
        : Get.dialog(Center(child: CircularProgressIndicator()),
            barrierDismissible: false);
    _firestore
        .doc("$collectionUser/" +
            _dashboardController.docIdLocal +
            "/Tasks/" +
            _dashboardController.documentId)
        .delete()
        .then((value) => print('Deleted'))
        .catchError((error) => print(error));
    _dashboardController.title = null;
    _dashboardController.date = DateTime.now();
    _dashboardController.desc = null;
    _dashboardController.documentId = null;
    _dashboardController.priority = null;

    Get.offAll(() => Dashboard());

    Get.snackbar(
      title,
      'Task Deleted Successfully',
    );
  }

  onTapClose() {
    _dashboardController.title = null;
    _dashboardController.date = DateTime.now();
    _dashboardController.desc = null;
    _dashboardController.documentId = null;
    _dashboardController.priority = null;

    Get.back();
  }
}
