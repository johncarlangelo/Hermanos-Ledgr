import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hermanos_ledgr/core/providers/database_provider.dart';
import 'package:hermanos_ledgr/features/ai_assistant/data/chat_repository_impl.dart';
import 'package:hermanos_ledgr/features/ai_assistant/domain/chat_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ChatRepositoryImpl(db.chatDao);
});
