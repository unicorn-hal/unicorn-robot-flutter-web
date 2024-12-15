import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unicorn_robot_flutter_web/Controller/home_controller.dart';
import 'package:unicorn_robot_flutter_web/Model/Data/clock_data.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_button.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_progress_indicator.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_text.dart';
import 'package:unicorn_robot_flutter_web/gen/assets.gen.dart';
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: _controller.videoPlayerController.value.aspectRatio,
          child: !_controller.videoPlayerController.value.isInitialized
              ? const CustomProgressIndicator()
              : Stack(
                  children: [
                    VideoPlayer(_controller.videoPlayerController),
                    ValueListenableBuilder(
                      valueListenable: _controller.emergencyQueueNotifier,
                      builder: (context, value, _) {
                        return Positioned(
                          bottom: 50,
                          right: 25,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: value == null
                                  ? Colors.green.withOpacity(0.75)
                                  : Colors.red.withOpacity(0.75),
                              borderRadius: BorderRadius.circular(36),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 7,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              value == null ? '待機中' : '対応中',
                              style: const TextStyle(
                                fontSize: 128,
                                color: Colors.white,
                                letterSpacing: 30,
                                fontFamily: 'NotoSansJP',
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      bottom: -100,
                      child: Container(
                        width: width * 0.2,
                        margin: const EdgeInsets.all(20),
                        alignment: Alignment.bottomLeft,
                        child: Assets.images.icons.unicorn.image(),
                      ),
                    ),
                    Positioned(
                      top: 25,
                      right: 50,
                      child: Container(
                        alignment: Alignment.topRight,
                        child: Consumer(
                          builder: (context, ref, _) {
                            final clockData = ref.watch(clockDataProvider);
                            final data = clockData.getData();
                            return CustomText(
                              text: DateFormat('yyyy/MM/dd HH:mm:ss')
                                  .format(data!),
                              fontSize: 24,
                            );
                          },
                        ),
                      ),
                    ),
                    CustomButton(
                      text: 'POST',
                      onTap: () {
                        _controller.completeSupport();
                      },
                    ),
                    const SizedBox(
                      width: 800,
                      height: 700,
                      child: GoogleMapViewer(
                        point: LatLng(35.6812, 137.7671),
                        destination: LatLng(35.6580, 139.7016),
                      ),
                    ),

                    // CustomButton(
                    //   text: 'ログアウト',
                    //   onTap: () {
                    //     controller.signOut();
                    //     window.location.reload();
                    //   },
                    // ),
                  ],
                ),
        ),
      ),
    );
  }
}
