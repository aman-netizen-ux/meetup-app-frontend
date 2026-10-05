class ApiError implements Exception {
  const ApiError({required this.code, required this.message, this.statusCode});

  final String code;
  final String message;
  final int? statusCode;

  factory ApiError.fromJson(Map<String, dynamic> json, {int? statusCode}) {
    final error = json['error'] as Map<String, dynamic>;
    return ApiError(
      code: error['code'] as String,
      message: error['message'] as String,
      statusCode: statusCode,
    );
  }

  @override
  String toString() => '$code: $message';
}
