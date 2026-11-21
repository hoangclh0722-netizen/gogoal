import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_setup.dart';
import '../data/firestore_chat_repository.dart';
import '../domain/chat_message.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => FirestoreChatRepository(appFirestore));

final messagesProvider = StreamProvider.autoDispose.family<List<ChatMessage>, String>(
  (ref, matchId) => ref.watch(chatRepositoryProvider).watch(matchId),
);
