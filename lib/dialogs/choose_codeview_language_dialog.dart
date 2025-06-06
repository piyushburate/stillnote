import 'package:flutter/material.dart';
import 'package:stillnote/models/code_view_language.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class ChooseCodeViewLanguageDialog extends StatefulWidget {
  final void Function(CodeViewLanguage? codeViewLanguage) close;
  const ChooseCodeViewLanguageDialog({
    super.key,
    required this.close,
  });

  @override
  State<ChooseCodeViewLanguageDialog> createState() =>
      _ChooseCodeViewLanguageDialogState();
}

class _ChooseCodeViewLanguageDialogState
    extends State<ChooseCodeViewLanguageDialog> {
  final _searchCtrl = TextEditingController();
  String searchText = '';
  final codeViewLangs = CodeViewLanguage.values;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.1),
      insetPadding: const EdgeInsets.all(25),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxWidth: 340),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border.fromBorderSide(
            BorderSide(width: 0.3, color: colorScheme.secondary),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: getDialogBody(colorScheme),
      ),
    );
  }

  Widget getDialogBody(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Change Code Language',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: colorScheme.primary,
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => widget.close(null),
                iconSize: 30,
                color: colorScheme.secondary,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Material(
            color: colorScheme.secondary.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(5),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: getSearchTextFieldDecoration(),
            ),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: codeViewLangs.length,
              separatorBuilder: (context, index) {
                if (searchText.isNotEmpty &&
                    !codeViewLangs[index]
                        .title
                        .toLowerCase()
                        .contains(searchText)) {
                  return const SizedBox();
                }
                return const SizedBox(height: 5);
              },
              itemBuilder: (context, index) {
                if (searchText.isNotEmpty &&
                    !codeViewLangs[index]
                        .title
                        .toLowerCase()
                        .contains(searchText)) {
                  return const SizedBox();
                }
                return Material(
                  borderRadius: BorderRadius.circular(5),
                  clipBehavior: Clip.hardEdge,
                  type: MaterialType.transparency,
                  child: ListTile(
                    tileColor: colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    onTap: () => widget.close(codeViewLangs[index]),
                    title: Text(codeViewLangs[index].title),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration getSearchTextFieldDecoration() {
    return const InputDecoration(
      hintText: 'Search...',
      contentPadding: EdgeInsets.all(15),
      border: InputBorder.none,
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: SvgIcon(XIcons.search),
      ),
    );
  }
}
