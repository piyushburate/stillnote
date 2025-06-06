import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/global_cubits/auth_cubit/auth_cubit.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/widgets/svg_icon.dart';

class XWidgets {
  const XWidgets._();

  static Widget svgIconTextBtn({
    required ColorScheme colorScheme,
    required String assetName,
    required String text,
    required void Function()? onPressed,
    ButtonStyle? style,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ).merge(style),
      icon: SvgIcon(assetName, invert: true, width: 18),
      label: Text(text),
    );
  }

  static Widget textBtn({
    required ColorScheme colorScheme,
    required String text,
    required void Function()? onPressed,
    ButtonStyle? style,
    TextStyle? textStyle,
    bool loading = false,
  }) {
    return ElevatedButton(
      onPressed: (onPressed != null)
          ? loading
              ? () {}
              : onPressed
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      ).merge(style),
      child: loading
          ? SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(color: colorScheme.onPrimary),
            )
          : Text(
              text,
              style:
                  const TextStyle(fontWeight: FontWeight.bold).merge(textStyle),
            ),
    );
  }

  static Widget switchListTile({
    required ColorScheme colorScheme,
    required bool value,
    required String text,
    required void Function(bool value)? onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      applyCupertinoTheme: true,
      activeTrackColor: colorScheme.primary,
      activeColor: colorScheme.onPrimary,
      title: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: colorScheme.primary.withValues(alpha: value ? 1 : 0.5),
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  static Widget profileBtn(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is AuthLoggedInState) {
      return IconButton(
        onPressed: () => context.push('/profile/${authState.user.username}'),
        icon: const SvgIcon(XIcons.profile),
      );
    }
    return textBtn(
      text: 'Login',
      colorScheme: Theme.of(context).colorScheme,
      onPressed: () => context.push('/auth/login'),
    );
  }

  static Widget? backBtn(BuildContext context) {
    return context.canPop()
        ? IconButton(
            onPressed: () => context.pop(),
            icon: const SvgIcon(XIcons.leftArrow),
          )
        : null;
  }

  static Widget starredBtn({
    required ColorScheme colorScheme,
    required User user,
    required String type,
    required String nid,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users/${user.uid}/starred')
          .where('type', isEqualTo: type)
          .where('id', isEqualTo: nid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          bool isStarred = snapshot.data!.docs.length == 1;
          return XWidgets.svgIconTextBtn(
            colorScheme: colorScheme,
            assetName: XIcons.star,
            text: isStarred ? 'Unstar' : 'Star',
            onPressed: () {
              if (isStarred) {
                FirebaseFirestore.instance
                    .collection('users/${user.uid}/starred')
                    .doc(snapshot.data!.docs[0].id)
                    .delete();
              } else {
                FirebaseFirestore.instance
                    .collection('users/${user.uid}/starred')
                    .add({
                  'type': type,
                  'id': nid,
                });
              }
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
