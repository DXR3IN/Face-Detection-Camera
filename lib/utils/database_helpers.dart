import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:absence_face_detection/model/attendance_model.dart';

class DatabaseHelper {
  static const _databaseName = "attendance.db";
  static const _databaseVersion = 1;

  static const table = 'attendance_table';
  static const columnId = 'id';
  static const columnName = 'name';
  static const columnImagePath = 'imagePath';
  static const columnClassName = 'className';
  static const columnDate = 'date';

  // Singleton pattern
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    // Get the path to the database
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _databaseName);

    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  // Create table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,
        $columnImagePath TEXT NOT NULL,
        $columnClassName TEXT NOT NULL,
        $columnDate TEXT NOT NULL
      )
    ''');
  }

  // Insert attendance data
  Future<int> insertAttendance(AttendanceModel attendance) async {
    Database db = await instance.database;
    return await db.insert(table, attendance.toMap());
  }

  // Get all attendance records
  Future<List<AttendanceModel>> getAllAttendance() async {
    Database db = await instance.database;
    var result = await db.query(table);
    return result.map((e) => AttendanceModel.fromMap(e)).toList();
  }

  // Delete attendance record
  Future<int> deleteAttendance(int id) async {
    Database db = await instance.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
