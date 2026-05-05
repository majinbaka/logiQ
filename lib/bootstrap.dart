import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/storage/storage_initializer.dart';

Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageInitializer.instance.initialize();
  runApp(const MainApp());
}
