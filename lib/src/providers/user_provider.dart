import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import 'repository_providers.dart';

/// Mocked, asynchronously loaded profile of the signed-in user.
final userProfileProvider = FutureProvider<UserProfile>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.fetchCurrentUser();
});
