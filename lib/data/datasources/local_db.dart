import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart';
import '../models/lecture.dart';

class LocalDB {
  static Future<sql.Database> _db() async {
    return sql.openDatabase(
      join(await sql.getDatabasesPath(), 'lectures.db'),
      onCreate: (db, version) => db.execute(
          'CREATE TABLE lectures(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, type TEXT, doctor TEXT, startTime TEXT, place TEXT, day TEXT)'),
      version: 1,
    );
  }

  static Future<int> insert(Lecture lec) async {
    final db = await _db();
    return db.insert('lectures', lec.toMap());
  }

  static Future<List<Lecture>> fetchAll() async {
    final db = await _db();
    final maps = await db.query('lectures', orderBy: 'startTime');
    return maps.map((e) => Lecture.fromMap(e)).toList();
  }

  static Future<List<Lecture>> fetchByDay(String day) async {
    final db = await _db();
    final maps =
        await db.query('lectures', where: 'day = ?', whereArgs: [day]);
    return maps.map((e) => Lecture.fromMap(e)).toList();
  }

  static Future<int> delete(int id) async {
    final db = await _db();
    return db.delete('lectures', where: 'id = ?', whereArgs: [id]);
  }

  static Future<int> update(Lecture lec) async {
    final db = await _db();
    return db.update('lectures', lec.toMap(),
        where: 'id = ?', whereArgs: [lec.id]);
  }
}
