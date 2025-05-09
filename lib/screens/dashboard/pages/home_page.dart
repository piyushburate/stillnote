import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/utils/x_constants.dart';
import 'package:stillnote/widgets/notebooks_gridview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    return FutureBuilder<List<Notebook>>(
        future: fetchRecentNotebooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return NotebooksGridview(
              title: 'Recently Viewed Notebooks',
              list: snapshot.data!,
            );
          } else {
            return const SizedBox();
          }
        });
  }

  Future<List<String>> getRecents() async {
    return (await SharedPreferences.getInstance())
            .getStringList(XConsts.bucketRecentNotebooks) ??
        [];
  }

  Future<List<Notebook>> fetchRecentNotebooks() async {
    final List<Notebook> result = [];
    final List<String> nids = await getRecents();
    for (var nid in nids) {
      final notebook = await Notebook.fromId(nid);
      if (notebook != null) {
        result.add(notebook);
      }
    }
    return result;
  }
}
