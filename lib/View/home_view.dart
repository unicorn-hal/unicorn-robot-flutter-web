import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unicorn_robot_flutter_web/Controller/home_controller.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_button.dart';
import 'package:unicorn_robot_flutter_web/View/Component/Parts/google_map_viewer.dart';
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
    _controller.videoPlayerDispose();
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
              const SizedBox(height: 20),
              const SizedBox(
                width: 800,
                height: 700,
                child: GoogleMapViewer(
                  point: LatLng(35.6812, 137.7671),
                  destination: LatLng(35.6580, 139.7016),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
