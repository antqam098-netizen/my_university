import 'package:flutter/material.dart';
import '../../data/models/lecture.dart';
import '../../data/datasources/local_db.dart';
import '../../core/services/notification_helper.dart';

class AddLectureScreen extends StatefulWidget {
  final Lecture? edit;
  const AddLectureScreen({super.key, this.edit});

  @override
  State<AddLectureScreen> createState() => _AddLectureScreenState();
}

class _AddLectureScreenState extends State<AddLectureScreen> {
  final _form = GlobalKey<FormState>();
  late String name, type = 'نظري', doctor, place, day = 'الأحد', startTime = '08:00';

  @override
  void initState() {
    super.initState();
    if (widget.edit != null) {
      name = widget.edit!.name;
      type = widget.edit!.type;
      doctor = widget.edit!.doctor ?? '';
      place = widget.edit!.place;
      day = widget.edit!.day;
      startTime = widget.edit!.startTime;
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    _form.currentState!.save();
    final lec = Lecture(
      id: widget.edit?.id,
      name: name,
      type: type,
      doctor: doctor.isEmpty ? null : doctor,
      startTime: startTime,
      place: place,
      day: day,
    );
    if (widget.edit == null) {
      await LocalDB.insert(lec);
    } else {
      await LocalDB.update(lec);
    }
    await NotificationHelper.scheduleLecture(lec);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.edit == null ? 'إضافة محاضرة' : 'تعديل')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: name,
                    decoration: const InputDecoration(labelText: 'اسم المحاضرة'),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    onSaved: (v) => name = v!,
                  ),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: ['نظري', 'عملي']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => type = v!,
                  ),
                  TextFormField(
                    initialValue: doctor,
                    decoration: const InputDecoration(labelText: 'اسم الدكتور (اختياري)'),
                    onSaved: (v) => doctor = v!,
                  ),
                  ListTile(
                    title: Text('وقت البدء: $startTime'),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (t != null) setState(() => startTime = t.format(context));
                    },
                  ),
                  TextFormField(
                    initialValue: place,
                    decoration: const InputDecoration(labelText: 'المكان'),
                    validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                    onSaved: (v) => place = v!,
                  ),
                  DropdownButtonFormField<String>(
                    value: day,
                    items: ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) => day = v!,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('حفظ'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
