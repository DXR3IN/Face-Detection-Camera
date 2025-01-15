import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

double translateX(
  double x,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  double correctedX;

  switch (rotation) {
    case InputImageRotation.rotation90deg:
      correctedX = x *
          canvasSize.width /
          (Platform.isIOS ? imageSize.width : imageSize.height);
      break;
    case InputImageRotation.rotation270deg:
      correctedX = canvasSize.width -
          x *
              canvasSize.width /
              (Platform.isIOS ? imageSize.width : imageSize.height);
      break;
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      correctedX = x * canvasSize.width / imageSize.width;
      break;
  }

  if (cameraLensDirection == CameraLensDirection.front) {
    correctedX = canvasSize.width - correctedX;
  }

  return correctedX;
}

double translateY(
  double y,
  Size canvasSize,
  Size imageSize,
  InputImageRotation rotation,
  CameraLensDirection cameraLensDirection,
) {
  switch (rotation) {
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y *
          canvasSize.height /
          (Platform.isIOS ? imageSize.height : imageSize.width);
    case InputImageRotation.rotation0deg:
    case InputImageRotation.rotation180deg:
      return y * canvasSize.height / imageSize.height;
  }
}
