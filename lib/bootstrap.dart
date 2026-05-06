import 'dart:async';

import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'app/startup_error_app.dart';
import 'core/storage/storage_initializer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    Zone.current.handleUncaughtError(
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  await runZonedGuarded(() async {
    await StorageInitializer.instance.initialize();
    runApp(const MainApp());
  }, (error, stackTrace) {
    runApp(const StartupErrorApp());
  });
}
