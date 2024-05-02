import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/global_cubits/auth_cubit/auth_cubit.dart';

class NotebookDiscussSection extends StatefulWidget {
  final String notebookId;
  const NotebookDiscussSection(this.notebookId, {super.key});

  @override
  State<NotebookDiscussSection> createState() => _NotebookDiscussSectionState();
}

class _NotebookDiscussSectionState extends State<NotebookDiscussSection> {
  late ColorScheme colorScheme;
  late AuthState authState;
  final msgCtrl = TextEditingController();
  final focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    authState = context.watch<AuthCubit>().state;
    colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discuss'),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: mainSection(),
          ),
          if (FirebaseAuth.instance.currentUser != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: bottomSection(),
            )
        ],
      ),
    );
  }

  Widget mainSection() {
    return Material(
      color: colorScheme.secondary,
      type: MaterialType.transparency,
      child: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notebooks/${widget.notebookId}/discuss')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          List<(String, Timestamp, String)> msgs = [];
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              if (doc.exists) {
                msgs.add((doc['from'], doc['timestamp'], doc['data']));
              }
            }
          }
          return ListView.separated(
            shrinkWrap: true,
            reverse: true,
            itemCount: msgs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 0.5),
            itemBuilder: (context, index) {
              return ListTile(
                tileColor: colorScheme.surface,
                leading: CircleAvatar(backgroundColor: colorScheme.primary),
                title: GestureDetector(
                  onTap: () => context.push('/profile/${msgs[index].$1}'),
                  child: Text(
                    '@${msgs[index].$1}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                ),
                subtitle: Text(msgs[index].$3),
              );
            },
          );
        },
      ),
    );
  }

  Widget bottomSection() {
    return Container(
      height: 60,
      color: colorScheme.surface,
      margin: const EdgeInsets.only(top: 1),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.emoji_emotions),
          ),
          Expanded(
            child: TextField(
              controller: msgCtrl,
              focusNode: focusNode,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Message...',
                contentPadding: EdgeInsets.all(10),
              ),
              onSubmitted: (value) => sendMessage(value),
            ),
          ),
          IconButton(
            onPressed: () => sendMessage(msgCtrl.text),
            icon: const Icon(Icons.send, size: 20),
          ),
        ],
      ),
    );
  }

  void sendMessage(String msg) async {
    if (msg.isNotEmpty && authState is AuthLoggedInState) {
      final authState = this.authState as AuthLoggedInState;
      msgCtrl.clear();
      focusNode.requestFocus();
      await FirebaseFirestore.instance
          .collection('notebooks/${widget.notebookId}/discuss')
          .add({
        'from': authState.user.username,
        'timestamp': Timestamp.now(),
        'data': msg,
      });
    }
  }
}
