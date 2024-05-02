part of 'note_cubit.dart';

class NoteState {
  const NoteState();
}

class NoteInitialState extends NoteState {}

class NoteAccessState extends NoteState {
  Note note;
  Notebook notebook;
  List<NoteSection> sections;

  NoteAccessState({
    required this.note,
    required this.notebook,
    required this.sections,
  }) : super();
}

class NoteReadOnlyState extends NoteAccessState {
  NoteReadOnlyState({
    required super.note,
    required super.notebook,
    required super.sections,
  });
}

class NoteEditorState extends NoteAccessState {
  NoteEditorState({
    required super.note,
    required super.notebook,
    required super.sections,
  });
}

class NoteErrorState extends NoteState {
  final String message;

  const NoteErrorState(this.message);
}
