import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_setup.dart';
import '../data/firestore_rating_repository.dart';
import '../domain/rating.dart';

final ratingRepositoryProvider = Provider<RatingRepository>((ref) => FirestoreRatingRepository(appFirestore));

final tagCountsProvider = FutureProvider.autoDispose.family<Map<RatingTag, int>, String>(
  (ref, uid) => ref.watch(ratingRepositoryProvider).tagCounts(uid),
);
