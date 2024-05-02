import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/dialogs/create_notebook_dialog.dart';
import 'package:stillnote/models/notebook.dart';

class NotebooksGridview extends StatefulWidget {
  final bool showCreateBtn;
  final bool showActions;
  final List<Notebook> list;
  final bool showErrorView;
  final String? title;
  final bool scrollable;
  final Widget? header;
  const NotebooksGridview({
    super.key,
    required this.list,
    this.showCreateBtn = false,
    this.showActions = true,
    this.showErrorView = false,
    this.title,
    this.scrollable = true,
    this.header,
  });

  @override
  State<NotebooksGridview> createState() => _NotebooksGridviewState();
}

class _NotebooksGridviewState extends State<NotebooksGridview> {
  late ColorScheme colorScheme;
  bool firstLoaded = false;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      floatingActionButton: widget.showCreateBtn
          ? FloatingActionButton.extended(
              onPressed: () async {
                await showDialog(
                  context: context,
                  useSafeArea: false,
                  builder: (dialogContext) {
                    return CreateNotebookDialog(
                      close: (notebookId) =>
                          Navigator.pop(dialogContext, notebookId),
                    );
                  },
                );
              },
              label: const Text('New Notebook'),
              icon: const Icon(Icons.add),
            )
          : null,
      body: getMainView(),
    );
  }

  Widget getMainView() {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      physics: widget.scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      children: [
        if (widget.header != null) widget.header!,
        if (widget.header != null) const SizedBox(height: 10),
        if (widget.title != null)
          Text(
            widget.title!,
            style: TextStyle(
              fontSize: 16,
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
        if (widget.showActions) _buildActions(),
        if (widget.showActions) const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 173,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 4 / 5,
          ),
          itemCount: widget.list.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              child: _getGridItem(widget.list[index], colorScheme),
              onTap: () => context.push("/notebook/${widget.list[index].id}"),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActions() {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      children: [],
    );
  }

  Widget _getGridItem(Notebook notebook, ColorScheme colorScheme) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          left: BorderSide(width: 4, color: colorScheme.secondary),
          right: BorderSide(width: 0.3, color: colorScheme.secondary),
          top: BorderSide(width: 0.3, color: colorScheme.secondary),
          bottom: BorderSide(width: 0.3, color: colorScheme.secondary),
        ),
        borderRadius: const BorderRadius.horizontal(
          left: Radius.circular(4),
          right: Radius.circular(10),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.3),
            offset: const Offset(3, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            notebook.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Text(
              notebook.description,
              textAlign: TextAlign.justify,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface,
                // decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dotted,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                margin: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  '${notebook.notesCount} note${(notebook.notesCount != 1) ? 's' : ''}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                    fontSize: 12,
                  ),
                ),
              ),
              notebook.menu(context, editable: true),
            ],
          ),
        ],
      ),
    );
  }
}
