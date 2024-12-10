import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/Controller/home_controller.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_button.dart';
import 'package:unicorn_robot_flutter_web/gen/assets.gen.dart';
import 'package:video_player/video_player.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController =
        VideoPlayerController.asset(Assets.videos.unicornShort);
    _videoPlayerController.initialize().then((_) {
      // 最初のフレームを描画するため初期化後に更新
      setState(() {
        _videoPlayerController.setLooping(true);
        _videoPlayerController.play();
      });
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    HomeController controller = HomeController(context);
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_videoPlayerController.value.isInitialized)
                AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController),
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
                  controller.logout();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
