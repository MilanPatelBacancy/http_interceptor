import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart';
import 'package:http_interceptor/extensions/extensions.dart';
import 'package:http_interceptor/http/http_methods.dart';
import 'package:http_interceptor/models/models.dart';
import 'package:http_interceptor/models/request_data.dart';
import 'interceptor_contract.dart';

/// Class to be used by the user to set up a new `http.Client` with interceptor
/// support.
///
/// Call `build()` and pass list of interceptors as parameter.
///
/// Example:
/// ```dart
///  InterceptedClient client = InterceptedClient.build(interceptors: [
///      LoggingInterceptor(),
///  ]);
/// ```
///
/// Then call the functions you want to, on the created `client` object.
/// ```dart
///  client.get(...);
///  client.post(...);
///  client.put(...);
///  client.delete(...);
///  client.head(...);
///  client.patch(...);
///  client.read(...);
///  client.send(...);
///  client.readBytes(...);
///  client.close();
/// ```
///
/// Don't forget to close the client once you are done, as a client keeps
/// the connection alive with the server by default.
class InterceptedClient extends BaseClient {
  /// List of interceptors that will be applied to the requests and responses.
  final List<InterceptorContract> interceptors;

  /// Maximum duration of a request.
  final Duration? requestTimeout;

  /// A policy that defines whether a request or response should trigger a
  /// retry. This is useful for implementing JWT token expiration
  final RetryPolicy? retryPolicy;

  int _retryCount = 0;
  late Client _inner;

  InterceptedClient._internal({
    required this.interceptors,
    this.requestTimeout,
    this.retryPolicy,
    Client? client,
  }) : _inner = client ?? Client();

  /// Builds a new [InterceptedClient] instance.
  ///
  /// Interceptors are applied in a linear order. For example a list that looks
  /// like this:
  ///
  /// ```dart
  /// InterceptedClient.build(
  ///   interceptors: [
  ///     WeatherApiInterceptor(),
  ///     LoggerInterceptor(),
  ///   ],
  /// ),
  /// ```
  ///
  /// Will apply first the `WeatherApiInterceptor` interceptor, so when
  /// `LoggerInterceptor` receives the request/response it has already been
  /// intercepted.
  factory InterceptedClient.build({
    required List<InterceptorContract> interceptors,
    Duration? requestTimeout,
    RetryPolicy? retryPolicy,
    Client? client,
  }) =>
      InterceptedClient._internal(
        interceptors: interceptors,
        requestTimeout: requestTimeout,
        retryPolicy: retryPolicy,
        client: client,
      );

  @override
  Future<Response> head(
    Uri url, {
    Map<String, String>? headers,
  }) async =>
      (await _sendUnstreamed(
        method: Method.HEAD,
        url: url,
        headers: headers,
      )) as Response;

  Future<Response> get(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) async =>
      (await _sendUnstreamed(
        method: Method.GET,
        url: url,
        headers: headers,
        params: params,
      )) as Response;

  @override
  Future<Response> post(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async =>
      (await _sendUnstreamed(
        method: Method.POST,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      )) as Response;

  @override
  Future<Response> put(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async =>
      (await _sendUnstreamed(
        method: Method.PUT,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      )) as Response;

  @override
  Future<Response> patch(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async =>
      (await _sendUnstreamed(
        method: Method.PATCH,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      )) as Response;

  @override
  Future<Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async =>
      (await _sendUnstreamed(
        method: Method.DELETE,
        url: url,
        headers: headers,
        params: params,
        body: body,
        encoding: encoding,
      )) as Response;

  @override
  Future<String> read(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) {
    return get(url, headers: headers, params: params).then((response) {
      _checkResponseSuccess(url, response);
      return response.body;
    });
  }

  @override
  Future<Uint8List> readBytes(
    Uri url, {
    Map<String, String>? headers,
    Map<String, dynamic>? params,
  }) {
    return get(url, headers: headers, params: params).then((response) {
      _checkResponseSuccess(url, response);
      return response.bodyBytes;
    });
  }

  // TODO: Implement interception from `send` method.
  Future<StreamedResponse> send(BaseRequest request) {
    return _inner.send(request);
  }


  Future<BaseResponse> _sendUnstreamed({
    required Method method,
    required Uri url,
    Map<String, String>? headers,
    Map<String, dynamic>? params,
    Object? body,
    Encoding? encoding,
  }) async {
    url = url.addParameters(params);

    Request request = new Request(method.toString(), url);
    if (headers != null) request.headers.addAll(headers);
    if (encoding != null) request.encoding = encoding;
    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List) {
        request.bodyBytes = body.cast<int>();
      } else if (body is Map) {
        request.bodyFields = body.cast<String, String>();
      } else {
        throw new ArgumentError('Invalid request body "$body".');
      }
    }

    var response = await _attemptRequest(request);

    // Intercept response
    response = await _interceptResponse(response);

    return response;
  }

  void _checkResponseSuccess(Uri url, Response response) {
    if (response.statusCode < 400) return;
    var message = "Request to $url failed with status ${response.statusCode}";
    if (response.reasonPhrase != null) {
      message = "$message: ${response.reasonPhrase}";
    }
    throw new ClientException("$message.", url);
  }

  /// Attempts to perform the request and intercept the data
  /// of the response
  Future<Response> _attemptRequest(Request request) async {
    var response;
    try {
      // Intercept request
      final interceptedRequest = await _interceptRequest(request);

      var stream = requestTimeout == null
          ? await _inner.send(interceptedRequest)
          : await _inner.send(interceptedRequest).timeout(requestTimeout!);

      response = await Response.fromStream(stream);
      if (retryPolicy != null &&
          retryPolicy!.maxRetryAttempts > _retryCount &&
          await retryPolicy!.shouldAttemptRetryOnResponse(response)) {
        _retryCount += 1;
        return _attemptRequest(request);
      }
    } on Exception catch (error) {
      if (retryPolicy != null &&
          retryPolicy!.maxRetryAttempts > _retryCount &&
          retryPolicy!.shouldAttemptRetryOnException(error)) {
        _retryCount += 1;
        return _attemptRequest(request);
      } else {
        rethrow;
      }
    }

    _retryCount = 0;
    return response;
  }

  /// This internal function intercepts the request.
  Future<Request> _interceptRequest(Request request) async {
    for (InterceptorContract interceptor in interceptors) {
      RequestData interceptedData = await interceptor.interceptRequest(
        data: RequestData.fromHttpRequest(request),
      );
      request = interceptedData.toHttpRequest();
    }

    return request;
  }

  /// This internal function intercepts the response.
  Future<Response> _interceptResponse(Response response) async {
    for (InterceptorContract interceptor in interceptors) {
      ResponseData responseData = await interceptor.interceptResponse(
        data: ResponseData.fromHttpResponse(response),
      );
      response = responseData.toHttpResponse();
    }

    return response;
  }

  void close() {
    _inner.close();
  }
}
