import 'package:flutter_application_1/screens/logged.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/utils/generic.dart';

Future<Map<String, dynamic>> loginInterceptor(
    String email, String password, BuildContext context) async {
  SharedPreferences prefs_Clear = await SharedPreferences.getInstance();
  await prefs_Clear.clear();
  const String apiUrl = 'http://192.168.0.155:5008/api/Auth/Login';

  Map<String, dynamic> requestBody = {
    'username': email,
    'password': password,
  };

  http.Response response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestBody),
  );

  Map<String, dynamic> responseData = jsonDecode(response.body);

  if (responseData.containsKey('apiResponse')) {
    Map<String, dynamic> apiResponse = responseData['apiResponse'];
    if (response.statusCode == 200) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoggedPage(),
        ),
      );
    } else {
      List<String> errorMessages = [];
      if (apiResponse.containsKey('messages')) {
        List<dynamic> messages = apiResponse['messages'];
        for (var message in messages) {
          if (message.containsKey('message')) {
            errorMessages.add(message['message']);
          }
        }
      }
      showMessageNegative(context, errorMessages, 'Hata');
      return responseData;
    }
  } else {
    List<String> errorMessages = [];
    if (responseData.containsKey('messages')) {
      List<dynamic> messages = responseData['messages'];
      for (var message in messages) {
        if (message.containsKey('message')) {
          errorMessages.add(message['message']);
        }
      }
    }
    showMessageNegative(context, errorMessages, 'Hata');

    return responseData['apiResponse']['data'];
  }
  return responseData['apiResponse']['data'];
}
