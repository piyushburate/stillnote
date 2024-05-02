import 'package:flutter/material.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class AuthPasswordField extends StatefulWidget {
  final TextEditingController? controller;
  final void Function(BuildContext) onSubmit;
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool passwordHide = true;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(5),
      child: TextFormField(
        controller: widget.controller,
        obscureText: passwordHide,
        onEditingComplete: () {
          widget.onSubmit(context);
        },
        keyboardType: TextInputType.visiblePassword,
        autofillHints: const [AutofillHints.password],
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Password",
          prefixIcon: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SvgIcon(XIcons.lock),
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 5),
            child: IconButton(
              tooltip: (passwordHide ? 'Show' : 'Hide'),
              icon: SvgIcon(passwordHide ? XIcons.eyeClose : XIcons.eyeOpen),
              onPressed: () => setState(() => passwordHide = !passwordHide),
            ),
          ),
          contentPadding: const EdgeInsets.all(15),
        ),
      ),
    );
  }
}
