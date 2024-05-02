import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/widgets/notebooks_gridview.dart';

class NotebooksPage extends StatefulWidget {
  const NotebooksPage({super.key});

  @override
  State<NotebooksPage> createState() => _NotebooksPageState();
}

class _NotebooksPageState extends State<NotebooksPage> {
  late StreamSubscription _streamSubscriptionNotebooks;
  List<Notebook> notebooks = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      fetchMyNotebooks();
    });
  }

  @override
  void dispose() {
    _streamSubscriptionNotebooks.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : NotebooksGridview(
            list: notebooks,
            showCreateBtn: true,
          );
  }

  void fetchMyNotebooks() async {
    if (loading) loading = false;
    final stream = FirebaseFirestore.instance
        .collection('notebooks')
        .where('owner_uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
    _streamSubscriptionNotebooks = stream.listen((event) async {
      final List<Notebook> result = [];
      for (var doc in event.docs) {
        if (doc.exists) {
          final notesCount = await Notebook.getNotesCount(doc.id);
          final notebook = Notebook.fromSnapshot(doc, notesCount);
          result.add(notebook);
        }
      }
      setState(() {
        notebooks = result;
      });
    });
  }
}
