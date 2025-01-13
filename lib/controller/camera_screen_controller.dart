import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';

class CameraScreenController extends GetxController {
  late CameraController cameraController;

  final Rx<File?> imageFile = Rx<File?>(null);
  final RxString message = "Positioned your face on the block.".obs;
  final RxBool isLoading = false.obs;
  RxBool isFaceCentered = false.obs;
  final RxBool isCameraInitialized = false.obs;
  late List<Face> totalFaces = [];
  final RxBool changeMirrored = false.obs;

  // Rx<FlashMode> flashMode = FlashMode.off.obs;

  @override
  void onInit() {
    _initializeCamera();
    super.onInit();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
    );

    cameraController = CameraController(
      frontCamera,
      ResolutionPreset.high,
    );

    await cameraController.initialize();
    isCameraInitialized.value = true;
  }

  bool _isFaceCentered(Face face, int imageWidth, int imageHeight) {
    // Define the center region as a percentage of the image dimensions
    const double centerRegionWidthPercentage = 0.1;
    const double centerRegionHeightPercentage = 0.1;

    // Calculate the center region boundaries
    final double centerX = imageWidth / 2;
    final double centerY = imageHeight / 2;
    final double centerRegionWidth = imageWidth * centerRegionWidthPercentage;
    final double centerRegionHeight =
        imageHeight * centerRegionHeightPercentage;

    final double leftBoundary = centerX - (centerRegionWidth / 2);
    final double rightBoundary = centerX + (centerRegionWidth / 2);
    final double topBoundary = centerY - (centerRegionHeight / 2);
    final double bottomBoundary = centerY + (centerRegionHeight / 2);

    // Get the face's bounding box
    final Rect boundingBox = face.boundingBox;

    // Check if the face's bounding box is within the center region
    final double faceCenterX = (boundingBox.left + boundingBox.right) / 2;
    final double faceCenterY = (boundingBox.top + boundingBox.bottom) / 2;

    return faceCenterX >= leftBoundary &&
        faceCenterX <= rightBoundary &&
        faceCenterY >= topBoundary &&
        faceCenterY <= bottomBoundary;
  }

  Future<bool> detectFace(File imageFile) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        performanceMode: FaceDetectorMode.fast,
      ),
    );

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
    img.Image flippedImage = img.decodeJpg(await rawImage.readAsBytes())!;
    flippedImage = img.flipHorizontal(flippedImage);
    await img.encodeJpgFile(rawImage.path, flippedImage);
  }

  void mirroredImageChanger() {
    changeMirrored.value = !changeMirrored.value;
  }
}
