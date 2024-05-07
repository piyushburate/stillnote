import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:stillnote/models/auth_user.dart';
import 'package:stillnote/models/note.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/notebooks_gridview.dart';
import 'package:stillnote/widgets/notes_listview.dart';
import 'package:stillnote/widgets/svg_icon.dart';
import 'package:stillnote/widgets/users_listview.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late ColorScheme colorScheme;
  double? screenWidth;
  List<Notebook> notebooks = [];
  List<Note> notes = [];
  List<AuthUser> users = [];
  FocusNode focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    screenWidth = MediaQuery.of(context).size.width;

    return DefaultTabController(
      length: 3,
      initialIndex: 0,
      child: Scaffold(
        appBar: AppBar(
          title: TextField(
            onSubmitted: (value) {
              focusNode.requestFocus();
              fetchNotebooks(value.toLowerCase().trim()).then(
                (result) => setState(() {
                  notebooks = result;
                }),
              );
              fetchNotes(value.toLowerCase().trim()).then(
                (result) => setState(() {
                  notes = result;
                }),
              );
              fetchUsers(value.toLowerCase().trim()).then(
                (result) => setState(() {
                  users = result;
                }),
              );
            },
            focusNode: focusNode,
            decoration: const InputDecoration(
              hintText: 'Search...',
              contentPadding: EdgeInsets.all(15),
              border: InputBorder.none,
              prefixIcon: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: SvgIcon(XIcons.search),
              ),
            ),
          ),
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.primary.withOpacity(0.5),
            tabAlignment: TabAlignment.start,
            isScrollable: true,
            tabs: [
              _buildTab('Notebooks', notebooks.length),
              _buildTab('Notes', notes.length),
              _buildTab('Users', users.length),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            NotebooksGridview(list: notebooks),
            Container(
              constraints: BoxConstraints(
                maxWidth:
                    XFuns.isTabletScreen(screenWidth!) ? double.infinity : 550,
              ),
              child: NotesListview(list: notes),
            ),
            UsersListview(list: users),
          ],
        ),
      ),
    );
  }

  Future<List<Notebook>> fetchNotebooks(String value) async {
    final List<Notebook> result = [];
    if (value.isNotEmpty) {
      final docs = (await FirebaseFirestore.instance
              .collection('notebooks')
              .where('private', isEqualTo: false)
              .get())
          .docs;
      for (var doc in docs) {
        if (doc.exists) {
          if (doc['title'].toString().toLowerCase().contains(value)) {
            result.add(Notebook.fromSnapshot(doc));
          }
        }
      }
    }
    return result;
  }

  Future<List<Note>> fetchNotes(String value) async {
    final List<Note> result = [];
    if (value.isNotEmpty) {
      final docs = (await FirebaseFirestore.instance
              .collection('notes')
              .where('private', isEqualTo: false)
              .get())
          .docs;
      for (var doc in docs) {
        if (doc.exists) {
          if (doc['title'].toString().toLowerCase().contains(value)) {
            result.add(Note.fromSnapshot(doc));
          }
        }
      }
    }
    return result;
  }

  Future<List<AuthUser>> fetchUsers(String value) async {
    final List<AuthUser> result = [];
    if (value.isNotEmpty) {
      final docs =
          (await FirebaseFirestore.instance.collection('users').get()).docs;
      for (var doc in docs) {
        if (doc.exists) {
          if (doc['name'].toString().toLowerCase().contains(value) ||
              doc['username'].toString().toLowerCase().contains(value)) {
            result.add(AuthUser.fromSnapshot(doc));
          }
        }
      }
    }
    return result;
  }

  Tab _buildTab(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count > 0)
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Badge(
                label: Text((count > 99) ? '99+' : count.toString()),
                // isLabelVisible: (count > 0),
                backgroundColor: colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
