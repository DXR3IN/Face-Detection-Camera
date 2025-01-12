import 'dart:io';

import 'package:absence_face_detection/model/attendance_model.dart';
import 'package:absence_face_detection/utils/database_helpers.dart';
import 'package:absence_face_detection/view/camera_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class AttendanceController extends GetxController {
  var imageFile = Rxn<File>();
  late final TextEditingController nameController;
  late final TextEditingController classController;
  List<CameraDescription> cameras = [];

  @override
  void onInit() {
    nameController = TextEditingController();
    classController = TextEditingController();
    super.onInit();
  }

  @override
  void dispose() {
    nameController.dispose();
    classController.dispose();
    super.dispose();
  }

  Future<void> initializeCameras() async {
    try {
      cameras = await availableCameras();
    } catch (e) {
      Exception("Error initializing cameras: $e");
    }
  }

  void toCamera() async {
    await initializeCameras();
    final result = await Get.to(() => CameraScreen(
        // cameras: cameras,
        ));
    if (result is File) {
      imageFile.value = result;
    }
  }

  void deleteImage() {
    if (imageFile.value != null) {
      try {
        imageFile.value!.deleteSync();
      } catch (e) {
        Exception("Error deleting file: $e");
      }
      imageFile.value = null;
    }
  }

  Future<void> submitAttendance() async {
    if (imageFile.value != null &&
        nameController.text.isNotEmpty &&
        classController.text.isNotEmpty) {
      // Save image file path
      String imagePath = imageFile.value!.path;

      // Create the AttendanceModel
      AttendanceModel attendance = AttendanceModel(
        name: nameController.text,
        imagePath: imagePath,
        className: classController.text,
        date: DateTime.now(),
      );

      // Insert attendance into SQLite database
      await DatabaseHelper.instance.insertAttendance(attendance);
      // print("Attendance inserted with id: $id");

      // Optionally clear form after submission
      imageFile.value = null;
      nameController.clear();
      classController.clear();

      Get.back();

      Get.snackbar('Success', 'Absence recorded successfully');
    } else {
      Get.snackbar('Error', 'Please fill in all fields and take a photo');
    }
  }
}
