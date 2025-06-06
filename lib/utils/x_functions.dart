import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stillnote/utils/x_constants.dart';
// import 'package:share_plus_dialog/share_plus_dialog.dart';

class XFuns {
  const XFuns._();

  static bool isDarkMode(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark;
  }

  static bool isMobileScreen(double screenWidth) =>
      (screenWidth <= XConsts.mobileSBP);
  static bool isTabletScreen(double screenWidth) =>
      (screenWidth <= XConsts.tabletSBP);
  static bool isWideScreen(double screenWidth) =>
      (screenWidth <= XConsts.wideSBP);
  static bool isLargeScreen(double screenWidth) =>
      (screenWidth <= XConsts.largeSBP);
  static bool isXLargeScreen(double screenWidth) =>
      (screenWidth <= XConsts.xlargeSBP);

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackbar(
    BuildContext context,
    String message, {
    int seconds = 3,
    bool showCloseIcon = true,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: seconds),
        showCloseIcon: showCloseIcon,
        content: Text(message),
      ),
    );
  }

  static bool isAuthenticated(BuildContext context) {
    return (FirebaseAuth.instance.currentUser != null);
  }

  static shareLink(BuildContext context, String link) {
    SharePlus.instance.share(
      ShareParams(
        uri: Uri.parse(link),
      ),
    );
  }

  static void copyText(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  static Future<void> bucketAddNotebookToRecent(String nid) async {
    final SharedPreferences bucket = await SharedPreferences.getInstance();
    final List<String> recents =
        bucket.containsKey(XConsts.bucketRecentNotebooks)
            ? bucket.getStringList(XConsts.bucketRecentNotebooks) ?? []
            : [];
    if (recents.isNotEmpty && recents.last == nid) return;
    if (recents.contains(nid)) recents.removeWhere((e) => e == nid);
    recents.add(nid);
    if (recents.length > 100) recents.removeAt(0);
    bucket.setStringList(XConsts.bucketRecentNotebooks, recents);
  }

  static Future<void> bucketSetScratchpad(String doc) async {
    final SharedPreferences bucket = await SharedPreferences.getInstance();
    bucket.setString(XConsts.bucketScratchpad, doc);
  }
}
