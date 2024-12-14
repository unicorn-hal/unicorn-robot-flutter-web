import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/Controller/home_controller.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_button.dart';
import 'package:video_player/video_player.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late HomeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = HomeController(context);
    _controller.initializeVideoPlayer(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_controller.videoPlayerController.value.isInitialized)
                AspectRatio(
                  aspectRatio:
                      _controller.videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_controller.videoPlayerController),
                )
              else
                const Text('Initializing video...'), // 初期化中であることを表示

              const Text(
                'WELCOME TO UNICORN ROBOT HOME VIEW',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: 'ログアウト',
                onTap: () {
                  _controller.logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
