import 'package:flutter_application_1/screens/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/generic.dart';

//HESAP OLUSTURMA ISLEMINI YAPAR
Future<Map<String, dynamic>?> createAccountInterceptor(
    String email, String password, String repass, BuildContext context) async {
  const String apiUrl = 'http://192.168.0.155:5008/api/Auth/CreateUser';

  Map<String, dynamic> requestBody = {
    'username': email,
    'password': password,
    'passwordConfirm': repass,
  };

  http.Response response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Content-Type': 'application/json',
    },
    body: jsonEncode(requestBody),
  );

  Map<String, dynamic> responseData = jsonDecode(response.body);
  print(
      '++++++++++++++++++++++++++API RESPONSE DATA OF CREATE ACCOUNT++++++++++++++++++++++++++');
  print(responseData);

  if (response.statusCode == 200) {
    Map<String, dynamic> apiResponse = responseData['apiResponse'];
    String successMessage = apiResponse.containsKey('message')
        ? apiResponse['message']
        : 'Hesap oluşturma işlemi başarılı.';
    showMessagePositive(context, [successMessage], 'Kullanıcı oluşturuldu');

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
      );
    });

    return apiResponse;
  } else {
    if (responseData.containsKey('apiResponse')) {
      Map<String, dynamic> apiResponse = responseData['apiResponse'];
      List<String> errorMessages = [];
      if (apiResponse.containsKey('messages')) {
        List<dynamic>? messages = apiResponse['messages'];
        if (messages != null) {
          for (var message in messages) {
            if (message != null && message.containsKey('message')) {
              errorMessages.add(message['message']);
            }
          }
        }
      }

      if (errorMessages.isEmpty) {
        errorMessages.add('Bir hata oluştu.');
      }

      showMessageNegative(context, errorMessages, 'Hata');
      return responseData;
    } else {
      List<String> errorMessages = [];
      if (responseData.containsKey('messages')) {
        List<dynamic> errors = responseData['messages'];
        for (var error in errors) {
          if (error.containsKey('message')) {
            errorMessages.add(error['message']);
          }
        }
      }

      if (errorMessages.isEmpty) {
        errorMessages.add('Bir hata oluştu.');
      }

      showMessageNegative(context, errorMessages, 'Hata');
      print(responseData);

      return responseData;
    }
  }
}
