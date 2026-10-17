import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:image/image.dart' as img_lib;

/// Utility for cropping and scaling user-uploaded profile pictures to a 1:1 square.
class ImageCropperUtil {
  /// Decodes image bytes to extract original width and height.
  static (int width, int height)? getImageDimensions(Uint8List rawBytes) {
    try {
      final decoded = img_lib.decodeImage(rawBytes);
      if (decoded == null) return null;
      return (decoded.width, decoded.height);
    } catch (_) {
      return null;
    }
  }

  /// Crops an image to a 1:1 square based on user viewport pan and zoom.
  /// Returns a high-definition 512x512 Base64 PNG string.
  static String? cropToSquare({
    required Uint8List rawBytes,
    required double viewportSize,
    required double displayedWidth,
    required double displayedHeight,
    required double offsetX,
    required double offsetY,
    required double scale,
    int outputSize = 512,
  }) {
    try {
      final decoded = img_lib.decodeImage(rawBytes);
      if (decoded == null) return null;

      final origW = decoded.width.toDouble();
      final origH = decoded.height.toDouble();

      final currentW = displayedWidth * scale;
      final currentH = displayedHeight * scale;

      // Viewport position relative to displayed image top-left
      final viewX = -offsetX;
      final viewY = -offsetY;

      // Ratio from displayed coordinates to original image pixels
      final ratioX = origW / currentW;
      final ratioY = origH / currentH;

      double cropX = viewX * ratioX;
      double cropY = viewY * ratioY;
      double cropW = viewportSize * ratioX;
      double cropH = viewportSize * ratioY;

      // Clamp inside image bounds
      cropX = cropX.clamp(0.0, origW - 1.0);
      cropY = cropY.clamp(0.0, origH - 1.0);
      cropW = cropW.clamp(1.0, origW - cropX);
      cropH = cropH.clamp(1.0, origH - cropY);

      final squareDim = math.min(cropW, cropH);

      final cropped = img_lib.copyCrop(
        decoded,
        x: cropX.toInt(),
        y: cropY.toInt(),
        width: squareDim.toInt(),
        height: squareDim.toInt(),
      );

      final resized = img_lib.copyResize(
        cropped,
        width: outputSize,
        height: outputSize,
        interpolation: img_lib.Interpolation.linear,
      );

      final pngBytes = Uint8List.fromList(img_lib.encodePng(resized));
      return base64Encode(pngBytes);
    } catch (_) {
      return null;
    }
  }
}
