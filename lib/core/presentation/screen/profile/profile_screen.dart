import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:voya/core/presentation/widget/templates/profile/profile_template.dart';

/// Placeholder profile screen. Kept intentionally minimal for the MVP — the
/// spec's authentication/backend sync (section 25/37) is out of scope until
/// a real backend replaces the local SharedPreferences repository.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileTemplate(onOpenSettings: () => context.push('/settings'));
  }
}
