part of 'notebook_cubit.dart';

class NotebookState {
  const NotebookState();
}

class NotebookInitialState extends NotebookState {}

class NotebookAccessState extends NotebookState {
  Notebook notebook;
  List<Note>? noteList;

  NotebookAccessState({required this.notebook}) : super();
}

class NotebookReadOnlyState extends NotebookAccessState {
  NotebookReadOnlyState({required super.notebook});
}

class NotebookEditorState extends NotebookAccessState {
  NotebookEditorState({
    required super.notebook,
    // required super.noteList,
  });
}

class NotebookErrorState extends NotebookState {
  final String message;

  const NotebookErrorState(this.message);
}
