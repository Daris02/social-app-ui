import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../models/user.dart';

final userProvider = StateNotifierProvider<UserController, User?>((ref) {
  return UserController();
});

class UserController extends StateNotifier<User?> {
  final Box<User> _box = Hive.box<User>('userBox');

  UserController() : super(Hive.box<User>('userBox').get('current')) {
    _box.watch(key: 'current').listen((event) {
      state = event.value as User?;
    });
  }

  Future<void> setUser(User user) async {
    await _box.put('current', user);
    state = user;
  }

  Future<void> clearUser() async {
    await _box.delete('current');
    state = null;
  }
}