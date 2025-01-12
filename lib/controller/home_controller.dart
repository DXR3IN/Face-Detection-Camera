import 'package:absence_face_detection/model/attendance_model.dart';
import 'package:absence_face_detection/utils/database_helpers.dart';
import 'package:absence_face_detection/view/attendance_screen.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  var attendanceList = <AttendanceModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAttendanceData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void fetchAttendanceData() async {
    isLoading(true);
    final data = await DatabaseHelper.instance.getAllAttendance();
    attendanceList.assignAll(data);
    isLoading(false);
  }

  void toAttendanceScreen() {
    Get.to(() => AttendanceScreen());
  }

  void deleteAttendanceById(int id) async {
    await DatabaseHelper.instance.deleteAttendance(id);
    fetchAttendanceData();
  }
}
