import 'package:hive/hive.dart';
import '../models/user.dart';

class UserStorage {
  static final _box = Hive.box<User>('userBox');

  static Future<void> saveUser(User user) async {
    await _box.put('current', user);
  }

  static User? getUser() {
    return _box.get('current');
  }

  static Future<void> clearUser() async {
    await _box.delete('current');
  }
}