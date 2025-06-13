import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/api_service.dart';

final authProvider = StateNotifierProvider<AuthController, User?>(
  (ref) => AuthController(),
);

class AuthController extends StateNotifier<User?> {
  AuthController() : super(null) {
    loadUser();
  }

  Future<User?> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    // final user = prefs.getString('user');
    final id = prefs.getInt('id');
    final token = prefs.getString('token');
    final firstName = prefs.getString('firstName');
    final lastName = prefs.getString('lastName');
    final email = prefs.getString('email');
    final IM = prefs.getString('IM');
    final phone = prefs.getString('phone');
    final address = prefs.getString('address');
    final position = prefs.getString('position');
    final attribution = prefs.getString('attribution');
    final direction = prefs.getString('direction');
    final entryDate = prefs.getString('entryDate');
    final senator = prefs.getBool('senator');
    if (
        id != null &&
        firstName != null &&
        lastName != null &&
        email != null &&
        token != null &&
        IM != null &&
        phone != null &&
        address != null &&
        position != null &&
        attribution != null &&
        direction != null &&
        entryDate != null &&
        senator != null
        // user != null
        ) {
      // state = jsonDecode(user);
      // return User.fromJson(jsonDecode(user));
      return User(
        id: id,
        firstName: firstName,
        lastName: lastName,
        email: email,
        token: token,
        IM: IM,
        phone: phone,
        address: address,
        position: position,
        attribution: attribution,
        direction: direction,
        entryDate: DateTime.parse(entryDate),
        senator: senator,
      );
    }
    return null;
  }

  Future<bool> login(String email, String password) async {
    try {
      final user = await ApiService.login(email, password);
      if (user == null || user == 'Fail login') return false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', user.toString());
      await prefs.setInt('id', user.id);
      await prefs.setString('token', user.token);
      await prefs.setString('firstName', user.firstName);
      await prefs.setString('lastName', user.lastName);
      await prefs.setString('email', user.email);
      await prefs.setString('IM', user.IM);
      await prefs.setString('phone', user.phone);
      await prefs.setString('address', user.address);
      await prefs.setString('position', user.position);
      await prefs.setString('attribution', user.attribution);
      await prefs.setString('direction', user.direction);
      await prefs.setString('entryDate', user.entryDate.toString());
      await prefs.setBool('senator', user.senator);

      state = user;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> register(CreateUser newUser) async {
    try {
      final data = await ApiService.register(newUser);
      if (data == null) {
        return false;
      }
      if (data == 'Fail registration') {
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      state = null;
      return true;
    } catch (err) {
      return false;
    }
  }
}
