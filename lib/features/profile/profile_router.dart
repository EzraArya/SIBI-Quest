import 'package:go_router/go_router.dart';
import 'package:sibi_quest/features/profile/presentation/pages/change_password_page.dart';
import 'package:sibi_quest/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:sibi_quest/features/profile/presentation/pages/edit_profile_picture_page.dart';
import 'package:sibi_quest/features/profile/presentation/pages/profile_page.dart';

class ProfileRoutes {
  static const String profileName = 'profile';
  static const String profilePath = '/profile';

  static const String editProfileName = 'edit-profile';
  static const String editProfilePath = '/profile/edit';

  static const String editProfilePictureName = 'edit-profile-picture';
  static const String editProfilePicturePath = '/profile/edit-picture';

  static const String changePasswordName = 'change-password';
  static const String changePasswordPath = '/profile/change-password';

  static List<GoRoute> routes() => [
    GoRoute(
      name: profileName,
      path: profilePath,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      name: editProfileName,
      path: editProfilePath,
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      name: editProfilePictureName,
      path: editProfilePicturePath,
      builder: (context, state) => const EditProfilePicturePage(),
    ),
    GoRoute(
      name: changePasswordName,
      path: changePasswordPath,
      builder: (context, state) => const ChangePasswordPage(),
    ),
  ];
}
