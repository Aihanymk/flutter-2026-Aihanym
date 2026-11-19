import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/api/api_exception.dart';
import 'new_user_screen.dart';
import 'status_views.dart';
import 'user.dart';
import 'user_detail_screen.dart';
import 'users_model.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<UsersModel>();
    return Scaffold(
      appBar: AppBar(title: const Text('Users')),
      floatingActionButton: FloatingActionButton(
        tooltip: 'New user',
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const NewUserScreen())),
        child: const Icon(Icons.person_add),
      ),
      body: _body(m),
    );
  }

  Widget _body(UsersModel m) {
    if (m.loading && m.items.isEmpty) return const LoadingView();

    return switch (m.error) {
      null => UserList(m.items),
      NoConnectionException() => Offline(onRetry: m.load),
      NotFoundException() || UnauthorizedException() => const RequestRejected(),
      ServerException(:final status) => ServerError(status, onRetry: m.load),
      BadResponseException(:final detail) => GenericError(detail: detail),
    };
  }
}

class UserList extends StatelessWidget {
  const UserList(this.users, {super.key});

  final List<User> users;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: context.read<UsersModel>().load,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: users.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text('${u.email}\n${u.address.city}'),
            isThreeLine: true,
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => UserDetailScreen(user: u),
              ),
            ),
          );
        },
      ),
    );
  }
}
