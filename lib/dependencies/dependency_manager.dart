import 'package:dio/dio.dart';
import 'package:dojodex_common/services/toast_service.dart';
import 'package:dojodex_instructor/common/routes/onboarding_router.dart';
import 'package:dojodex_instructor/common/routes/route_helper.dart';
import 'package:dojodex_instructor/common/services/club_service.dart';
import 'package:dojodex_instructor/common/services/modal_service.dart';
import 'package:dojodex_instructor/common/services/token_service.dart';
import 'package:dojodex_instructor/common/services/user_service.dart';
import 'package:dojodex_instructor/common/utils/image_utils.dart';
import 'package:dojodex_instructor/data/database/database_service.dart';
import 'package:dojodex_instructor/data/repositories/authentication_repository.dart';
import 'package:dojodex_instructor/data/repositories/club_repository.dart';
import 'package:dojodex_instructor/data/repositories/lesson_repository.dart';
import 'package:dojodex_instructor/data/repositories/message_repository.dart';
import 'package:dojodex_instructor/data/repositories/setting_repository.dart';
import 'package:dojodex_instructor/data/repositories/sp_attendance_repository.dart';
import 'package:dojodex_instructor/data/repositories/sp_lesson_schedule_repository.dart';
import 'package:dojodex_instructor/data/repositories/sp_message_repository.dart';
import 'package:dojodex_instructor/dependencies/auth_interceptor.dart';
import 'package:dojodex_instructor/env/env.dart';
import 'package:dojodex_common/models/app_environment.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get_it/get_it.dart';
import 'package:dojodex_instructor/common/routes/main_router.dart';
import 'package:dojodex_instructor/common/routes/root_router.dart';
import 'package:dojodex_instructor/common/utils/app_logger.dart';
import 'package:logger/web.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:sembast/sembast_io.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Global dependency locator used across the codebase
GetIt sl = GetIt.I;

extension GetItExtension on GetIt {
  Future<void> ensureReady<T extends Object>() async {
    try {
      await isReady<T>();
    } on Exception catch (e) {
      debugPrint("ensureReady caught exception $e");
    }
  }
}

class DependencyManager {
  bool initialized = false;

  DependencyManager() {
    // Helpers
    provideLogger();
    provideRouteHelper();
    provideFaker();
    provideDIO();
    provideModalService();
    provideImageService();
    provideFToast();
    provideDojoDexToastService();
    provideSupabaseClient();

    // App Environment
    provideEnvironment();

    // Routes
    provideMainRouter();
    provideRootRouter();
    provideOnboardingRouter();

    // Repositories
    provideRepositories();

    // Databases
    provideSharedPreferences();
    provideLocalDatabase();
    provideDatabaseService();
    provideUserService();
    provideClubService();
    provideFlutterSecureStorage();

    sl<Logger>().i({"Initialized"});
  }

