import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stillnote/models/auth_user.dart';

class UsersListview extends StatefulWidget {
  final List<AuthUser> list;
  const UsersListview({
    super.key,
    required this.list,
  });

  @override
  State<UsersListview> createState() => _UsersListviewState();
}

class _UsersListviewState extends State<UsersListview> {
  late ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return ListView.builder(
      shrinkWrap: true,
      itemCount: widget.list.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: _buildUserItem(widget.list[index]),
      ),
    );
  }

  Widget _buildUserItem(AuthUser user) {
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        contentPadding: const EdgeInsets.only(left: 16),
        shape: RoundedRectangleBorder(
          side: BorderSide(
            width: 1,
            color: colorScheme.primary.withValues(alpha: 0.2),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        leading: CircleAvatar(backgroundColor: colorScheme.primary),
        title: Text(
          user.name,
          maxLines: 1,
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
        subtitle: Text(
          '@${user.username}',
          maxLines: 1,
          style: const TextStyle(overflow: TextOverflow.ellipsis),
        ),
        tileColor: colorScheme.surface,
        onTap: () => context.push('/profile/${user.username}'),
      ),
    );
  }
}
