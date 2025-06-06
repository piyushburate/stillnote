import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/dialogs/notebook_manage_access_dialog.dart';
import 'package:stillnote/dialogs/notebook_settings_dialog.dart';
import 'package:stillnote/screens/notebook/cubit/notebook_cubit.dart';
import 'package:stillnote/utils/extensions.dart';
import 'package:stillnote/utils/x_constants.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/utils/x_widgets.dart';

class NotebookDashboardSection extends StatelessWidget {
  final NotebookAccessState notebookState;
  const NotebookDashboardSection(this.notebookState, {super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      alignment: Alignment.topCenter,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          right: BorderSide(width: 0.3, color: colorScheme.secondary),
        ),
      ),
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          Text(
            notebookState.notebook.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Created on',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            notebookState.notebook.createdDatetime.toDate().toHumanReadable(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Last Modified',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            notebookState.notebook.modifiedDatetime.toDate().getDifferences(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [
              XWidgets.svgIconTextBtn(
                colorScheme: colorScheme,
                assetName: XIcons.share,
                text: 'Share',
                onPressed: () => XFuns.shareLink(
                  context,
                  '${XConsts.appDomain}/notebook/${notebookState.notebook.id}',
                ),
              ),
              if (notebookState is NotebookEditorState)
                XWidgets.svgIconTextBtn(
                  colorScheme: colorScheme,
                  assetName: XIcons.pencil,
                  text: 'Edit',
                  onPressed: () {
                    showTitleDescUpdateDialog(
                      context,
                      (notebookState as NotebookEditorState),
                    );
                  },
                ),
              if (notebookState is NotebookEditorState)
                XWidgets.svgIconTextBtn(
                  colorScheme: colorScheme,
                  assetName: XIcons.lockedBook,
                  text: 'Manage Access',
                  onPressed: () async {
                    await manageAccessDialog(
                        context, notebookState as NotebookEditorState);
                    // ignore: use_build_context_synchronously
                    context.read<NotebookCubit>().setAccess();
                  },
                ),
              if (FirebaseAuth.instance.currentUser != null)
                XWidgets.starredBtn(
                  colorScheme: colorScheme,
                  user: FirebaseAuth.instance.currentUser!,
                  type: 'notebook',
                  nid: notebookState.notebook.id,
                )
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          Text(
            notebookState.notebook.description,
            style: const TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.left,
          ),
        ],
      ),
    );
  }

  void showTitleDescUpdateDialog(
      BuildContext context, NotebookEditorState state) {
    showDialog(
      context: context,
      builder: (dialogContext) => NotebookSettingsDialog(
        state: state,
        close: (newTitle, newDesc) async {
          if (newTitle != null && newDesc != null) {
            if (newTitle.isNotEmpty && newDesc.isNotEmpty) {
              await context
                  .read<NotebookCubit>()
                  .updateTitleDesc(context, state, newTitle, newDesc);
            }
          }
          // ignore: use_build_context_synchronously
          Navigator.pop(dialogContext, true);
        },
      ),
    );
  }

  Future<void> manageAccessDialog(
      BuildContext context, NotebookEditorState state) async {
    return await showDialog(
      context: context,
      builder: (dialogContext) => NotebookManageAccessDialog(
        notebook: state.notebook,
        close: () => Navigator.pop(dialogContext, true),
      ),
    );
  }
}
