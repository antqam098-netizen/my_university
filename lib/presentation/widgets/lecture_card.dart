import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../data/models/lecture.dart';

class LectureCard extends StatelessWidget {
  final Lecture lec;
  final VoidCallback onDelete, onEdit;
  const LectureCard({super.key, required this.lec, required this.onDelete, required this.onEdit});

  Color _color() => lec.type == 'نظري' ? Colors.blue : Colors.green;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(motion: const ScrollMotion(), children: [
        SlidableAction(
          onPressed: (_) => onEdit(),
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          icon: Icons.edit,
          label: 'تعديل',
        ),
        SlidableAction(
          onPressed: (_) => onDelete(),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          icon: Icons.delete,
          label: 'حذف',
        ),
      ]),
      child: Card(
        color: _color().withOpacity(.1),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: ListTile(
          leading: CircleAvatar(backgroundColor: _color(), child: Text(lec.type[0])),
          title: Text(lec.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (lec.doctor != null) Text('د.${lec.doctor}'),
              Text('${lec.startTime} | ${lec.place}'),
            ],
          ),
        ),
      ),
    );
  }
}
