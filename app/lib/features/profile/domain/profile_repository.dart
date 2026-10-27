import 'user_profile.dart';

abstract interface class ProfileRepository {
  Stream<UserProfile?> watch(String uid);
  Future<UserProfile?> fetch(String uid);
  Future<void> create(UserProfile profile);
  Future<void> update(UserProfile profile);
}
