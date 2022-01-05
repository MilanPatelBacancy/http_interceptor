/// Enum representation of all available HTTP methods.
enum Method {
  HEAD,
  GET,
  POST,
  PUT,
  PATCH,
  DELETE,
}

/// Extends [Method] to be initialized from a [String] value.
extension StringToMethod on Method {
  /// Parses an string into a Method Enum value.
  static Method fromString(String method) {
    switch (method) {
      case "HEAD":
        return Method.HEAD;
      case "GET":
        return Method.GET;
      case "POST":
        return Method.POST;
      case "PUT":
        return Method.PUT;
      case "PATCH":
        return Method.PATCH;
      case "DELETE":
        return Method.DELETE;
    }
    throw ArgumentError.value(method, "method", "Must be a valid HTTP Method.");
  }
}

/// Extends [Method] to provide a [String] representation.
extension MethodToString on Method {
  // Parses a Method Enum value into a string.
  String get asString {
    switch (this) {
      case Method.HEAD:
        return "HEAD";
      case Method.GET:
        return "GET";
      case Method.POST:
        return "POST";
      case Method.PUT:
        return "PUT";
      case Method.PATCH:
        return "PATCH";
      case Method.DELETE:
        return "DELETE";
    }
  }
}
  Method methodFromString(String method) {
    switch (method) {
      case "HEAD":
        return Method.HEAD;
      case "GET":
        return Method.GET;
      case "POST":
        return Method.POST;
      case "PUT":
        return Method.PUT;
      case "PATCH":
        return Method.PATCH;
      case "DELETE":
        return Method.DELETE;
    }
    throw ArgumentError.value(method, "method", "Must be a valid HTTP Method.");
  }

  String methodToString(Method method) {
    switch (method) {
      case Method.HEAD:
        return "HEAD";
      case Method.GET:
        return "GET";
      case Method.POST:
        return "POST";
      case Method.PUT:
        return "PUT";
      case Method.PATCH:
        return "PATCH";
      case Method.DELETE:
        return "DELETE";
      default:
        return method.toString();
    }
}
