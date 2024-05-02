import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:stillnote/utils/x_constants.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class Notebook {
  final String id;
  final int notesCount;
  final Timestamp createdDatetime;
  final String ownerUID;
  String title;
  String description;
  Timestamp modifiedDatetime;
  bool private;

  Notebook({
    required this.id,
    required this.title,
    required this.description,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.ownerUID,
    required this.private,
    required this.notesCount,
  });

  factory Notebook.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> document, int? notesCount) {
    final data = document.data()!;
    return Notebook(
      id: document.id,
      title: data['title'],
      description: data['description'],
      createdDatetime: data['created_datetime'],
      modifiedDatetime: data['modified_datetime'],
      ownerUID: data['owner_uid'],
      private: data['private'],
      notesCount: notesCount ?? 0,
    );
  }

  static Future<int?> getNotesCount(String notebookId) async {
    return (await FirebaseFirestore.instance
            .collection('notes')
            .where('notebook_id', isEqualTo: notebookId)
            .count()
            .get())
        .count;
  }

  static Future<Notebook?> fromId(String id) async {
    final firestore = FirebaseFirestore.instance;
    final ref = await firestore.collection('notebooks').doc(id).get();
    if (!ref.exists) {
      return null;
    }
    return Notebook.fromSnapshot(ref, await getNotesCount(id));
  }

  static Future<Notebook?> createNewNotebook({
    required String title,
    required String description,
    required bool private,
  }) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    final ref = await FirebaseFirestore.instance.collection("notebooks").add({
      "title": title,
      "description": description,
      "private": private,
      "owner_uid": FirebaseAuth.instance.currentUser!.uid,
      "created_datetime": DateTime.now(),
      "modified_datetime": DateTime.now(),
    });
    final doc = await ref.get();
    if (doc.exists) {
      return Notebook.fromSnapshot(doc, await getNotesCount(doc.id));
    }
    return null;
  }

  Widget menu(BuildContext context, {bool editable = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton(
      tooltip: "",
      surfaceTintColor: colorScheme.surface,
      icon: const SvgIcon(XIcons.moreHorz),
      itemBuilder: (context) {
        return <PopupMenuEntry>[
          PopupMenuItem(
            child: const Row(
              children: [
                SvgIcon(XIcons.share, width: 20),
                SizedBox(width: 10),
                Text("Share"),
              ],
            ),
            onTap: () =>
                XFuns.shareLink(context, '${XConsts.appDomain}/notebook/$id'),
          ),
          if (editable)
            PopupMenuItem(
              child: const Row(
                children: [
                  SvgIcon(XIcons.bin),
                  SizedBox(width: 10),
                  Text("Delete"),
                ],
              ),
              onTap: () {},
            ),
        ];
      },
    );
  }
}
