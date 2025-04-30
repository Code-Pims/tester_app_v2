import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class EnvValues {
  @EnviedField(varName: 'ENV', defaultValue: '', obfuscate: true)
  static String env = _EnvValues.env;

  @EnviedField(varName: 'FLAVOR', defaultValue: '', obfuscate: true)
  static String flavor = _EnvValues.flavor;

  @EnviedField(varName: 'APP_NAME', defaultValue: '', obfuscate: true)
  static String appName = _EnvValues.appName;

  @EnviedField(varName: 'DATABASE_NAME', defaultValue: '', obfuscate: true)
  static String databaseName = _EnvValues.databaseName;

  @EnviedField(varName: 'BASE_URL', defaultValue: '', obfuscate: true)
  static String baseUrl = _EnvValues.baseUrl;

  @EnviedField(varName: 'WEB_BASE_URL', defaultValue: '', obfuscate: true)
  static String webBaseUrl = _EnvValues.webBaseUrl;

  @EnviedField(varName: 'SECRET_KEY', defaultValue: '', obfuscate: true)
  static String secretKey = _EnvValues.secretKey;

  @EnviedField(varName: 'JWT_SECRET', defaultValue: '', obfuscate: true)
  static String jwtSecret = _EnvValues.jwtSecret;

  @EnviedField(varName: 'USERNAME', defaultValue: '', obfuscate: true)
  static String adminUsername = _EnvValues.adminUsername;

  @EnviedField(varName: 'PASSWORD', defaultValue: '', obfuscate: true)
  static String adminPassword = _EnvValues.adminPassword;

  @EnviedField(varName: 'SUPABASE_URL', defaultValue: '', obfuscate: true)
  static String supabaseUrl = _EnvValues.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY', defaultValue: '', obfuscate: true)
  static String supabaseAnonKey = _EnvValues.supabaseAnonKey;

  @EnviedField(
      varName: 'SUPABASE_SERVICE_ROLE', defaultValue: '', obfuscate: true)
  static String supabaseServiceRole = _EnvValues.supabaseServiceRole;

  @EnviedField(
      varName: 'SUPABASE_JWT_SECRET', defaultValue: '', obfuscate: true)
  static String supabaseJwtSecret = _EnvValues.supabaseJwtSecret;
}
