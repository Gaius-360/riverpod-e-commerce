/// Mocked user profile shown on the profile screen.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    required this.avatarInitials,
    required this.memberSince,
    required this.shippingAddress,
    required this.ordersCount,
  });

  final String name;
  final String email;
  final String avatarInitials;
  final DateTime memberSince;
  final String shippingAddress;
  final int ordersCount;
}
