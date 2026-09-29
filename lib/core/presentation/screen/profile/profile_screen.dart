import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:voya/core/presentation/bloc/auth/auth_cubit.dart';
import 'package:voya/core/presentation/widget/templates/profile/profile_template.dart';

/// Shows the signed-in user (from [AuthCubit]) and wires Settings/Edit
/// Profile/Sign Out. Signing out needs no manual navigation — `AppRouter`'s
/// redirect reacts to the auth-state change and bounces to `/sign-in`.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
    return ProfileTemplate(
      user: user,
      onOpenSettings: () => context.push('/settings'),
      onEditProfile: () => context.push('/profile/edit'),
      onSignOut: () => context.read<AuthCubit>().signOut(),
    );
  }
}
