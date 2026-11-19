import 'package:flutter/material.dart';

import 'user.dart';

class UserDetailScreen extends StatelessWidget {
  const UserDetailScreen({super.key, required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final a = user.address;
    return Scaffold(
      appBar: AppBar(title: Text(user.name)),
      body: ListView(
        children: [
          _Tile(Icons.person, 'Username', user.username),
          _Tile(Icons.email, 'Email', user.email),
          _Tile(
            Icons.phone,
            'Phone',
            user.phone,
            extra: user.phoneDigits,
            onTap: () {},
          ),
          _Tile(Icons.public, 'Website', user.website ?? '—', onTap: () {}),
          _Tile(
            Icons.home,
            'Address',
            '${a.street}, ${a.suite}\n${a.city}, ${a.zipcode}',
          ),
          _Tile(Icons.place, 'Geo', '${a.geo.lat}, ${a.geo.lng}'),
          _Tile(
            Icons.business,
            'Company',
            '${user.company.name}\n${user.company.catchPhrase}',
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.icon, this.label, this.value, {this.extra, this.onTap});

  final IconData icon;
  final String label;
  final String value;
  final String? extra;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    subtitle: Text(extra == null ? value : '$value\ndigits: $extra'),
    onTap: onTap,
  );
}
