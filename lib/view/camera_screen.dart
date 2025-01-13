import 'package:absence_face_detection/painters/people_silhouette.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:absence_face_detection/controller/camera_screen_controller.dart';
import 'dart:math' as math;

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final CameraScreenController _controller;

  @override
  void initState() {
    _controller = Get.put(CameraScreenController());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              child: Obx(() {
                if (_controller.isCameraInitialized.value) {
                  return _controller.isMirroredImage.value
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Center(
                              child:
                                  CameraPreview(_controller.cameraController)),
                        )
                      : Center(
                          child: CameraPreview(_controller.cameraController));
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
            ),
            SilhouetteOverlay(),
            Positioned(
              top: MediaQuery.of(context).padding.top + 35,
              left: 10,
              child: GestureDetector(
                onTap: Get.back,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                height: height * 0.2,
                width: width,
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Column(
                  children: [
                    Center(
                      child: Obx(
                        () => Text(
                          _controller.message.value,
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 60,
                          height: 60,
                        ),
                        const SizedBox(width: 32),

                        // Capture Button
                        Obx(
                          () => GestureDetector(
                            onTap: _controller.isCameraInitialized.value &&
                                    !_controller.isLoading.value
                                ? () async {
                                    await _controller.captureImage(
                                        _controller.cameraController);
                                  }
                                : null,
                            child: Obx(
                              () => Container(
                                width: width * 0.18,
                                height: width * 0.18,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(0.5),
                                ),
                                alignment: Alignment.center,
                                child: _controller.isLoading.value
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : Container(
                                        width: width * 0.15,
                                        height: width * 0.15,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 32),
                        //Button to change the camera view and the image (mirrored or not)
                        GestureDetector(
                          onTap: _controller.mirroredImageChanger,
                          child: Container(
                            width: width * 0.13,
                            height: width * 0.13,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.loop,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
