import 'package:absence_face_detection/widget/animated_list_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:absence_face_detection/controller/home_controller.dart';

class HomeScreen extends StatelessWidget {
  final HomeController _controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _controller.fetchAttendanceData();
        },
        child: Obx(() {
          if (_controller.attendanceList.isEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - kToolbarHeight,
                child: Center(
                  child: const Text("No attendance records found."),
                ),
              ),
            );
          } else {
            return ListView.builder(
              itemCount: _controller.attendanceList.length,
              itemBuilder: (context, index) {
                final attendance = _controller.attendanceList[index];
                return AnimatedListTile(
                  title: attendance.name,
                  subtitle: attendance.className,
                  imagePath: attendance.imagePath,
                  onDelete: () =>
                      _controller.deleteAttendanceById(attendance.id!),
                );
              },
            );
          }
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _controller.toAttendanceScreen,
        child: const Icon(Icons.add),
      ),
    );
  }
}
