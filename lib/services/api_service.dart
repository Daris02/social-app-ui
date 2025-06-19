import 'package:social_app/models/direction.dart';
import 'package:social_app/models/message.dart';
import 'package:social_app/models/user.dart';
import 'package:social_app/services/auth_service.dart';
import 'package:social_app/services/message_service.dart';
import 'package:social_app/services/post_service.dart';
import 'package:social_app/services/user_service.dart';

class ApiService {
  static dynamic login(String email, String password) => AuthService.login(email, password);

  static dynamic register(CreateUser newUser) => AuthService.register(newUser);

  static Future<List<User>> getContacts() => UserService.getContacts();

  static Future<List<Direction>> getDirections() => UserService.getDirections();

  static Future<void> createPost(String title, String content) => PostService.createPost(title, content);

  static Future<void> likePost(int id, String reaction) => PostService.likePost(id, reaction);

  static Future<void> deletePost(int id) => PostService.deletePost(id);

  static Future<List<Message>> getMessages(int id) => MessageService.getMessages(id);
}
