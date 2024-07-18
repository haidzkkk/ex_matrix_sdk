import 'package:ex_sdk_matrix/data/provider/room_provider.dart';
import 'package:ex_sdk_matrix/screen/auth/splass_screen.dart';
import 'package:ex_sdk_matrix/ultis/flutter_overlay.dart';
import 'package:flutter/material.dart';
import 'package:matrix/matrix.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/provider/auth_provider.dart';
import 'data/provider/home_provider.dart';
import 'overlay_window/overlay_window_screen.dart';


void main() async {
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();

  var pres = await SharedPreferences.getInstance();
  final client = Client(
    'Matrix Example Chat',
    databaseBuilder: (_) async {
      final dir = await getApplicationSupportDirectory();
      final db = HiveCollectionsDatabase('matrix_example_chat1', dir.path);
      await db.open();
      return db;
    },
  );
  await client.init();


  FlutterOverlay.closeOverlay();
  runApp(
      MaterialApp(
        title: 'Matrix Example Chat',
        builder: (context, child) => MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => HomeProvider(client),),
            ChangeNotifierProvider(create: (context) => AuthProvider(client, pres),),
            ChangeNotifierProvider(create: (context) => RoomProvider(client),),
          ],
          child: child,
        ),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      )
  );
}

// overlay entry point
@pragma("vm:entry-point")
void overlayMain() async{
  Provider.debugCheckInvalidValueType = null;
  WidgetsFlutterBinding.ensureInitialized();

  var pres = await SharedPreferences.getInstance();
  final client = Client(
    'Matrix Example Chat',
    databaseBuilder: (_) async {
      final dir = await getApplicationSupportDirectory();
      final db = HiveCollectionsDatabase('matrix_example_chat2', dir.path);
      await db.open();
      return db;
    },

  );

  await client.init();

  runApp(
    MaterialApp(
      builder: (context, child) => MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => HomeProvider(client),),
          ChangeNotifierProvider(create: (context) => AuthProvider(client, pres),),
          ChangeNotifierProvider(create: (context) => RoomProvider(client),),
        ],
        child: child,
      ),
      debugShowCheckedModeBanner: false,
      home: const OverlayWindowScreen(),
    ),
  );
}

