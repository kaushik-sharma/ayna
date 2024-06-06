import 'dart:async';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../di.dart';
import '../helpers/ui_helpers.dart';
import 'network_info.dart';

class CustomDio {
  CustomDio._() {
    _dio = Dio(_baseOptions)..interceptors.addAll(_interceptors);
    _retryDio = Dio(_baseOptions)
      ..interceptors.addAll(
        _interceptors.where((element) => element is! _RetryInterceptor),
      );
  }

  static final CustomDio instance = CustomDio._();

  late final Dio _dio;
  late final Dio _retryDio;

  Dio get dio => _dio;

  Dio get retryDio => _retryDio;

  final BaseOptions _baseOptions = BaseOptions(
    baseUrl: '',
    headers: {'Authorization': 'AuthLocalService.instance.getToken()'},
    validateStatus: (status) => true,
    sendTimeout: const Duration(minutes: 5),
    connectTimeout: const Duration(minutes: 5),
    receiveTimeout: const Duration(minutes: 5),
  );

  final List<Interceptor> _interceptors = [
    if (kDebugMode)
      PrettyDioLogger(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
      ),
    _RetryInterceptor(),
  ];
}

class _RetryInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    const int maxRetryCount = 3;
    const Duration retryDelay = Duration(seconds: 5);

    for (int i = 0; i < maxRetryCount; i++) {
      final isConnected = await sl<NetworkInfo>().isConnected;
      if (isConnected) {
        handler.next(options);
        return;
      }

      log('Rechecking for Internet connection in ${retryDelay.inSeconds} seconds...');
      await Future.delayed(retryDelay);
    }

    UiHelpers.showSnackBar(
        'It seems like you\'re currently offline. Please check your Internet connection and try again later.',
        mode: SnackBarMode.error);

    handler.reject(DioException(requestOptions: options));
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    void handleError() {
      handler.reject(DioException(requestOptions: response.requestOptions));
    }

    if (response.statusCode! == 200) {
      handler.next(response);
      return;
    }

    if (response.statusCode! < 500) {
      handleError();
      return;
    }

    Response res = response;

    final retryDio = CustomDio.instance.retryDio;

    const int maxRetryCount = 3;
    const List<Duration> retryDelays = [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 3),
    ];

    for (int i = 0; i < maxRetryCount; i++) {
      final delay = retryDelays[i];
      log('Retrying request "${res.requestOptions.path}" in ${delay.inSeconds} second(s)...');
      await Future.delayed(delay);

      res = await retryDio.request(
        res.requestOptions.path,
        data: res.requestOptions.data,
        cancelToken: res.requestOptions.cancelToken,
        onReceiveProgress: res.requestOptions.onReceiveProgress,
        onSendProgress: res.requestOptions.onSendProgress,
        queryParameters: res.requestOptions.queryParameters,
        options: Options(
          sendTimeout: res.requestOptions.sendTimeout,
          receiveTimeout: res.requestOptions.receiveTimeout,
          contentType: res.requestOptions.contentType,
          extra: res.requestOptions.extra,
          followRedirects: res.requestOptions.followRedirects,
          headers: res.requestOptions.headers,
          listFormat: res.requestOptions.listFormat,
          maxRedirects: res.requestOptions.maxRedirects,
          method: res.requestOptions.method,
          persistentConnection: res.requestOptions.persistentConnection,
          receiveDataWhenStatusError:
              res.requestOptions.receiveDataWhenStatusError,
          requestEncoder: res.requestOptions.requestEncoder,
          responseDecoder: res.requestOptions.responseDecoder,
          responseType: res.requestOptions.responseType,
          validateStatus: res.requestOptions.validateStatus,
          preserveHeaderCase: res.requestOptions.preserveHeaderCase,
        ),
      );

      if (res.statusCode! == 200) {
        handler.next(res);
        return;
      }
      if (res.statusCode! < 500) {
        handleError();
        return;
      }
    }

    handleError();
  }

  @override
  void onError(DioException exception, ErrorInterceptorHandler handler) {
    if (exception.message != null) {
      UiHelpers.showSnackBar(exception.message!, mode: SnackBarMode.error);
    }
    handler.reject(exception);
  }
}
