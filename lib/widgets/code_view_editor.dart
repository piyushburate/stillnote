import 'package:flutter/material.dart';
import 'package:flutter_code_editor/flutter_code_editor.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stillnote/screens/note/note_sections/code_view_box_section.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class CodeViewEditor extends StatelessWidget {
  final String initialCode;
  final CodeViewLanguage language;
  final bool editable;
  final CodeController controller;
  final void Function(String value)? onChanged;
  const CodeViewEditor({
    super.key,
    required this.initialCode,
    required this.language,
    required this.editable,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      clipBehavior: Clip.hardEdge,
      borderRadius: BorderRadius.circular(5),
      color: colorScheme.secondary,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 5),
            child: Row(
              children: [
                Material(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(3),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                    child: Text(language.title),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    XFuns.copyText(controller.text);
                    XFuns.showSnackbar(context, 'Code Copied!');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    padding: const EdgeInsets.fromLTRB(5, 2, 5, 2),
                    child: const SvgIcon(XIcons.copy, width: 20),
                  ),
                ),
              ],
            ),
          ),
          CodeTheme(
            data: CodeThemeData(styles: githubTheme),
            child: CodeField(
              background: colorScheme.background,
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              controller: controller,
              readOnly: !editable,
              onChanged: onChanged,
              textStyle: TextStyle(
                  fontFamily: GoogleFonts.getFont('Anonymous Pro').fontFamily),
              gutterStyle: const GutterStyle(
                showErrors: false,
                showFoldingHandles: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
