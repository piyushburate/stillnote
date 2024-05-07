import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/models/notebook.dart';

class NotebooksGridview extends StatelessWidget {
  final List<Notebook> list;
  final String? title;
  final bool scrollable;
  final Widget? header;
  const NotebooksGridview({
    super.key,
    required this.list,
    this.title,
    this.scrollable = true,
    this.header,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(16),
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      children: [
        if (list.isNotEmpty) _buildHeader(colorScheme),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 175,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 4 / 5,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            return _buildNotebookItem(context, colorScheme, list[index]);
          },
        ),
      ],
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (header != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: header!,
          ),
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              title!,
              style: TextStyle(
                fontSize: 16,
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildNotebookItem(
      BuildContext context, ColorScheme colorScheme, Notebook notebook) {
    return GestureDetector(
      onTap: () => context.push("/notebook/${notebook.id}"),
      child: Container(
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notebook.title,
              textAlign: TextAlign.left,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              notebook.description,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface,
                // decoration: TextDecoration.underline,
                decorationStyle: TextDecorationStyle.dotted,
              ),
            ),
            const Spacer(),
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
                  margin:
                      const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FutureBuilder<int>(
                      initialData: 0,
                      future: notebook.getNotesCount(),
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.data!} note${(snapshot.data! != 1) ? 's' : ''}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        );
                      }),
                ),
                notebook.menu(context, editable: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
