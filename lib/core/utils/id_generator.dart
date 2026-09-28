// Transaction ID generator matching the SRS format: tx_{hex8}_{hex4}
// TODO: Re-enable uuid package when building for Android
import 'dart:math';

class IdGenerator {
  IdGenerator._();

  static final _random = Random();

  /// Generates a transaction ID like "tx_8f3d92c1_a9e4"
  static String transactionId() {
    final hex = List.generate(12, (_) => _random.nextInt(16).toRadixString(16)).join();
    return 'tx_${hex.substring(0, 8)}_${hex.substring(8, 12)}';
  }
}
