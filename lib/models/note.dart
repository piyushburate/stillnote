import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/screens/notebook/cubit/notebook_cubit.dart';
import 'package:stillnote/utils/x_constants.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class Note {
  final String id;
  String title;
  final Timestamp createdDatetime;
  final Timestamp modifiedDatetime;
  final String notebookId;
  final bool private;
  List<dynamic> sectionList;

  Note({
    required this.id,
    required this.title,
    required this.createdDatetime,
    required this.modifiedDatetime,
    required this.notebookId,
    required this.private,
    required this.sectionList,
  });

  factory Note.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return Note(
      id: document.id,
      title: data['title'],
      createdDatetime: data['created_datetime'],
      modifiedDatetime: data['modified_datetime'],
      notebookId: data['notebook_id'],
      private: data['private'],
      sectionList: data['section_list'],
    );
  }

  static Future<Note?> fromId(String id) async {
    final doc =
        await FirebaseFirestore.instance.collection("notes").doc(id).get();
    if (!doc.exists) {
      return null;
    }
    return Note.fromSnapshot(doc);
  }

  static Future<Note?> createNewNote({
    required String title,
    required bool private,
    required String notebookID,
  }) async {
    if (FirebaseAuth.instance.currentUser == null) {
      return null;
    }
    final ref = await FirebaseFirestore.instance.collection("notes").add({
      "title": title,
      "private": private,
      "section_list": [],
      "notebook_id": notebookID,
      "created_datetime": DateTime.now(),
      "modified_datetime": DateTime.now(),
    });
    final doc = await ref.get();
    if (doc.exists) {
      return Note.fromSnapshot(doc);
    }
    return null;
  }

  Future<String?> getStarredId() async {
    final docs = (await FirebaseFirestore.instance
            .collection(
                'users/${FirebaseAuth.instance.currentUser!.uid}/starred')
            .where('type', isEqualTo: 'note')
            .where('id', isEqualTo: id)
            .get())
        .docs;
    if (docs.isNotEmpty) {
      return docs.first.id;
    }
    return null;
  }

  Widget menu(BuildContext context, {NotebookEditorState? notebookState}) {
    final colorScheme = Theme.of(context).colorScheme;
    return PopupMenuButton(
      tooltip: "",
      surfaceTintColor: colorScheme.surface,
      icon: const SvgIcon(XIcons.moreVert),
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
            onTap: () => XFuns.shareLink(context, '/note/$id'),
          ),
          if (XFuns.isAuthenticated(context))
            PopupMenuItem(
              child: Row(
                children: [
                  const SvgIcon(XIcons.star, width: 20),
                  const SizedBox(width: 10),
                  FutureBuilder<String?>(
                    future: getStarredId(),
                    builder: (context, snapshot) {
                      return Text((snapshot.data != null) ? 'Unstar' : 'Star');
                    },
                  ),
                ],
              ),
              onTap: () async {
                final starredId = await getStarredId();
                if (starredId != null) {
                  FirebaseFirestore.instance
                      .collection(
                          'users/${FirebaseAuth.instance.currentUser!.uid}/starred')
                      .doc(starredId)
                      .delete();
                } else {
                  FirebaseFirestore.instance
                      .collection(
                          'users/${FirebaseAuth.instance.currentUser!.uid}/starred')
                      .add({'type': 'note', 'id': id});
                }
              },
            ),
          if (notebookState != null)
            PopupMenuItem(
              child: const Row(
                children: [
                  SvgIcon(XIcons.bin),
                  SizedBox(width: 10),
                  Text("Delete"),
                ],
              ),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: const Text('Delete Note'),
                      content: Text(
                          'Are you really want to delete this note containing ${sectionList.length} note sections?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            context
                                .read<NotebookCubit>()
                                .deleteNote(notebookState, this);
                            // ignore: use_build_context_synchronously
                          },
                          child: const Text('Yes'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ];
      },
    );
  }
}
