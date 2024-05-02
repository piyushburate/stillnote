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
  ColorScheme? colorScheme;
  double? screenWidth;
  late StreamSubscription _streamSubscriptionNotebooks;
  late StreamSubscription _streamSubscriptionNotes;
  List<Notebook> notebooks = [];
  List<Note> notes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchStarredNotebooks();
      fetchStarredNotes();
    });
  }

  @override
  void dispose() {
    _streamSubscriptionNotebooks.cancel();
    _streamSubscriptionNotes.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 2,
      initialIndex: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: colorScheme!.surface,
            child: TabBar(
              indicatorColor: colorScheme!.primary,
              labelColor: colorScheme!.primary,
              unselectedLabelColor: colorScheme!.primary.withOpacity(0.5),
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
                NotebooksGridview(list: notebooks),
                NotesListview(list: notes),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void fetchStarredNotebooks() async {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('starred')
        .where('type', isEqualTo: 'notebook')
        .snapshots();
    _streamSubscriptionNotebooks = stream.listen((event) async {
      final List<Notebook> result = [];
      for (var doc in event.docs) {
        if (doc.exists) {
          final notebook = await Notebook.fromId(doc['id']);
          if (notebook != null) {
            result.add(notebook);
          }
        }
      }
      setState(() {
        notebooks = result;
      });
    });
  }

  void fetchStarredNotes() async {
    final stream = FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('starred')
        .where('type', isEqualTo: 'note')
        .snapshots();
    _streamSubscriptionNotes = stream.listen((event) async {
      final List<Note> result = [];
      for (var doc in event.docs) {
        if (doc.exists) {
          final note = await Note.fromId(doc['id']);
          if (note != null) {
            result.add(note);
          }
        }
      }
      setState(() {
        notes = result;
      });
    });
  }
}
