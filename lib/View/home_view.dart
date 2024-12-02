import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/Route/router.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Home View',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                const LoginRoute().go(context);
              },
              child: const Text('GO TO Login'),
            ),
          ],
        ),
      ),
    );
  }
}
