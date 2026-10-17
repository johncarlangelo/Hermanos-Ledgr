import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermanos_ledgr/app/theme/app_theme.dart';
import 'package:hermanos_ledgr/features/settings/presentation/widgets/profile_photo_adjust_sheet.dart';
import 'package:image/image.dart' as img_lib;

void main() {
  testWidgets('ProfilePhotoAdjustSheet mounts, adjusts zoom slider, resets, and crops 1:1', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Create a 600x400 test image
    final testImg = img_lib.Image(width: 600, height: 400);
    img_lib.fill(testImg, color: img_lib.ColorRgb8(127, 184, 174));
    final testBytes = Uint8List.fromList(img_lib.encodePng(testImg));

    String? returnedResult;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                returnedResult = await ProfilePhotoAdjustSheet.show(
                  context,
                  rawImageBytes: testBytes,
                );
              },
              child: const Text('Open Cropper'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap button to open sheet
    await tester.tap(find.text('Open Cropper'));
    await tester.pumpAndSettle();

    // Verify sheet UI components
    expect(find.text('Adjust 1:1 Crop'), findsOneWidget);
    expect(find.text('Pan & zoom to fit your avatar'), findsOneWidget);
    expect(find.text('1.0x'), findsOneWidget);
    expect(find.text('Center & Reset'), findsOneWidget);
    expect(find.text('Apply 1:1 Crop'), findsOneWidget);

    // Drag zoom slider to increase scale
    final sliderFinder = find.byType(Slider);
    expect(sliderFinder, findsOneWidget);
    await tester.drag(sliderFinder, const Offset(60, 0));
    await tester.pumpAndSettle();

    // Tap Center & Reset
    await tester.tap(find.text('Center & Reset'));
    await tester.pumpAndSettle();
    expect(find.text('1.0x'), findsOneWidget);

    // Tap Apply 1:1 Crop
    await tester.tap(find.text('Apply 1:1 Crop'));
    await tester.pumpAndSettle();

    // Verify modal is dismissed and returnedResult is a valid 512x512 base64 PNG
    expect(find.text('Adjust 1:1 Crop'), findsNothing);
    expect(returnedResult, isNotNull);
    final croppedBytes = base64Decode(returnedResult!);
    final decodedImg = img_lib.decodeImage(croppedBytes);
    expect(decodedImg, isNotNull);
    expect(decodedImg!.width, 512);
    expect(decodedImg.height, 512);
  });
}
