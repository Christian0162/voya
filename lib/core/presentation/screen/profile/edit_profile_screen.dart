import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:voya/config/constant/app_colors.dart';
import 'package:voya/config/constant/app_spacing.dart';
import 'package:voya/core/error/failure.dart';
import 'package:voya/core/presentation/bloc/auth/auth_cubit.dart';
import 'package:voya/core/presentation/widget/atoms/md_primary_button.dart';

/// Username + avatar editing. The avatar upload talks to Supabase Storage
/// directly (not routed through `AuthRepository`) since it's a one-off
/// upload-then-get-a-url operation, not an auth concern — `updateProfile`
/// still goes through `AuthCubit` like everything else.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _usernameController;
  String? _avatarUrl;
  File? _pickedAvatar;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _avatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final userId = context.read<AuthCubit>().state.user?.id;
    if (userId == null) return;

    setState(() {
      _pickedAvatar = File(picked.path);
      _isUploadingAvatar = true;
      _errorMessage = null;
    });

    try {
      final extension = picked.path.split('.').last;
      final path = '$userId/avatar.$extension';
      final storage = Supabase.instance.client.storage.from('avatars');
      await storage.upload(path, _pickedAvatar!, fileOptions: const FileOptions(upsert: true));
      final publicUrl = storage.getPublicUrl(path);
      // Cache-bust: the path is stable per user, so an updated avatar at the
      // same URL would otherwise keep showing a cached copy of the old one.
      setState(() => _avatarUrl = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}');
    } catch (_) {
      setState(() => _errorMessage = "Couldn't upload that image. Try a different one.");
    } finally {
      if (mounted) setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _save() async {
    final username = _usernameController.text.trim();
    if (username.length < 3) {
      setState(() => _errorMessage = 'Username needs at least 3 characters.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });
    try {
      await context.read<AuthCubit>().updateProfile(username: username, avatarUrl: _avatarUrl);
      if (mounted) Navigator.of(context).maybePop();
    } catch (e) {
      setState(() => _errorMessage = e is Failure ? e.message : 'Something went wrong.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          children: [
            Center(
              child: GestureDetector(
                onTap: _isUploadingAvatar ? null : _pickAvatar,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 48,
                      backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                      child: _avatarUrl == null ? const Icon(Icons.person_rounded, size: 48) : null,
                    ),
                    if (_isUploadingAvatar)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMessage!,
                style: const TextStyle(color: AppColors.error),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            MdPrimaryButton(label: 'Save', isLoading: _isSaving, onPressed: _save),
          ],
        ),
      ),
    );
  }
}
