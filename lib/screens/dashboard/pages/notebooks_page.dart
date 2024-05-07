import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stillnote/dialogs/create_notebook_dialog.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/widgets/notebooks_gridview.dart';

class NotebooksPage extends StatefulWidget {
  const NotebooksPage({super.key});

  @override
  State<NotebooksPage> createState() => _NotebooksPageState();
}

class _NotebooksPageState extends State<NotebooksPage> {
  List<Notebook> notebooks = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            useSafeArea: false,
            builder: (dialogContext) {
              return CreateNotebookDialog(
                close: (notebookId) => Navigator.pop(dialogContext, notebookId),
              );
            },
          );
        },
        label: const Text('New Notebook'),
        icon: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('notebooks')
            .where('owner_uid',
                isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return NotebooksGridview(list: notebooks);
          }
          notebooks = getMyNotebooks(snapshot.data!);
          return NotebooksGridview(list: notebooks);
        },
      ),
    );
  }

  List<Notebook> getMyNotebooks(QuerySnapshot<Map<String, dynamic>> data) {
    final List<Notebook> result = [];
    for (var doc in data.docs) {
      result.add(Notebook.fromSnapshot(doc));
    }
    result.sort(
      (a, b) {
        return (b.createdDatetime.compareTo(a.createdDatetime));
      },
    );
    return result;
  }
}
