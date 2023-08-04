import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

void updateValue(String nameOfValue, String newValue) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString(nameOfValue, newValue);
}

void clearSharedPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isSwitchOn = prefs.getBool('isSwitchOn') ?? false;

  SharedPreferences prefs_Clear = await SharedPreferences.getInstance();
  await prefs_Clear.clear();

  SharedPreferences prefs_Save = await SharedPreferences.getInstance();
  prefs_Save.setBool('isSwitchOn', isSwitchOn);
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

String extractNameFromUsername(String username) {
  List<String> parts = username.split('@')[0].split('.');
  if (parts.length == 2) {
    String firstName = capitalize(parts[0]);
    String lastName = capitalize(parts[1]);
    return '$firstName $lastName';
  }
  return username;
}

String capitalize(String word) {
  if (word.isEmpty) {
    return '';
  }
  return word[0].toUpperCase() + word.substring(1);
}

void openCard(BuildContext context, String title) {
  final RenderBox button = context.findRenderObject() as RenderBox;
  final RenderBox overlay =
      Overlay.of(context).context.findRenderObject() as RenderBox;
  final RelativeRect position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(button.size.topRight(Offset.zero),
          ancestor: overlay),
      button.localToGlobal(button.size.topRight(Offset.zero),
          ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );

  showMenu(
    color: Colors.blueGrey[50],
    context: context,
    position: const RelativeRect.fromLTRB(50, 80, 30, 50),
    items: [
      PopupMenuItem(
        child: Row(
          children: [
            const SizedBox(
              height: 10,
            ),
            Card(
              elevation: 1,
              color: Colors.blueGrey[50],
              child: Text(
                ' $title',
                style: const TextStyle(fontSize: 18, color: Colors.indigo),
              ),
            ),
          ],
        ),
      ),
    ],
  );
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

Future<void> saveUserInfo(
    String apiToken, String refreshToken, String userName, String email) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('apiToken', apiToken);
  await prefs.setString('refreshToken', refreshToken);
  await prefs.setString('userName', userName);
  await prefs.setString('userEmail', email);
  print('API Token, Refresh Token, and User Info saved to shared preferences.');
}

void showMessageNegative(
    BuildContext context, List<String> errorMessages, String type) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
            for (var message in errorMessages)
              Text(
                message,
                style: TextStyle(fontSize: 17),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      );
    },
  );
}

void showMessagePositive(
    BuildContext context, List<String> errorMessages, String type) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check,
              size: 60,
              color: Colors.indigo,
            ),
            const SizedBox(height: 30),
            for (var message in errorMessages)
              Text(message, style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    },
  );
}

void showFadeawayMessage(BuildContext context, String message) {
  final overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 10,
      left: 0,
      right: 0,
      child: FadeawayMessage(message: message),
    ),
  );

  Overlay.of(context)?.insert(overlayEntry);
}

class FadeawayMessage extends StatefulWidget {
  final String message;

  const FadeawayMessage({required this.message});

  @override
  _FadeawayMessageState createState() => _FadeawayMessageState();
}

class _FadeawayMessageState extends State<FadeawayMessage> {
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _startFadeOutTimer();
  }

  void _startFadeOutTimer() async {
    await Future.delayed(Duration(seconds: 2));
    setState(() {
      _visible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: Duration(milliseconds: 1000),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.indigo,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          widget.message,
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

Future<dynamic> showInputSQL(BuildContext context) async {
  TextEditingController textEditingController = TextEditingController();
  String query = '';

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.table_view_outlined,
              size: 60,
              color: Colors.indigo,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                hintText: "SQL sorgunuz:",
              ),
              onChanged: (value) {
                query = value;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setString('query', query);

              Navigator.pop(context, query);
            },
            child: Text(
              "OK",
              style: TextStyle(fontSize: 17),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context, null);
            },
            child: Text(
              "iptal",
              style: TextStyle(fontSize: 17),
            ),
          ),
        ],
      );
    },
  );
}

void deleteSingleValueFromShared(String key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove(key);
}
