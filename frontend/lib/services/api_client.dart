import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio = Dio();
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  static const String baseBackendUrl = 'https://shakala.camdvr.org';
  static const String socketBackendUrl = 'wss://shakala.camdvr.org';
  // static const String baseBackendUrl = 'http://192.168.13.123:8000';
  // static const String socketBackendUrl = 'ws://192.168.13.123:8000';

  /// POST Request
  Future<dynamic> post(
    String url,
    String type,
    dynamic dataOrBuilder, {
    bool auth = false,
  }) async {
    dynamic getData() {
      if (dataOrBuilder is Function) {
        return dataOrBuilder();
      }
      return dataOrBuilder;
    }

    String contentType;
    switch (type) {
      case 'json':
        contentType = 'application/json';
        break;
      case 'form':
        contentType = 'multipart/form-data';
        break;
      default:
        contentType = 'application/json';
    }

    Future<Map<String, String>> buildHeaders([String? token]) async {
      final headers = <String, String>{
        'Content-Type': contentType,
      };
      if (auth && token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      return headers;
    }

    try {
      final token = auth ? await secureStorage.read(key: 'access_token') : null;

      final response = await dio.post(
        url,
        data: getData(),
        options: Options(headers: await buildHeaders(token)),
      );

      print('APICLIENT: POST successful: ${response.data}');
      return response.data;

    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && auth) {
        print('APICLIENT: POST 401 → refreshing token...');
        if (await refreshToken()) {
          final newToken = await secureStorage.read(key: 'access_token');
          if (newToken == null) return null;

          try {
            final retryResponse = await dio.post(
              url,
              data: getData(),
              options: Options(headers: await buildHeaders(newToken)),
            );

            print('APICLIENT: POST retry successful: ${retryResponse.data}');
            return retryResponse.data;

          } catch (retryError) {
            print('APICLIENT: POST retry failed: $retryError');
            return null;
          }
        } else {
          print('APICLIENT: POST failed: unable to refresh token');
          return null;
        }
      } else {
        print('APICLIENT: POST failed: ${e.message}');
        print('APICLIENT: RESPONSE STATUS: ${e.response?.statusCode}');
        print('APICLIENT: RESPONSE DATA: ${e.response?.data}');
        return e;
      }
    }
  }

  /// GET Request
  Future<dynamic> get(
    String url, {
    bool auth = false,
    Map<String, dynamic>? queryParams,
  }) async {
    Future<Map<String, String>> buildHeaders([String? token]) async {
      final headers = <String, String>{
        'Accept': 'application/json',
      };
      if (auth && token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      return headers;
    }

    try {
      final token = auth ? await secureStorage.read(key: 'access_token') : null;

      final response = await dio.get(
        url,
        queryParameters: queryParams,
        options: Options(headers: await buildHeaders(token)),
      );

      print('APICLIENT: GET successful: ${response.data}');
      return response.data;

    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && auth) {
        print('APICLIENT: GET 401 → refreshing token...');
        if (await refreshToken()) {
          final newToken = await secureStorage.read(key: 'access_token');
          if (newToken == null) return null;

          try {
            final retryResponse = await dio.get(
              url,
              queryParameters: queryParams,
              options: Options(headers: await buildHeaders(newToken)),
            );

            print('APICLIENT: GET retry successful: ${retryResponse.data}');
            return retryResponse.data;

          } catch (retryError) {
            print('APICLIENT: GET retry failed: $retryError');
            return null;
          }
        } else {
          print('APICLIENT: GET failed: unable to refresh token');
          return null;
        }
      } else {
        print('APICLIENT: GET failed: ${e.message}');
        print('APICLIENT: RESPONSE STATUS: ${e.response?.statusCode}');
        print('APICLIENT: RESPONSE DATA: ${e.response?.data}');
        return e;
      }
    }
  }

  /// PATCH Request
  Future<dynamic> patch(
    String url,
    dynamic data, {
    bool auth = false,
  }) async {
    Future<Map<String, String>> buildHeaders([String? token]) async {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (auth && token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      return headers;
    }

    try {
      final token = auth ? await secureStorage.read(key: 'access_token') : null;

      final response = await dio.patch(
        url,
        data: data,
        options: Options(headers: await buildHeaders(token)),
      );

      print('APICLIENT: PATCH successful: ${response.data}');
      return response.data;

    } on DioException catch (e) {
      if (e.response?.statusCode == 401 && auth) {
        print('APICLIENT: PATCH 401 → refreshing token...');
        if (await refreshToken()) {
          final newToken = await secureStorage.read(key: 'access_token');
          if (newToken == null) return null;

          try {
            final retryResponse = await dio.patch(
              url,
              data: data,
              options: Options(headers: await buildHeaders(newToken)),
            );

            print('APICLIENT: PATCH retry successful: ${retryResponse.data}');
            return retryResponse.data;

          } catch (retryError) {
            print('APICLIENT: PATCH retry failed: $retryError');
            return null;
          }
        } else {
          print('APICLIENT: PATCH failed: unable to refresh token');
          return null;
        }
      } else {
        print('APICLIENT: PATCH failed: ${e.message}');
        print('APICLIENT: RESPONSE STATUS: ${e.response?.statusCode}');
        print('APICLIENT: RESPONSE DATA: ${e.response?.data}');
        return null;
      }
    }
  }

  /// Refresh access token using refresh token
  Future<bool> refreshToken() async {
    try {
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken == null) return false;

      final response = await dio.post(
        '$baseBackendUrl/api/token/refresh/',
        data: {'refresh': refreshToken},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final newAccessToken = response.data['access'];
      await secureStorage.write(key: 'access_token', value: newAccessToken);

      print('APICLIENT: 🔁 Token refreshed');
      return true;

    } catch (e) {
      print('APICLIENT: ❌ Token refresh failed: $e');
      return false;
    }
  }
}

  /*

  ApiClient._internal(this.dio) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('📡 Processing REQUEST to: ${options.path}');
          // Skip adding token for refresh endpoint
          if (options.path.contains('token/refresh/')) {
            return handler.next(options);
          }

          final accessToken = await secureStorage.read(key: 'access_token');
          print('🔐 REQ: Adding token to request: $accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final response = error.response;

          // Check if we should attempt refresh
          if (response?.statusCode == 401 &&
              response?.data['code'] == 'token_not_valid' &&
              !error.requestOptions.path.contains('token/refresh/')) {
            
            // // Prevent multiple refresh attempts
            // if (_isRefreshing) {
            //   // Queue the request to retry after refresh completes
            //   return handler.reject(error);
            // }

            // _isRefreshing = true;
            final refreshToken = await secureStorage.read(key: 'refresh_token');

            if (refreshToken != null) {
              try {
                print('🔄 Attempting token refresh...');
                
                // Create new Dio instance without interceptor to avoid loops
                final plainDio = Dio(dio.options);
                final refreshResponse = await plainDio.post(
                  '$baseBackendUrl/api/token/refresh/',
                  data: {'refresh': refreshToken},
                );

                final newAccessToken = refreshResponse.data['access'];
                print('🔐 New access token obtained: $newAccessToken');
                await secureStorage.write(key: 'access_token', value: newAccessToken);

                final newRequestOptions = error.requestOptions.copyWith(
                  headers: {
                    ...error.requestOptions.headers,
                    'Authorization': 'Bearer $newAccessToken',
                  },
                );

                final retry = await dio.fetch(newRequestOptions);
                return handler.resolve(retry);

              } catch (e) {
                // _isRefreshing = false;
                print('❌ Token refresh failed: $e');
                // await secureStorage.deleteAll();
                // You might want to trigger a logout here
                return handler.reject(error);
              }
            } else {
              // _isRefreshing = false;
              print('❌ No refresh token available');
              await secureStorage.deleteAll();
              return handler.reject(error);
            }
          }
          // _isRefreshing = false;
          return handler.next(error);
        },
      ),
    );
  }

  static final ApiClient _instance = ApiClient._internal(Dio(
    BaseOptions(
      baseUrl: ApiClient.baseBackendUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  ));

  factory ApiClient() {
    return _instance;
  }
  
  */

  


// }