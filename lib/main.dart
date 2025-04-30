import 'dart:async';
import 'dart:developer';

import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:dojodex_instructor/dojodex_app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'common/services/sync_service_supabase.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      // Initialize depedency injection
      final DependencyManager dependencyManager;

      dependencyManager = DependencyManager();

      await dependencyManager.init().onError((error, stackTrace) {
        debugPrint("DEPENDENCY MANAGEMENT ERROR: $error $stackTrace");
      });

      SyncServiceSupabase syncServiceSupabase =
          SyncServiceSupabase(Supabase.instance.client);
      syncServiceSupabase.monitorConnection();

      runApp(DojoDexApp(dependencyManager: dependencyManager));
    },
    (error, stack) async {
      log(error.toString());
    },
  );
}
