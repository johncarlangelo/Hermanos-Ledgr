import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hermanos_ledgr/features/accounts/providers/accounts_provider.dart';
import 'package:hermanos_ledgr/features/ai_assistant/providers/ai_assistant_provider.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/data/ocr_service.dart';
import 'package:hermanos_ledgr/features/receipt_scanner/domain/receipt_scan_result.dart';

enum ReceiptScanStatus { idle, capturing, processing, success, error }

class ReceiptScannerState {
  final ReceiptScanStatus status;
  final ReceiptScanResult? result;
  final String? errorMessage;
  final String? imagePath;

  const ReceiptScannerState({
    this.status = ReceiptScanStatus.idle,
    this.result,
    this.errorMessage,
    this.imagePath,
  });

  ReceiptScannerState copyWith({
    ReceiptScanStatus? status,
    ReceiptScanResult? result,
    String? errorMessage,
    String? imagePath,
    bool clearResult = false,
  }) {
    return ReceiptScannerState(
      status: status ?? this.status,
      result: clearResult ? null : (result ?? this.result),
      errorMessage: errorMessage ?? this.errorMessage,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

final ocrServiceProvider = Provider<OcrService>((ref) {
  final service = OcrService();
  ref.onDispose(() => service.dispose());
  return service;
});

class ReceiptScannerNotifier extends Notifier<ReceiptScannerState> {
  final ImagePicker _picker = ImagePicker();

  @override
  ReceiptScannerState build() => const ReceiptScannerState();

  OcrService get _ocrService => ref.read(ocrServiceProvider);

  /// Captures a photo using device camera and scans it.
  Future<void> scanFromCamera() async {
    try {
      state = state.copyWith(status: ReceiptScanStatus.capturing);
      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 90,
      );

      if (photo == null) {
        state = state.copyWith(status: ReceiptScanStatus.idle);
        return;
      }

      await processImagePath(photo.path);
    } catch (e) {
      state = state.copyWith(
        status: ReceiptScanStatus.error,
        errorMessage: 'Camera error: $e',
      );
    }
  }

  /// Selects a photo from gallery and scans it (Task 10.6).
  Future<void> scanFromGallery() async {
    try {
      state = state.copyWith(status: ReceiptScanStatus.capturing);
      final photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );

      if (photo == null) {
        state = state.copyWith(status: ReceiptScanStatus.idle);
        return;
      }

      await processImagePath(photo.path);
    } catch (e) {
      state = state.copyWith(
        status: ReceiptScanStatus.error,
        errorMessage: 'Gallery error: $e',
      );
    }
  }

  /// Processes an image path through OCR and hybrid parsing.
  Future<void> processImagePath(String path) async {
    state = state.copyWith(
      status: ReceiptScanStatus.processing,
      imagePath: path,
      clearResult: true,
      errorMessage: null,
    );

    try {
      final llmService = ref.read(llmServiceProvider);
      final accounts = ref.read(accountsProvider).map((a) => a.name).toList();

      final scanResult = await _ocrService.processReceiptImage(
        imagePath: path,
        optionalLlmService: llmService,
        availableAccounts: accounts,
      );

      state = state.copyWith(
        status: ReceiptScanStatus.success,
        result: scanResult,
      );
    } catch (e) {
      state = state.copyWith(
        status: ReceiptScanStatus.error,
        errorMessage: 'OCR processing error: $e',
      );
    }
  }

  /// Resets scanner state.
  void reset() {
    state = const ReceiptScannerState();
  }
}

final receiptScannerProvider =
    NotifierProvider<ReceiptScannerNotifier, ReceiptScannerState>(
  ReceiptScannerNotifier.new,
);
