import 'dart:io';
import 'package:absence_face_detection/painters/face_detection_painter.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class CameraScreenController extends GetxController {
  late CameraController cameraController;

  final _cameraLensDirection = CameraLensDirection.front;
  final Rx<File?> imageFile = Rx<File?>(null);
  final RxString message = "Positioned your face on the block.".obs;

  final RxBool doItRealTime = false.obs;
  final RxBool isLoading = false.obs;
  RxBool isFaceCentered = false.obs;
  final RxBool isCameraInitialized = false.obs;
  final RxBool changeMirrored = false.obs;

  List<Face> totalFaces = [];
  final RxList<Face> realTimeFaces = <Face>[].obs;

  late Rx<CustomPaint> customPaint;
  String? _text;

  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(enableLandmarks: true, enableContours: true),
  );

  @override
  void onInit() {
    _initializeCamera();
    customPaint = const CustomPaint().obs;
    super.onInit();
  }

  Future stopFaceDetection() async {
    await cameraController.stopImageStream();
    await cameraController.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras[1];

    cameraController = CameraController(
      frontCamera,
      enableAudio: false,
      ResolutionPreset.high,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    await cameraController.initialize();
    isCameraInitialized.value = true;

    if (doItRealTime.value) _startRealTimeFaceDetection(cameraController);
  }

  void toggleRealTime() {
    isCameraInitialized.value = false;
    cameraController.dispose();
    doItRealTime.value = !doItRealTime.value;
    _initializeCamera();
  }

  void _startRealTimeFaceDetection(CameraController cameraController) {
    if (cameraController.value.isStreamingImages) return;
    int frameCount = 0;
    cameraController.startImageStream((image) async {
      frameCount++;
      try {
        if (frameCount % 5 == 0) {
          final inputImage = InputImage.fromBytes(
            bytes: concatenatePlanes(image),
            metadata: InputImageMetadata(
              size: Size(image.width.toDouble(), image.height.toDouble()),
              rotation: InputImageRotationValue.fromRawValue(
                    cameraController.description.sensorOrientation,
                  ) ??
                  InputImageRotation.rotation0deg,
              format: Platform.isAndroid
                  ? InputImageFormat.nv21
                  : InputImageFormat.bgra8888,
              bytesPerRow: image.planes[1].bytesPerRow,
            ),
          );

          final faces = await faceDetector.processImage(inputImage);

          if (inputImage.metadata?.size != null &&
              inputImage.metadata?.rotation != null) {
            final painter = FaceDetectorPainter(
              faces,
              inputImage.metadata!.size,
              inputImage.metadata!.rotation,
              _cameraLensDirection,
            );
            customPaint.value = CustomPaint(painter: painter);
          } else {
            String text = 'Faces found: ${faces.length}\n\n';
            for (final face in faces) {
              text += 'face: ${face.boundingBox}\n\n';
            }
            _text = text;
            customPaint.value = const CustomPaint();
          }
          realTimeFaces.assignAll(faces);
          // print('Faces found: ${faces.length}');
        }
      } catch (e) {
        throw ('Error detecting faces in real-time: $e');
      }
    });
  }

  Future<bool> detectFace(File imageFile) async {
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final List<Face> faces = await faceDetector.processImage(inputImage);

    await faceDetector.close();

    totalFaces = faces;

    if (faces.isNotEmpty) {
      final image = await decodeImageFromList(imageFile.readAsBytesSync());
      isFaceCentered.value =
          _isFaceCentered(faces.first, image.width, image.height);

      return true;
    } else {
      return false;
    }
  }

  Future<void> captureImage(CameraController cameraController) async {
    isLoading.value = true;
    message.value = "Processing Image...";

    try {
      final XFile rawImage = await cameraController.takePicture();

      if (changeMirrored.value) {
        await _mirroredImage(rawImage);
      }

      final File file = File(rawImage.path);

      final isValidFace = await detectFace(file);

      if (isValidFace) {
        imageFile.value = file;

        //check if the face is centered or there's too many faces
        if (!isFaceCentered.value) {
          message.value = "Face is not centered.";
          isLoading.value = false;
          return;
        } else if (totalFaces.length > 1) {
          message.value = "To many face detected: ${totalFaces.length} faces.";
          isLoading.value = false;
          return;
        }

        message.value = "Valid photo!";

        Get.back(result: imageFile.value);
      } else {
        imageFile.value = null;
        message.value = "There's no face on the image.";
        return;
      }
    } catch (e) {
      message.value = "Error on taking image, try again.";
      // Get.snackbar("Error", message.value);
    } finally {
      isLoading.value = false;
    }
  }

  //code to help if the picture need to be mirrored or not
  Future<void> _mirroredImage(XFile rawImage) async {
    final bytes = await rawImage.readAsBytes();
    final img.Image? originalImage = img.decodeImage(bytes);
    if (originalImage != null) {
      final img.Image flippedImage = img.flipHorizontal(originalImage);
      final File output = File(rawImage.path);
      await output.writeAsBytes(img.encodeJpg(flippedImage));
    } else {
      throw Exception("Error decoding image.");
    }
  }

  void mirroredImageChanger() {
    changeMirrored.value = !changeMirrored.value;
  }

  //function to help increase performance Real Time Face Detection
  Uint8List concatenatePlanes(CameraImage image) {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  bool _isFaceCentered(Face face, int imageWidth, int imageHeight) {
    const double centerRegionWidthPercentage = 0.1;
    const double centerRegionHeightPercentage = 0.1;

    final double centerX = imageWidth / 2;
    final double centerY = imageHeight / 2;
    final double centerRegionWidth = imageWidth * centerRegionWidthPercentage;
    final double centerRegionHeight =
        imageHeight * centerRegionHeightPercentage;

    final double leftBoundary = centerX - (centerRegionWidth / 2);
    final double rightBoundary = centerX + (centerRegionWidth / 2);
    final double topBoundary = centerY - (centerRegionHeight / 2);
    final double bottomBoundary = centerY + (centerRegionHeight / 2);

    final Rect boundingBox = face.boundingBox;

    final double faceCenterX = (boundingBox.left + boundingBox.right) / 2;
    final double faceCenterY = (boundingBox.top + boundingBox.bottom) / 2;

    return faceCenterX >= leftBoundary &&
        faceCenterX <= rightBoundary &&
        faceCenterY >= topBoundary &&
        faceCenterY <= bottomBoundary;
  }
}
