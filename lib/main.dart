import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:voya/app.dart';
import 'package:voya/core/data/repositories/interview_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Required by the Rive 0.13.x runtime before loading any .riv file.
  await RiveFile.initialize();
  final prefs = await SharedPreferences.getInstance();
  runApp(VoyaApp(repository: InterviewRepositoryImpl(prefs)));
}
