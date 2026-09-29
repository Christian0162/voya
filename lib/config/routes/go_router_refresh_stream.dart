import 'dart:async';

import 'package:flutter/foundation.dart';

/// Turns any [Stream] into a [Listenable] go_router's `refreshListenable` can
/// use — go_router doesn't ship this itself (it's the standard pattern from
/// its own docs for triggering `redirect` re-evaluation on auth-state
/// changes), so it's a small hand-rolled wrapper rather than a dependency.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
