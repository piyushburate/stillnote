import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/screens/notebook/cubit/notebook_cubit.dart';
import 'package:stillnote/widgets/notes_listview.dart';

class NotebookNotesSection extends StatefulWidget {
  final NotebookAccessState notebookState;
  const NotebookNotesSection(this.notebookState, {super.key});

  @override
  State<NotebookNotesSection> createState() => _NotebookNotesSectionState();
}

class _NotebookNotesSectionState extends State<NotebookNotesSection> {
  ColorScheme? colorScheme;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    // return DefaultTabController(
    //   length: 4,
    //   initialIndex: 0,
    //   child: Scaffold(
    //     appBar: AppBar(
    //       title: const Text('Notes'),
    //       automaticallyImplyLeading: false,
    //       bottom: TabBar(
    //         indicatorColor: colorScheme!.primary,
    //         labelColor: colorScheme!.primary,
    //         unselectedLabelColor: colorScheme!.primary.withOpacity(0.5),
    //         tabAlignment: TabAlignment.start,
    //         isScrollable: true,
    //         tabs: const [
    //           Tab(text: 'All'),
    //           Tab(text: 'Unit 1'),
    //           Tab(text: 'Unit 2'),
    //           Tab(text: 'Unit 3'),
    //         ],
    //       ),
    //     ),
    //     body: TabBarView(
    //       children: [

    //         Container(),
    //         Container(),
    //         Container(),
    //       ],
    //     ),
    //   ),
    // );
    return NotesListview(
      title: 'Notes',
      list: widget.notebookState.noteList,
      showCreateBtn: true,
      notebook: widget.notebookState.notebook,
      showActions: true,
      notebookState: (widget.notebookState is NotebookEditorState)
          ? (widget.notebookState as NotebookEditorState)
          : null,
      refreshFun: () => context.read<NotebookCubit>().setAccess(),
    );
  }
}
