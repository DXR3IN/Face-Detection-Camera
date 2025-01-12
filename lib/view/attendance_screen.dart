import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:absence_face_detection/controller/attendance_controller.dart';

class AttendanceScreen extends StatelessWidget {
  final AttendanceController _controller = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _photoAttendance(),
                const SizedBox(height: 30),
                _buildTextField(
                    "Name", "Enter your name", _controller.nameController),
                const SizedBox(height: 30),
                _buildTextField(
                    "Class", "Enter your class", _controller.classController),
                const SizedBox(height: 30),
                _buildButton()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Obx _photoAttendance() {
    return Obx(() {
      final imageFile = _controller.imageFile.value;
      return imageFile != null
          ? Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Image
                  Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.file(
                        imageFile,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Delete button
                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      onPressed: () {
                        _controller.deleteImage();
                      },
                      icon: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: GestureDetector(
                onTap: _controller.toCamera,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
    });
  }

  Widget _buildTextField(
      String label, String hint, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget _buildButton() {
    // final width = MediaQuery.of(Get.context!).size.width;
    return GestureDetector(
      onTap: _controller.submitAttendance,
      child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(5),
            color: Colors.blue,
          ),
          child: const Text(
            "Submit",
            style: TextStyle(color: Colors.white),
          )),
    );
  }
}
