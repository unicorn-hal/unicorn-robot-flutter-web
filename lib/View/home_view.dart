import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:unicorn_robot_flutter_web/Constants/Enum/user_gender_enum.dart';
import 'package:unicorn_robot_flutter_web/Controller/home_controller.dart';
import 'package:unicorn_robot_flutter_web/Model/Data/clock_data.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_progress_indicator.dart';
import 'package:unicorn_robot_flutter_web/View/Component/CustomWidget/custom_text.dart';
import 'package:unicorn_robot_flutter_web/View/Component/Parts/user_image_circle.dart';
import 'package:unicorn_robot_flutter_web/gen/assets.gen.dart';
import 'package:unicorn_robot_flutter_web/View/Component/Parts/google_map_viewer.dart';
import 'package:unicorn_robot_flutter_web/gen/colors.gen.dart';
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
    _controller.initializeGoogleMapsJs(() {
      setState(() {});
    });
    _controller.initializeVideoPlayer(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildUserInfo() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorName.mainColor, width: 2),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomText(
            text: '要請ユーザー情報',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UserImageCircle(
                imageSize: 100,
                imageUrl: _controller.user!.iconImageUrl ?? '',
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUserInfoRow(
                    icon: Icons.person,
                    label:
                        '名前：${_controller.user!.lastName} ${_controller.user!.firstName}',
                  ),
                  _buildUserInfoRow(
                    icon: Icons.wc,
                    label: '性別：${_controller.user!.gender.displayName}',
                  ),
                  _buildUserInfoRow(
                    icon: Icons.cake,
                    label:
                        '生年月日：${DateFormat('yyyy/MM/dd').format(_controller.user!.birthDate)}',
                  ),
                  _buildUserInfoRow(
                    icon: Icons.height,
                    label: '身長：${_controller.user!.bodyHeight}cm',
                  ),
                  _buildUserInfoRow(
                    icon: Icons.monitor_weight,
                    label: '体重：${_controller.user!.bodyWeight}kg',
                  ),
                  _buildUserInfoRow(
                    icon: Icons.work,
                    label: '職業：${_controller.user!.occupation}',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const CustomText(
            text: '最新の検診結果',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfoRow(
                icon: Icons.event,
                label:
                    '日付：${DateFormat('yyyy/MM/dd').format(_controller.healthCheckUpList!.last.date)}',
              ),
              _buildUserInfoRow(
                icon: Icons.thermostat,
                label:
                    '体温：${_controller.healthCheckUpList!.last.bodyTemperature}℃',
              ),
              _buildUserInfoRow(
                icon: Icons.favorite,
                label:
                    '血圧：${_controller.healthCheckUpList!.last.bloodPressure}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoRow({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 8),
        CustomText(
          text: label,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: _controller.videoPlayerController.value.aspectRatio,
          child: !_controller.videoPlayerController.value.isInitialized
              ? const CustomProgressIndicator()
              : ValueListenableBuilder(
                  valueListenable: _controller.emergencyQueueNotifier,
                  builder: (context, emergencyQueue, _) {
                    return Stack(
                      children: [
                        VideoPlayer(_controller.videoPlayerController),
                        Positioned(
                          bottom: 50,
                          right: 25,
                          child: Container(
                            margin: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: emergencyQueue == null
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
                              emergencyQueue == null ? '待機中' : '対応中',
                              style: const TextStyle(
                                fontSize: 128,
                                color: Colors.white,
                                letterSpacing: 30,
                                fontFamily: 'NotoSansJP',
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -100,
                          child: Container(
                            width: width * 0.2,
                            margin: const EdgeInsets.all(20),
                            alignment: Alignment.bottomLeft,
                            child: Assets.images.logo.image(),
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
                        Positioned(
                          top: 25,
                          left: 50,
                          child: Container(
                            alignment: Alignment.topLeft,
                            child: emergencyQueue == null
                                ? const SizedBox()
                                : _buildUserInfo(),
                          ),
                        ),
                        Positioned(
                          top: 80,
                          right: 25,
                          child: emergencyQueue == null
                              ? const SizedBox()
                              : Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  width: 400,
                                  height: 400,
                                  child: ValueListenableBuilder(
                                    valueListenable:
                                        _controller.unicornPositionNotifier,
                                    builder: (context, unicornPosition, _) {
                                      return GoogleMapViewer(
                                        point:
                                            _controller.unicornInitialPosition,
                                        destination: LatLng(
                                            emergencyQueue.userLatitude,
                                            emergencyQueue.userLongitude),
                                        current: unicornPosition,
                                        onRouteFetched: (polyline) async {
                                          await _controller.queueTask(
                                            polyline: polyline,
                                          );
                                        },
                                      );
                                    },
                                  ),
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
                    );
                  },
                ),
        ),
      ),
    );
  }
}
