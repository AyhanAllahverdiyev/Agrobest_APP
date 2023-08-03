import 'package:flutter_application_1/screens/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/services/logoutService.dart';
import 'package:flutter_application_1/utils/generic.dart';

Future<void> refresfTokens(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  print('=======================================');
  final username = await getUsername();
  final refreshToken = await getRefreshToken();
  print(username);
  print(refreshToken);
  Map<String, dynamic> requestBody = {
    'refreshToken': refreshToken,
    'username': username,
  };

  http.Response response = await http.post(
    Uri.parse("http://192.168.0.155:5008/api/Auth/RefreshTokenLogin"),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestBody),
  );
  print('=======================================');
  print(response.body);
  print(response.statusCode);
  if (response.statusCode == 200) {
    Map<String, dynamic> responseData = jsonDecode(response.body);
    Map<String, dynamic> apiResponse = responseData['apiResponse'];

    updateValue('refreshToken', apiResponse['data']['refreshToken']);
    updateValue('apiToken', apiResponse['data']['accessToken']);
    printAllShared();
    print('Refresh token yenilendi ');
  } else if (response.statusCode == 400) {
    print('Her iki tokenin süresi bitmiş');
    showFadeawayMessage(
        context, 'Uzun süre haraketsiz kalındığı için otomatik çıkış yapıldı');
    clearSharedPrefs();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }
}
