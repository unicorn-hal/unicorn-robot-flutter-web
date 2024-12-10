import 'package:flutter/material.dart';
import 'package:unicorn_robot_flutter_web/Controller/home_controller.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_button.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_text.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_textfield.dart';
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
              SizedBox(
                height: 70,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(text: '移動通知'),
                      CustomTextfield(
                          hintText: 'userID',
                          controller: controller.movingUserIdController,
                          width: 150),
                      const SizedBox(height: 30),
                      CustomTextfield(
                          hintText: 'latitude',
                          controller: controller.movingRobotLatitudeController,
                          width: 150),
                      const SizedBox(height: 30),
                      CustomTextfield(
                          hintText: 'longitude',
                          controller: controller.movingRobotLongitudeController,
                          width: 150),
                      const SizedBox(height: 30),
                      CustomButton(
                          text: 'PUSH',
                          onTap: () async {
                            await controller.postMovingUnicorn();
                          }),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(text: '到着通知'),
                      CustomTextfield(
                          hintText: 'userID',
                          controller: controller.arrivalUserIdController,
                          width: 150),
                      const SizedBox(height: 30),
                      CustomTextfield(
                          hintText: 'latitude',
                          controller: controller.arrivalRobotLatitudeController,
                          width: 150),
                      const SizedBox(height: 30),
                      CustomTextfield(
                          hintText: 'longitude',
                          controller:
                              controller.arrivalRobotLongitudeController,
                          width: 150),
                      const SizedBox(height: 30),
                      CustomButton(
                          text: 'PUSH',
                          onTap: () async {
                            await controller.postArrivalUnicorn();
                          }),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomText(text: '完了通知'),
                      CustomTextfield(
                          hintText: 'userID',
                          controller: controller.completeUserIdController,
                          width: 150),
                      const SizedBox(height: 30),
                      CustomTextfield(
                          hintText: 'robotSupportID',
                          controller:
                              controller.completeRobotSupportIdController,
                          width: 150),
                      const SizedBox(height: 30),
                      CustomButton(
                          text: 'PUSH',
                          onTap: () async {
                            await controller.postCompleteUnicorn();
                          }),
                    ],
                  ),
                ],
              ),
              SizedBox(
                height: 70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
