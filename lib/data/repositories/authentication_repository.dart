import 'package:dio/dio.dart';
import 'package:dojodex_instructor/common/architecture/base_repository.dart';
import 'package:dojodex_instructor/env/env.dart';
import 'package:dojodex_common/exceptions/custom_exception_converter.dart';
import 'package:dojodex_common/models/session_token/session_token.dart';
import 'package:dojodex_common/models/user/user.dart';
import 'package:http/http.dart' as http;

class AuthenticationRepository extends BaseRepository {
  AuthenticationRepository({required Dio dio}) : super(dio);

  Future<SessionToken?> login({
    required String email,
    required String password,
  }) async {
    final Map<String, dynamic> credential = {
      'username': email,
      'password': password,
    };

    try {
      final response = await dio.post(
        '/jwt-auth/v1/token',
        data: credential,
      );

      final data = response.data['data'];

      final sessionToken = SessionToken.fromJson(data);

      return sessionToken;
    } on DioException catch (e) {
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }

  Future<User?> getMe() async {
    try {
      final response = await dio.get(
        '/wp/v2/users/me',
      );

      final data = response.data;
      final user = User.fromJson(data);

      return user;
    } on DioException catch (e) {
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }

  Future<void> register({
    required String username,
    required String password,
  }) async {
    final Map<String, dynamic> data = {
      'username': username,
      'password': password,
      'apikey': EnvValues.jwtSecret
    };

    try {
      await dio.post(
        '/api/v1/mo-jwt-register',
        data: data,
      );
    } on DioException catch (e) {
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }

  Future<void> updateMe({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    bool? isFromRegistration,
  }) async {
    var url = '/wp/v2/users/$id';

    url =
        '$url?first_name=$firstName&last_name=$lastName&email=$email&name=$firstName $lastName';

    try {
      if (isFromRegistration ?? false) {
        /// Set user role to customer
        await _updateTheUserDataAsAdmin(url);
        return;
      }
      await dio.put(
        url,
      );
    } on DioException catch (e) {
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }

  Future<void> _updateTheUserDataAsAdmin(String url) async {
    try {
      /// Set user role to customer
      final roles = ['customer', 'subscriber'];

      url = '$url&roles=${roles.join(',')}';

      /// Allow admin to update user data
      final adminUrlLogin = await login(
        email: EnvValues.adminUsername,
        password: EnvValues.adminPassword,
      );

      final uri = Uri.parse(dio.options.baseUrl + url);

      await http.put(uri, headers: {
        'Authorization': 'Bearer ${adminUrlLogin?.token}',
      });
    } on DioException catch (e) {
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }

  Future<List<User>?> fetchUsers(String? searchValue) async {
    try {
      if (searchValue == null || searchValue.isEmpty) {
        return [];
      }

      final Map<String, dynamic> map = {
        'search': searchValue,
      };
      final response = await dio.get(
        '/wp/v2/users',
        data: map,
      );

      final data = response.data;

      final users = data.map<User>((user) => User.fromJson(user)).toList();

      return users;
    } on DioException catch (e) {
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }

  Future<List<String>?> fetchClubMemberIds(String clubId) async {
    try {
      final response = await dio.post(
        '/wcra/v1/get_club_users/?secret_key=${EnvValues.secretKey}',
        data: {
          'club_id': clubId,
        },
      );

      final data = response.data['data'];

      final memberIds =
          data.map<String>((memberId) => memberId.toString()).toList();

      return memberIds;
    } on DioException catch (e) {
      final errorData = e.error as Map<String, dynamic>;
      throw const CustomExceptionConverter().fromJson(errorData);
    }
  }
}
