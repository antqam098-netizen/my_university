import 'package:flutter/material.dart';
import '../../data/datasources/local_db.dart';
import '../../data/models/lecture.dart';

class LectureProvider with ChangeNotifier {
  List<Lecture> _list = [];
  List<Lecture> get list => _list;

  Future<void> load() async {
    _list = await LocalDB.fetchAll();
    notifyListeners();
  }
}
