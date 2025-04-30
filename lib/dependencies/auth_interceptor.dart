import 'package:dio/dio.dart';
import 'package:dojodex_instructor/common/services/token_service.dart';
import 'package:dojodex_instructor/dependencies/dependency_manager.dart';
import 'package:logger/web.dart';

class AuthInterceptor extends InterceptorsWrapper {
  final Dio dio;

  AuthInterceptor(this.dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    options.headers.addAll({
      Headers.contentTypeHeader: Headers.jsonContentType,
      Headers.acceptHeader: Headers.jsonContentType,
    });

    if (options.headers['is_admin'] != null && options.headers['is_admin']) {
      handler.next(options);
      return;
    }

    var token = await sl.get<TokenService>().getToken();

    sl<Logger>().i("token: $token");
    if (token != null) {
      options.headers.addAll({
        'Authorization': 'Bearer $token',
      });
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // if (err.response?.statusCode == 401) {
    //   final forbiden = DioError(
    //     requestOptions: err.requestOptions,
    //     error: err.response?.data['message'],
    //   );
    //   return handler.next(forbiden);
    // }
    if (err.response?.statusCode == 500 ||
        err.response?.statusCode == 400 ||
        err.response?.statusCode == 401 ||
        err.response?.statusCode == 403) {
      final internalServer = DioException(
        requestOptions: err.requestOptions,
        error: err.response?.data,
      );
      return handler.next(internalServer);
    }
    return handler.next(err);
  }
}
