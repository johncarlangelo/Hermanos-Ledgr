import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/shared/utils/image_cropper_util.dart';
import 'package:image/image.dart' as img_lib;

void main() {
  group('ImageCropperUtil', () {
    late Uint8List landscapeImageBytes;
    late Uint8List portraitImageBytes;

    setUp(() {
      // 800x400 landscape test image
      final landscape = img_lib.Image(width: 800, height: 400);
      img_lib.fill(landscape, color: img_lib.ColorRgb8(100, 150, 200));
      landscapeImageBytes = Uint8List.fromList(img_lib.encodePng(landscape));

      // 400x800 portrait test image
      final portrait = img_lib.Image(width: 400, height: 800);
      img_lib.fill(portrait, color: img_lib.ColorRgb8(200, 150, 100));
      portraitImageBytes = Uint8List.fromList(img_lib.encodePng(portrait));
    });

    test('extracts dimensions correctly', () {
      final dims = ImageCropperUtil.getImageDimensions(landscapeImageBytes);
      expect(dims, isNotNull);
      expect(dims!.$1, 800);
      expect(dims.$2, 400);
    });

    test('crops landscape image to 1:1 512x512 square', () {
      // Viewport 260x260, displayed width 520, height 260 (at scale 1.0, centered at offsetX = -130, offsetY = 0)
      final resultBase64 = ImageCropperUtil.cropToSquare(
        rawBytes: landscapeImageBytes,
        viewportSize: 260,
        displayedWidth: 520,
        displayedHeight: 260,
        offsetX: -130,
        offsetY: 0,
        scale: 1.0,
      );

      expect(resultBase64, isNotNull);
      final decodedBytes = base64Decode(resultBase64!);
      final resultImg = img_lib.decodeImage(decodedBytes);
      expect(resultImg, isNotNull);
      expect(resultImg!.width, 512);
      expect(resultImg.height, 512);
    });

    test('crops portrait image with zoom scaling', () {
      // Viewport 260x260, displayed width 260, height 520, scale 1.5
      final resultBase64 = ImageCropperUtil.cropToSquare(
        rawBytes: portraitImageBytes,
        viewportSize: 260,
        displayedWidth: 260,
        displayedHeight: 520,
        offsetX: 0,
        offsetY: -100,
        scale: 1.5,
      );

      expect(resultBase64, isNotNull);
      final decodedBytes = base64Decode(resultBase64!);
      final resultImg = img_lib.decodeImage(decodedBytes);
      expect(resultImg, isNotNull);
      expect(resultImg!.width, 512);
      expect(resultImg.height, 512);
    });
  });
}
