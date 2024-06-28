import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'auth/splass_screen.dart';
import 'overlay_window/overlay_window_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final client = Client(
    'Matrix Example Chat',
    databaseBuilder: (_) async {
      final dir = await getApplicationSupportDirectory();
      final db = HiveCollectionsDatabase('matrix_example_chat', dir.path);
      await db.open();
      return db;
    },
  );
  await client.clear();
  client.clearArchivesFromCache();
  await client.clearCache();
  await client.init();
  runApp(SplashScreen(client: client));
}

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() async{
  WidgetsFlutterBinding.ensureInitialized();

  final client = Client(
    'Matrix Example Chat',
    databaseBuilder: (_) async {
      final dir = await getApplicationSupportDirectory();
      final db = HiveCollectionsDatabase('matrix_example_chat', dir.path);
      await db.open();
      return db;
    },

  );

  await client.init();
  runApp(
    MaterialApp(
      builder: (context, child) => Provider<Client>(
        create: (context) => client,
        child: child,
      ),
      debugShowCheckedModeBanner: false,
      home: const OverlayWindowScreen(),
    ),
  );
}

