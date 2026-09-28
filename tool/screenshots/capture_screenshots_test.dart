// Not a correctness test (lives under tool/, not test/, so `flutter test`
// never picks it up) — it renders each screen's *_template_preview.dart
// fixture harness (real app widgets, fixture data, no bloc/router/repository
// needed) to an actual PNG via Flutter's own test rendering pipeline, so the
// README can show real screenshots without needing a device/emulator.
//
// Run with: flutter test tool/screenshots/capture_screenshots_test.dart
//
// It always reports as "failed": google_fonts fires one harmless
// fire-and-forget network fetch attempt per text style (there's no
// path_provider in a test binary to cache it), which the test framework
// surfaces as a trailing async exception after the real work is already
// done. Check docs/screenshots/*.png for the actual result.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:voya/core/presentation/widget/templates/history/history_template_preview.dart';
import 'package:voya/core/presentation/widget/templates/home/home_template_preview.dart';
import 'package:voya/core/presentation/widget/templates/interview_results/interview_result_template_preview.dart';
import 'package:voya/core/presentation/widget/templates/interview_setup/interview_setup_template_preview.dart';
import 'package:voya/core/presentation/widget/templates/profile/profile_template_preview.dart';
import 'package:voya/core/presentation/widget/templates/settings/settings_template_preview.dart';

const _logicalSize = Size(393, 852); // iPhone 15-ish
const _pixelRatio = 3.0;

/// `flutter test` doesn't load real font assets by default (nor does
/// `path_provider`-backed google_fonts caching work without a platform), so
/// text/icons render as placeholder glyphs unless the actual font bytes are
/// registered under the exact family name the engine looks up.
///
/// `google_fonts` always sets `fontFamily` to a composite string —
/// `"<Family>_<variant>"`, e.g. `"PlusJakartaSans_600"` for weight 600, or
/// `"PlusJakartaSans_regular"` for weight 400 (see
/// `GoogleFontsVariant.toString()` in the package source) — regardless of
/// whether the real font ever finishes loading, so registering fonts under
/// those exact composite names (rather than the plain family name, which is
/// only a *supplementary glyph-coverage* fallback, not a substitute for a
/// missing primary family) is what actually makes real glyphs render here.
Future<void> _loadTestFonts() async {
  Future<void> load(String family, String path) async {
    final loader = FontLoader(family);
    loader.addFont(
      Future(() async {
        final bytes = await File(path).readAsBytes();
        return ByteData.view(bytes.buffer);
      }),
    );
    await loader.load();
  }

  await load('PlusJakartaSans_regular', 'tool/screenshots/fonts/PlusJakartaSans-Regular.ttf');
  await load('PlusJakartaSans_600', 'tool/screenshots/fonts/PlusJakartaSans-SemiBold.ttf');
  await load('PlusJakartaSans_700', 'tool/screenshots/fonts/PlusJakartaSans-Bold.ttf');
  await load('MaterialIcons', 'tool/screenshots/fonts/MaterialIcons-Regular.otf');
}

Future<void> _capture(WidgetTester tester, Widget widget, String filename) async {
  tester.view.physicalSize = _logicalSize * _pixelRatio;
  tester.view.devicePixelRatio = _pixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(RepaintBoundary(child: widget));

  // Real asset images (Image.asset) load via genuine file I/O, which doesn't
  // resolve inside flutter_test's FakeAsync zone — pumpAndSettle alone won't
  // wait for it, so the icon would render blank. Doing the settle inside
  // runAsync lets that I/O actually complete before capturing.
  final bytes = await tester.runAsync(() async {
    await tester.pumpAndSettle();
    final boundary =
        tester.renderObject(find.byType(RepaintBoundary).first) as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 1.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  });

  final dir = Directory('docs/screenshots');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  File('${dir.path}/$filename').writeAsBytesSync(bytes!);
}

void main() {
  setUpAll(() async {
    // google_fonts can't cache a network-fetched font without a platform
    // (path_provider has no test implementation), so it always fails here —
    // load the real bytes manually instead under the family name it falls
    // back to.
    GoogleFonts.config.allowRuntimeFetching = false;
    await _loadTestFonts();
  });

  testWidgets('capture screenshots for the README', (tester) async {
    await _capture(tester, const HomeTemplatePreview(), 'home.png');
    await _capture(tester, const HistoryTemplatePreview(), 'history.png');
    await _capture(tester, const InterviewSetupTemplatePreview(), 'interview_setup.png');
    await _capture(tester, const InterviewResultTemplatePreview(), 'interview_result.png');
    await _capture(tester, const ProfileTemplatePreview(), 'profile.png');
    await _capture(tester, const SettingsTemplatePreview(), 'settings.png');
  });
}
