import 'package:equatable/equatable.dart';

/// The signed-in user, combining Supabase's `auth.users` (id/email) with the
/// editable `profiles` table (username/avatar) — the domain/presentation
/// layers see one flat entity and never know two Supabase tables back it.
class AppUser extends Equatable {
  const AppUser({required this.id, required this.email, this.username, this.avatarUrl});

  final String id;
  final String email;
  final String? username;
  final String? avatarUrl;

  String get displayName => username ?? email.split('@').first;

  AppUser copyWith({String? username, String? avatarUrl}) {
    return AppUser(
      id: id,
      email: email,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, email, username, avatarUrl];
}
