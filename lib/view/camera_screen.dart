import 'package:absence_face_detection/painters/block_painter.dart';
import 'package:absence_face_detection/widget/animated_rotating_icon_widget.dart';
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
  void dispose() {
    _controller.stopFaceDetection();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final paddingTop = MediaQuery.of(context).padding.top;
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            SizedBox(
              height: double.infinity,
              child: Obx(() {
                if (_controller.isCameraInitialized.value) {
                  return _controller.changeMirrored.value
                      ? Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationY(math.pi),
                          child: Center(
                            child: Obx(
                              () => _controller.doItRealTime.value
                                  ? Stack(
                                      children: [
                                        CameraPreview(
                                          _controller.cameraController,
                                          child: _controller.customPaint.value,
                                        ),
                                        for (var face
                                            in _controller.realTimeFaces)
                                          Positioned(
                                            left: face.boundingBox.left,
                                            top: face.boundingBox.top,
                                            child: Container(
                                              width: face.boundingBox.width,
                                              height: face.boundingBox.height,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  : CameraPreview(
                                      _controller.cameraController,
                                    ),
                            ),
                          ),
                        )
                      : Center(
                          child: Obx(
                            () => _controller.doItRealTime.value
                                ? Stack(
                                    children: [
                                      CameraPreview(
                                        _controller.cameraController,
                                        child: _controller.customPaint.value,
                                      ),
                                      for (var face
                                          in _controller.realTimeFaces)
                                        Positioned(
                                          left: face.boundingBox.left,
                                          top: face.boundingBox.top,
                                          child: Container(
                                            width: face.boundingBox.width,
                                            height: face.boundingBox.height,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.transparent,
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                                : CameraPreview(
                                    _controller.cameraController,
                                  ),
                          ),
                        );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              }),
            ),
            BlockPainter(),
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                height: paddingTop + height * 0.1,
                width: width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
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
                    Obx(
                      () => RichText(
                          text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Face Tracking',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          const TextSpan(
                            text: ' : ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                          TextSpan(
                            text: _controller.doItRealTime.value ? 'ON' : 'OFF',
                            style: TextStyle(
                              color: _controller.doItRealTime.value
                                  ? Colors.blue
                                  : Colors.red,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )),
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                  ],
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
                        RotatingIconWidget(
                          icon: Icons.camera,
                          onTap: _controller.toggleRealTime,
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
                        RotatingIconWidget(
                          onTap: _controller.mirroredImageChanger,
                        ),
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
