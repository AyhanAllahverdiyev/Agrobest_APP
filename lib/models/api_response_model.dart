import 'dart:convert';

class LoginApiResponse {
  ApiResponseData? apiResponse;

  LoginApiResponse({
    this.apiResponse,
  });

  factory LoginApiResponse.fromJson(Map<String, dynamic> json) {
    return LoginApiResponse(
      apiResponse: ApiResponseData.fromJson(json['apiResponse']),
    );
  }
}

class ApiResponse {
  bool succeeded;
  List<Message> messages;

  ApiResponse({
    required this.succeeded,
    required this.messages,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      succeeded: json['succeeded'],
      messages:
          List<Message>.from(json['messages'].map((x) => Message.fromJson(x))),
    );
  }
}

class ApiResponseData {
  String? userName;
  String? accessToken;
  String? refreshToken;

  ApiResponseData({
    this.userName,
    this.accessToken,
    this.refreshToken,
  });

  factory ApiResponseData.fromJson(Map<String, dynamic> json) {
    return ApiResponseData(
      userName: json['userName'] as String?,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
    );
  }
}

class Message {
  String? messageType;
  String? message;
  MessageData? data;

  Message({
    this.messageType,
    this.message,
    this.data,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageType: json['messageType'] as String?,
      message: json['message'] as String?,
      data: json['data'] != null ? MessageData.fromJson(json['data']) : null,
    );
  }
}

class MessageData {
  MessageData();

  factory MessageData.fromJson(Map<String, dynamic> json) {
    return MessageData();
  }
}
