import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/generic.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const baseUrl = "http://192.168.0.155:5008/api/Auth/Logout";

Future<void> logout(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final username = await getUsername();
  final accessToken = await getAccessToken();

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

  Map<String, dynamic> responseData = jsonDecode(response.body);
  //Map<String, dynamic> apiResponse = responseData['apiResponse'];
  String message = responseData['apiResponse']['messages'][0]['message'];

  showFadeawayMessage(context, message);

  printAllShared();
  clearSharedPrefs();
  print('LIGHTLIGHTLIGHTLIGHTLIGHTLIGHTLIGHT');

  print(prefs.getBool('isSwitchOn'));
}
