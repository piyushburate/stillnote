import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stillnote/global_cubits/auth_cubit/auth_cubit.dart';
import 'package:stillnote/models/auth_user.dart';
import 'package:stillnote/models/notebook.dart';
import 'package:stillnote/screens/error_page.dart';
import 'package:stillnote/utils/x_constants.dart';
import 'package:stillnote/utils/x_functions.dart';
import 'package:stillnote/utils/x_icons.dart';
import 'package:stillnote/utils/x_widgets.dart';
import 'package:stillnote/widgets/notebooks_gridview.dart';

class ProfileScreen extends StatefulWidget {
  final String username;
  const ProfileScreen(this.username, {super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late double screenWidth;
  late ColorScheme colorScheme;
  AuthUser? authUser;
  bool isloading = true;
  List<Notebook> notebooks = [];

  @override
  void initState() {
    super.initState();
    AuthUser.fromUsername(widget.username).then((value) {
      setState(() {
        isloading = false;
        authUser = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    colorScheme = Theme.of(context).colorScheme;
    return Title(
      color: colorScheme.primary,
      title: 'Profile',
      child: Scaffold(
        appBar: AppBar(
          title: const Text(XConsts.appName),
          actions: [
            XWidgets.profileBtn(context),
            SizedBox(width: screenWidth / 70),
          ],
          leading: XWidgets.backBtn(context),
        ),
        body: isloading
            ? const Center(child: CircularProgressIndicator())
            : (authUser == null)
                ? const ErrorPage(errorMsg: 'User not found!')
                : XFuns.isTabletScreen(screenWidth)
                    ? ListView(
                        shrinkWrap: true,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: Material(
                              clipBehavior: Clip.hardEdge,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: getProfileView(context, colorScheme),
                            ),
                          ),
                          getNotebooksGridview(false),
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: XFuns.isTabletScreen(screenWidth)
                                  ? double.infinity
                                  : 340,
                              minHeight: 200,
                            ),
                            child: getProfileView(context, colorScheme),
                          ),
                          Expanded(child: getNotebooksGridview(true)),
                        ],
                      ),
      ),
    );
  }

  Widget getNotebooksGridview(bool scrollable) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: getNotebooksStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return NotebooksGridview(list: notebooks);
        }
        notebooks = getMyNotebooks(snapshot.data!);
        return NotebooksGridview(
          list: notebooks,
          scrollable: scrollable,
        );
      },
    );
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getNotebooksStream() {
    if (XFuns.isAuthenticated(context)) {
      if (FirebaseAuth.instance.currentUser!.uid == authUser!.uid) {
        return FirebaseFirestore.instance
            .collection('notebooks')
            .where('owner_uid', isEqualTo: authUser!.uid)
            .snapshots();
      }
    }
    return FirebaseFirestore.instance
        .collection('notebooks')
        .where(
          Filter.and(
            Filter('owner_uid', isEqualTo: authUser!.uid),
            Filter('private', isEqualTo: false),
          ),
        )
        .snapshots();
  }

  List<Notebook> getMyNotebooks(QuerySnapshot<Map<String, dynamic>> data) {
    final List<Notebook> result = [];
    for (var doc in data.docs) {
      result.add(Notebook.fromSnapshot(doc));
    }
    result.sort(
      (a, b) {
        return (b.createdDatetime.compareTo(a.createdDatetime));
      },
    );
    return result;
  }

  Widget getProfileView(BuildContext context, ColorScheme colorScheme) {
    return Container(
      color: colorScheme.surface,
      alignment: Alignment.topLeft,
      padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
      child: Flex(
        direction:
            XFuns.isTabletScreen(screenWidth) ? Axis.horizontal : Axis.vertical,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(shape: BoxShape.circle),
            clipBehavior: Clip.hardEdge,
            foregroundDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              // image: DecorationImage(
              //   image: AssetImage(XConsts.onErrorImageAsset),
              //   fit: BoxFit.cover,
              // ),
            ),
            child: Image.asset(
              XConsts.onErrorImageAsset,
              fit: BoxFit.cover,
              width: screenWidth / 4,
              height: 180,
            ),
          ),
          const SizedBox.square(dimension: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: XFuns.isTabletScreen(screenWidth)
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Text(
                  authUser!.name,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  authUser!.email,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                    color: colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${authUser!.username}',
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 16,
                    overflow: TextOverflow.ellipsis,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary.withValues(alpha: 0.8),
                  ),
                ),
                if (FirebaseAuth.instance.currentUser != null)
                  if (authUser!.uid == FirebaseAuth.instance.currentUser!.uid)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          XWidgets.svgIconTextBtn(
                            colorScheme: colorScheme,
                            assetName: XIcons.pencil,
                            text: 'Edit Profile',
                            onPressed: () {},
                          ),
                          XWidgets.svgIconTextBtn(
                            colorScheme: colorScheme,
                            assetName: XIcons.logout,
                            text: 'Log Out',
                            onPressed: () =>
                                context.read<AuthCubit>().signOut(context),
                          ),
                        ],
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
