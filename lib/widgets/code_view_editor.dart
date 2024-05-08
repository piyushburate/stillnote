import 'package:code_text_field/code_text_field.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stillnote/models/code_view_language.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/dark.dart';

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
      color: colorScheme.onBackground,
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
                Tooltip(
                  message: 'Copy Code',
                  child: InkWell(
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
                ),
              ],
            ),
          ),
          CodeTheme(
            data: CodeThemeData(
              styles: XFuns.isDarkMode(context) ? darkTheme : githubTheme,
            ),
            child: CodeField(
              controller: controller,
              readOnly: !editable,
              onChanged: onChanged,
              background: colorScheme.background,
              textStyle: TextStyle(
                fontFamily: GoogleFonts.getFont('Anonymous Pro').fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
