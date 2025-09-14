import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../data/datasources/local_db.dart';
import '../../data/models/lecture.dart';
import 'add_lecture_screen.dart';
import 'about_screen.dart';
import '../providers/lecture_provider.dart';
import '../widgets/lecture_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final days = ['الأحد', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'];
  int current = 0;
  String query = '';

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: ChangeNotifierProvider(
        create: (_) => LectureProvider()..load(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('جامعتي'),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () async {
                  final q = await showSearch<String?>(
                    context: context,
                    delegate: _LectureSearchDelegate(),
                  );
                  if (q != null) setState(() => query = q);
                },
              ),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const AboutScreen())),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const AddLectureScreen())),
            child: const Icon(Icons.add),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: current,
            onDestinationSelected: (i) => setState(() => current = i),
            destinations: days
                .map((d) => NavigationDestination(icon: const Icon(Icons.calendar_today), label: d))
                .toList(),
          ),
          body: Consumer<LectureProvider>(
            builder: (_, prov, __) {
              final list = prov.list
                  .where((l) => l.day == days[current])
                  .where((l) =>
                      query.isEmpty ||
                      l.name.contains(query) ||
                      (l.doctor?.contains(query) ?? false) ||
                      l.place.contains(query) ||
                      l.type.contains(query))
                  .toList();
              if (list.isEmpty) {
                return const Center(child: Text('لا توجد محاضرات لهذا اليوم'));
              }
              return ListView.builder(
                itemCount: list.length,
                itemBuilder: (_, i) => LectureCard(
                  lec: list[i],
                  onDelete: () async {
                    await LocalDB.delete(list[i].id!);
                    prov.load();
                  },
                  onEdit: () async {
                    await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => AddLectureScreen(edit: list[i])));
                    prov.load();
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LectureSearchDelegate extends SearchDelegate<String?> {
  @override
  List<Widget>? buildActions(BuildContext context) => [
        IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              query = '';
              showSuggestions(context);
            })
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
      icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));

  @override
  Widget buildResults(BuildContext context) => const SizedBox();

  @override
  Widget buildSuggestions(BuildContext context) {
    final prov = Provider.of<LectureProvider>(context, listen: false);
    final res = prov.list
        .where((l) =>
            l.name.contains(query) ||
            (l.doctor?.contains(query) ?? false) ||
            l.place.contains(query) ||
            l.type.contains(query))
        .toList();
    return ListView.builder(
      itemCount: res.length,
      itemBuilder: (_, i) => ListTile(
        title: Text(res[i].name),
        subtitle: Text('${res[i].day} ${res[i].startTime}'),
        onTap: () => close(context, query),
      ),
    );
  }
}
