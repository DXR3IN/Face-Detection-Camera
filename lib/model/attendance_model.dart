class AttendanceModel {
  final int? id;
  final String name;
  final String imagePath;
  final String className;
  final DateTime date;

  AttendanceModel({
    this.id,
    required this.name,
    required this.imagePath,
    required this.className,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imagePath': imagePath,
      'className': className,
      'date': date.toIso8601String(),
    };
  }

  // Convert a map to an AttendanceModel
  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'],
      name: map['name'],
      imagePath: map['imagePath'],
      className: map['className'],
      date: DateTime.parse(map['date']),
    );
  }
}
