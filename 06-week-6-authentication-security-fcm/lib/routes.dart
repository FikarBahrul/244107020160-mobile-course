class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const home = '/';
  static const announcement = '/pengumuman/:id';

  static String announcementFor(String id) => '/pengumuman/$id';
}

// Refactoring: parsing RemoteMessage -> route dijadikan fungsi murni
// agar bisa diunit-test tanpa Firebase.
String routeFromMessage(Map<String, dynamic> data) {
  final route = (data['route'] as String?) ?? AppRoutes.home;
  return route.startsWith('/') ? route : '/$route';
}
