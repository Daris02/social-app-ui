
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_app/models/user.dart';

class CardUser extends StatelessWidget {
  const CardUser({
    super.key,
    required this.user,
    required this.router,
  });

  final User user;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: user.photo != null
              ? NetworkImage(user.photo!)
              : null,
          child: user.photo == null
              ? Icon(Icons.person, size: 32)
              : null,
        ),
        title: Text(
          '${user.firstName} ${user.lastName}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(color: Colors.grey[700]),
            ),
            if (user.phone.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.phone,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.primary,
        ),
        onTap: () {
          router.push('/profile', extra: user);
        },
      ),
    );
  }
}
