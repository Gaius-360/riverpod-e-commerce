import '../models/user_profile.dart';

/// Fetches the (mocked) currently signed-in user profile.
class UserRepository {
  const UserRepository();

  Future<UserProfile> fetchCurrentUser() async {
    await Future.delayed(const Duration(milliseconds: 500));

    return UserProfile(
      name: 'Amara Diallo',
      email: 'amara.diallo@example.com',
      avatarInitials: 'AD',
      memberSince: DateTime(2023, 4, 12),
      shippingAddress: '12 Rue des Lilas, 75011 Paris, France',
      ordersCount: 7,
    );
  }
}
