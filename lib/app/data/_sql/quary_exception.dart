final class QuaryException implements Exception {
  const QuaryException({
    required this.message,
  });
  final String message;

  @override
  String toString() => 'QuaryException \nmessage: $message';
}

final class ResponseException implements Exception {
  ResponseException({
    required this.message,
    required this.error,
  });

  ResponseException.server():
        message= 'server error',
        error= ErrorType.serverError ;

  final String message;
  final ErrorType error;

  @override
  String toString() => 'ResponseException \nmessage: $message';

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'error': error.text,
    };
  }
}

enum ErrorType {
  unAuthenticated(401, 'authentication failed'),
  serverError(500, 'internal server error'),
  badRequest(400, 'invalid input');

  const ErrorType(this.code, this.text);
  final int code;
  final String text;
}
