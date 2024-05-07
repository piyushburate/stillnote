import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stillnote/models/note.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/widgets/notebooks_gridview.dart';
import 'package:stillnote/widgets/notes_listview.dart';

class StarredPage extends StatefulWidget {
  const StarredPage({super.key});

  @override
  State<StarredPage> createState() => _StarredPageState();
}

class _StarredPageState extends State<StarredPage> {
  List<Notebook> notebooks = [];
  List<Note> notes = [];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: colorScheme.surface,
            child: TabBar(
              indicatorColor: colorScheme.primary,
              labelColor: colorScheme.primary,
              unselectedLabelColor: colorScheme.primary.withOpacity(0.5),
              tabAlignment: TabAlignment.start,
              isScrollable: true,
              tabs: const [
                Tab(child: Text('Notebooks')),
                Tab(child: Text('Notes')),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('starred')
                      .where('type', isEqualTo: 'notebook')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return NotebooksGridview(list: notebooks);
                    }
                    return FutureBuilder<List<Notebook>>(
                      future: fetchStarredNotebooks(snapshot.data!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          notebooks = snapshot.data!;
                        }
                        return NotebooksGridview(list: notebooks);
                      },
                    );
                  },
                ),
                StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .collection('starred')
                      .where('type', isEqualTo: 'note')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return NotesListview(list: notes);
                    }
                    return FutureBuilder<List<Note>>(
                      future: fetchStarredNotes(snapshot.data!),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          notes = snapshot.data!;
                        }
                        return NotesListview(list: notes);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Notebook>> fetchStarredNotebooks(
      QuerySnapshot<Map<String, dynamic>> data) async {
    final List<Notebook> result = [];
    for (var doc in data.docs) {
      final notebook = await Notebook.fromId(doc['id']);
      if (notebook != null) {
        result.add(notebook);
      }
    }
    return result;
  }

  Future<List<Note>> fetchStarredNotes(
      QuerySnapshot<Map<String, dynamic>> data) async {
    final List<Note> result = [];
    for (var doc in data.docs) {
      if (doc.exists) {
        final note = await Note.fromId(doc['id']);
        if (note != null) {
          result.add(note);
        }
      }
    }
    return result;
  }
}
