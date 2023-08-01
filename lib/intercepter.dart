import 'package:flutter_application_1/logged.dart';
import 'package:flutter_application_1/main.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'generic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'logout.dart';
import 'models/api_response_model.dart';

Future<Map<String, dynamic>> loginInterceptor(
    String email, String password, BuildContext context) async {
  SharedPreferences prefs_Clear = await SharedPreferences.getInstance();
  await prefs_Clear.clear();
  const String apiUrl = 'http://192.168.0.155:5008/api/auth/login';

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
  LoginApiResponse loginApiResponse = LoginApiResponse.fromJson(responseData);

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

//sharedpereference da olan herseyi ekrana basar
void printAllShared() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    print(
        "++++++++++++++++++++++++++ EVERYTHING INSIDE SHARED_PREFERENCES BEFORE CLEAR+++++++++++++++++++++++");

    for (var key in allKeys) {
      final value = prefs.get(key);
      print('$key: $value');
    }
    print(
        "++++++++++++++++++++++++++ EVERYTHING INSIDE SHARED_PREFERENCES BEFORE CLEAR+++++++++++++++++++++++");
  } catch (e) {
    print('Error reading SharedPreferences: $e');
  }
}

Future<bool> askLocationPermission(BuildContext context) async {
  PermissionStatus status = await Permission.location.request();
  var count = 0;
  while (!status.isGranted) {
    if (status.isGranted) {
      return true;
    } else {
      await Future.delayed(Duration(seconds: 3));
      showMessageNegative(
        context,
        ['Devam etmek için lütfen konum erişim izni veriniz'],
        "Uyarı",
      );
      count++;
      if (count == 2) {
        showMessageNegative(
            context,
            [
              'Lütfen mobil cihazınızın ayarlar kısmından  konum erişimine izin verdikten sonra tekrar deneyin. Iyi günler!'
            ],
            "HATA");
        await Future.delayed(Duration(seconds: 3));
        exitApp();
      }
    }
  }
  return true;
}

Future<void> getUserLocation() async {
  try {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    var latitude = position.latitude.toString();
    var longitude = position.longitude.toString();
    print('LOCATION:');
    print(longitude);
    print(latitude);
  } catch (e) {
    print("error getUserLocation() : $e");
  }
}

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

UrlLauncher(String link) async {
  final Uri url = Uri.parse(link);
  if (!await launchUrl(url)) {
    throw Exception('Could not launch $url');
  }
  print('LAUNCHED');
}

void exitApp() {
  exit(0);
}

Future<void> refresfTokens(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final username = await getUsername();
  final refreshToken = await getRefreshToken();

  Map<String, dynamic> requestBody = {
    'refreshToken': refreshToken,
    'userName': username,
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

void updateValue(String nameOfValue, String newValue) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(nameOfValue, newValue);
}

void clearSharedPrefs() async {
  SharedPreferences prefs_Clear = await SharedPreferences.getInstance();
  await prefs_Clear.clear();
}