  void provideDIO() {
    // Register DIO
    sl.registerLazySingleton<Dio>(() {
      var dio = Dio();

      String? baseUrl = EnvValues.baseUrl;

      sl<Logger>().i({"URL: $baseUrl"});

      bool willLog = false;

      return dio
        ..options = BaseOptions(
          baseUrl: baseUrl,
          receiveTimeout: const Duration(seconds: 60),
          connectTimeout: const Duration(seconds: 60),
        )
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: willLog,
            requestBody: willLog,
            responseBody: willLog,
            responseHeader: willLog,
            error: true,
            compact: true,
            maxWidth: 90,
          ),
        )
        ..interceptors.add(
          AuthInterceptor(dio),
        );
    });
  }

  Future<void> init() async {
    await sl.allReady();

    initialized = true;
  }

  Future<void> dispose() async {
    await sl.reset();
  }

  void provideEnvironment() {
    sl<Logger>().i({"Creating ${EnvValues.env} database"});
    sl.registerLazySingleton<AppEnvironment>(() {
      return AppEnvironment(
        env: EnvValues.env,
        flavor: EnvValues.flavor,
        appName: EnvValues.appName,
        databaseName: EnvValues.databaseName,
      );
    });
  }

  void provideFaker() {
    sl.registerLazySingleton<Faker>(
      () => Faker(),
    );
  }

  void provideFlutterSecureStorage() async {
    sl.registerLazySingleton<FlutterSecureStorage>(
      () => const FlutterSecureStorage(),
    );

    // Register TokenHelper
    sl.registerLazySingleton<TokenService>(
      () => TokenService(sl<FlutterSecureStorage>()),
    );
  }

  Future<void> provideLocalDatabase() async {
    final appDir = await getApplicationDocumentsDirectory();
    await appDir.create(recursive: true);
    sl<Logger>().i({"Creating database"});
    final databasePath = p.join(
      appDir.path,
      sl<AppEnvironment>().databaseName,
    );
    final database = await databaseFactoryIo.openDatabase(
      databasePath,
      version: 1,
    );

    sl.registerSingleton<Database>(database);
  }

  void provideDatabaseService() {
    sl.registerLazySingleton(
      () => DatabaseService(
        db: sl.get<Database>(),
        logger: sl.get<Logger>(),
      ),
    );
  }

  void provideUserService() {
    sl.registerLazySingleton(
      () => UserService(
        sl.get<DatabaseService>(),
      ),
    );
  }

  void provideClubService() {
    sl.registerLazySingleton(
      () => ClubService(
        sl.get<DatabaseService>(),
      ),
    );
  }

  void provideRouteHelper() {
    sl.registerSingleton<RouteHelper>(RouteHelper());
  }

  void provideSharedPreferences() {
    sl.registerSingletonAsync<SharedPreferences>(() async {
      final sharedPreferences = await SharedPreferences.getInstance();

      return sharedPreferences;
    });
  }

  void provideMainRouter() {
    sl.registerSingleton<MainRouter>(MainRouter());
  }

  void provideRootRouter() {
    sl.registerSingleton<RootRouter>(RootRouter());
  }

  void provideLogger() {
    sl.registerLazySingleton<Logger>(
      () => Logger(
        printer: AppLogger(),
      ),
    );
  }

  void provideRepositories() {
    /// SettingRepository
    sl.registerLazySingleton<SettingRepository>(
      () => SettingRepository(
        dio: sl<Dio>(),
      ),
    );

    /// AuthenticationRepository
    sl.registerLazySingleton<AuthenticationRepository>(
      () => AuthenticationRepository(
        dio: sl<Dio>(),
      ),
    );

    /// ClubRepository
    sl.registerLazySingleton<ClubRepository>(
      () => ClubRepository(
        dio: sl<Dio>(),
      ),
    );

    /// ClubRepository
    sl.registerLazySingleton<MessageRepository>(
      () => MessageRepository(
        dio: sl<Dio>(),
      ),
    );

    /// LessonRepository
    sl.registerLazySingleton<LessonRepository>(
      () => LessonRepository(
        dio: sl<Dio>(),
      ),
    );

    /// SupabaseMessageRepository
    sl.registerLazySingleton<SupabaseMessageRepository>(
      () => SupabaseMessageRepository(
        supabase: sl<SupabaseClient>(),
      ),
    );

    /// SupabaseLessonScheduleRepository
    sl.registerLazySingleton<SupabaseLessonScheduleRepository>(
      () => SupabaseLessonScheduleRepository(
        supabase: sl<SupabaseClient>(),
      ),
    );

    /// SupabaseAttendanceRepository
    sl.registerLazySingleton<SupabaseAttendanceRepository>(
      () => SupabaseAttendanceRepository(
        supabase: sl<SupabaseClient>(),
      ),
    );
  }

  Future<SupabaseClient?> provideSupabaseClient() async {
    /// instance of Supabase
    sl.registerSingletonAsync<SupabaseClient>(() async {
      await Supabase.initialize(
        url: EnvValues.supabaseUrl,
        anonKey: EnvValues.supabaseAnonKey,
      );

      return Supabase.instance.client;
    });
    return null;
  }

  void provideModalService() {
    sl.registerLazySingleton<ModalService>(ModalService.new);
  }

  void provideOnboardingRouter() {
    sl.registerSingleton<OnboardingRouter>(OnboardingRouter());
  }

  void provideImageService() {
    sl.registerLazySingleton<ImageService>(ImageService.new);
  }

  void provideFToast() {
    sl.registerLazySingleton<FToast>(() => FToast());
  }

  void provideDojoDexToastService() {
    sl.registerLazySingleton<ToastService>(
      () => ToastService(
        fToast: sl<FToast>(),
      ),
    );
  }
}
