import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/screens/note/cubit/note_cubit.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class NoteMainSection extends StatefulWidget {
  final NoteAccessState noteState;
  const NoteMainSection(this.noteState, {super.key});

  @override
  State<NoteMainSection> createState() => _NoteMainSectionState();
}

class _NoteMainSectionState extends State<NoteMainSection> {
  ColorScheme? colorScheme;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    final noteViewList = getNoteViewList(context);
    return ScrollablePositionedList.builder(
      padding: const EdgeInsets.only(bottom: 100),
      itemScrollController: context.read<NoteCubit>().noteViewItemScroller,
      itemCount: noteViewList.length,
      itemBuilder: (context, index) => noteViewList[index],
    );
  }

  List<Widget> getNoteViewList(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return [
      Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          top: 20,
          left: XFuns.isMobileScreen(screenWidth) ? 20 : 40,
          right: XFuns.isMobileScreen(screenWidth) ? 20 : 40,
        ),
        alignment: Alignment.center,
        color: colorScheme!.surface,
        margin: EdgeInsets.zero,
        child: TextFormField(
          initialValue: widget.noteState.note.title,
          onChanged: (value) async {
            if (widget.noteState is NoteEditorState) {
              context.read<NoteCubit>().updateTitle(
                  context, widget.noteState as NoteEditorState, value);
            }
          },
          readOnly: (widget.noteState is NoteReadOnlyState),
          maxLines: null,
          keyboardType: TextInputType.multiline,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: colorScheme!.primary,
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            hintStyle: TextStyle(color: colorScheme!.secondary),
            hintText: "Your Title Here...",
          ),
        ),
      ),
      for (var section in widget.noteState.sections)
        Container(
          key: ValueKey("note_section_${section.id}"),
          width: double.infinity,
          padding: EdgeInsets.only(
            left: XFuns.isMobileScreen(screenWidth) ? 20 : 40,
            right: XFuns.isMobileScreen(screenWidth) ? 20 : 40,
            bottom: 10,
          ),
          alignment: Alignment.center,
          color: colorScheme!.surface,
          child: section.widget(context, (widget.noteState is NoteEditorState)),
        ),
    ];
  }
}
