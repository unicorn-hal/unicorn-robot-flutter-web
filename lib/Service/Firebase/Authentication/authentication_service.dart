import 'package:firebase_auth/firebase_auth.dart';
import 'package:unicorn_robot_flutter_web/Service/Log/log_service.dart';

class FirebaseAuthenticationService {
  late FirebaseAuth _instance;

  FirebaseAuthenticationService() {
    _instance = FirebaseAuth.instance;
  }

  Future<void> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      Log.echo('Sign-in: ${userCredential.user!.email}');
    } catch (e) {
      Log.echo('Sign-in error: $e');
    }
  }

  /// ユーザー情報を取得する
  User? getRobot() {
    return _instance.currentUser;
  }

  /// UIDを取得する
  String? getUid() {
    return _instance.currentUser?.uid;
  }

  /// IDトークンを取得する
  Future<String?> getIdToken() async {
    return _instance.currentUser?.getIdToken();
  }
}
