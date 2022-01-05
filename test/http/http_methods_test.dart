import 'package:http_interceptor/http/http_methods.dart';
import 'package:test/test.dart';

main() {
  group("Can parse from string", () {
    test("with HEAD method", () {
      // Arrange
      Method method;
      String methodString = "HEAD";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(Method.HEAD));
    });
    test("with GET method", () {
      // Arrange
      Method method;
      String methodString = "GET";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(Method.GET));
    });
    test("with POST method", () {
      // Arrange
      Method method;
      String methodString = "POST";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(Method.POST));
    });
    test("with PUT method", () {
      // Arrange
      Method method;
      String methodString = "PUT";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(Method.PUT));
    });
    test("with PATCH method", () {
      // Arrange
      Method method;
      String methodString = "PATCH";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(Method.PATCH));
    });
    test("with DELETE method", () {
      // Arrange
      Method method;
      String methodString = "DELETE";

      // Act
      method = StringToMethod.fromString(methodString);

      // Assert
      expect(method, equals(Method.DELETE));
    });
  });

  group("Can parse to string", () {
    test("to 'HEAD' string.", () {
      // Arrange
      String methodString;
      Method method = Method.HEAD;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("HEAD"));
    });
    test("to 'GET' string.", () {
      // Arrange
      String methodString;
      Method method = Method.GET;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("GET"));
    });
    test("to 'POST' string.", () {
      // Arrange
      String methodString;
      Method method = Method.POST;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("POST"));
    });
    test("to 'PUT' string.", () {
      // Arrange
      String methodString;
      Method method = Method.PUT;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("PUT"));
    });
    test("to 'PATCH' string.", () {
      // Arrange
      String methodString;
      Method method = Method.PATCH;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("PATCH"));
    });
    test("to 'DELETE' string.", () {
      // Arrange
      String methodString;
      Method method = Method.DELETE;

      // Act
      methodString = method.asString;

      // Assert
      expect(methodString, equals("DELETE"));
    });
  });

  group("Can control unsupported values", () {
    test("Throws when string is unsupported", () {
      // Arrange
      String methodString = "UNSUPPORTED";

      // Act
      // Assert
      expect(
          () => StringToMethod.fromString(methodString), throwsArgumentError);
    });
  });
}
