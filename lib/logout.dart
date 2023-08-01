import 'dart:convert';
import 'package:flutter/material.dart';
import 'intercepter.dart';
import 'package:flutter_application_1/logged.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'generic.dart';

const baseUrl = "http://localhost:5008/api/Auth/Logout";

Future<void> refreshToken() async {
  try {
    final refreshToken = await getRefreshToken();

    final response = await http.post(
      Uri.parse(baseUrl + "auth/refreshtokenLogin"),
      body: {
        "refreshToken": refreshToken,
        "username": await getUsername(),
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final accessToken = data["accessToken"];
      await saveAccessToken(accessToken);
    } else {
      print("Token Refresh Failed: ${response.statusCode}");
    }
  } catch (e) {
    print("Token Refresh Error: $e");
  }
}

Future<void> saveAccessToken(String accessToken) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("apiToken", accessToken);
}

Future<void> saveRefreshToken(String refreshToken) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString("refreshToken", refreshToken);
}

Future<String> getAccessToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("apiToken") ?? "";
}

Future<String> getRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("refreshToken") ?? "";
}

Future<String> getUsername() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString("userName") ?? "";
}

Future<bool> isAuthenticated() async {
  final accessToken = await getAccessToken();
  return accessToken.isNotEmpty;
}

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final username = await getUsername();
  final accessToken = await getAccessToken();
  final refreshToken = await getRefreshToken();

  try {
    Map<String, dynamic> requestBody = {
      'userName': username,
      'token': accessToken,
    };

    http.Response response = await http.post(
      Uri.parse("http://192.168.0.155:5008/api/Auth/Logout"),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    print(response.body);
    print(response.statusCode);
    Map<String, dynamic> responseData = jsonDecode(response.body);
    //Map<String, dynamic> apiResponse = responseData['apiResponse'];
    String message = responseData['apiResponse']['message'];
    print('messagemessagemessagemessagemessage');
    print(message);
    showFadeawayMessage(context, message);
  } catch (e) {
    print('Error while logging out: $e');
  }
  printAllShared();
  SharedPreferences prefs_Clear = await SharedPreferences.getInstance();
  await prefs_Clear.clear();
}
