import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/logoutService.dart';
import 'package:flutter_application_1/screens/main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_application_1/screens/sideMenu.dart';
import 'package:flutter_application_1/utils/generic.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.blue,
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  primarySwatch: Colors.blue,
);

class LoggedPage extends StatefulWidget {
  const LoggedPage({Key? key}) : super(key: key);

  @override
  State<LoggedPage> createState() => LoggedPageState();
}

class LoggedPageState extends State<LoggedPage> {
  late bool isSwitchOn;
  late bool _listSwitch = false;

  void saveLightModeToShared() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isSwitchOn', isSwitchOn);
  }

  void getLightMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isSwitchOn = prefs.getBool('isSwitchOn') ?? false;
  }

  String? apiToken;
  String? refreshToken;
  String? userName;
  String? userEmail;

  List<Widget> appButtons = [];

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();

  bool _isSearchExpanded = false;

  late ThemeData _currentTheme;

  LoggedPageState() {
    isSwitchOn = false;
    _currentTheme = isSwitchOn ? darkTheme : lightTheme;
  }

  @override
  void initState() {
    super.initState();
    getLightMode();
    loadUserInfo();
    getApps();
  }

  void loadUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiToken = prefs.getString('apiToken');
      userName = prefs.getString('userName');
      userEmail = prefs.getString('userEmail');
    });
  }

  void toggleThemeMode() {
    setState(() {
      isSwitchOn = !isSwitchOn;
      saveLightModeToShared();
      getApps();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: isSwitchOn ? darkTheme : lightTheme,
      home: GestureDetector(
        onTap: () {
          if (_searchController.text.isNotEmpty) {
            _searchController.clear();
          }
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          key: scaffoldKey,
          drawer: const NavDrawer(),
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 68, 54, 97),
            leading: Builder(
              builder: (context) => IconButton(
                onPressed: () {
                  scaffoldKey.currentState?.openDrawer();
                },
                icon: const Icon(Icons.menu),
                color: Colors.white,
              ),
            ),
            actions: [
              SizedBox(width: 40),
              IconButton(
                onPressed: () {
                  setState(() {
                    toggleThemeMode();
                  });
                },
                icon: Icon(
                  isSwitchOn ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => openCard(context, 'Mail'),
                icon: const Icon(Icons.mail_outline),
                color: Colors.white,
              ),
              Builder(
                builder: (context) => IconButton(
                  onPressed: () => openCard(context, 'Bildirimler'),
                  icon: const Icon(
                    Icons.notifications_active_outlined,
                    color: Colors.white,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _listSwitch = !_listSwitch;
                    getApps();
                  });
                },
                icon: Icon(
                  _listSwitch ? Icons.list_alt_outlined : Icons.apps_outlined,
                  color: Colors.white,
                ),
              ),
              IconButton(
                onPressed: () => openProfilePreview(context),
                icon: Image.asset(
                  'assets/gigity.png',
                  width: 30,
                  height: 30,
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                const Center(
                  child: Text(
                    'Hoşgeldin',
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                Text(
                  extractNameFromUsername(userName ?? 'N/A'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                if (isSwitchOn)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: appButtons.length,
                    itemBuilder: (context, index) => appButtons[index],
                  )
                else
                  ...appButtons,
              ],
            ),
          ),
        ),
      ),
    );
  }

//Api'ye istek atarak uygulamalari alan fonksiyon
  void getApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String apiUrl = 'http://192.168.0.155:5008/api/AppList/GetAppListFromToken';

    String? username = prefs.getString('userName');
    final body = jsonEncode({"username": username});

    var header = {
      'Content-Type': 'application/json',
      "Authorization": "Bearer $apiToken"
    };
    var response = await http.post(
      Uri.parse(apiUrl),
      headers: header,
      body: body,
    );

    if (response.statusCode == 200) {
      List<dynamic> appList = jsonDecode(response.body)["apiResponse"]["data"];

      List<String> iconUrls = [];
      List<String> names = [];
      List<String> images = [];
      List<String> urls = [];
      for (var appData in appList) {
        String title = appData["name"];
        String imageUrl = appData["imageUrl"];
        String iconUrl = appData["iconUrl"];
        String name = appData['name'];
        String image = appData['imageUrl'];
        String url = appData['url'];

        iconUrls.add(iconUrl);
        names.add(name);
        images.add(image);
        urls.add(url);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setStringList('iconUrls', iconUrls);
        prefs.setStringList('names', names);
        prefs.setStringList('images', images);
        prefs.setStringList('urls', urls);
      }

      setState(() {
        appButtons.clear();
        for (var appData in appList) {
          String title = appData["name"];
          String imageUrl = appData["imageUrl"];
          String iconUrl = appData["iconUrl"];
          String url = appData["url"];
          if (_listSwitch) {
            Widget button =
                buildButtonList(context, title, imageUrl, iconUrl, url);
            appButtons.add(button);
          } else {
            Widget button = buildButton(context, title, imageUrl, iconUrl, url);
            appButtons.add(button);
          }
        }
      });
    }
    //  else if (response.statusCode == 400) {
    //   getAccessToken();
    //   getApps();
    // }
    else {
      print(header);
    }
  }

//apiden gelen uygulama bilgilerine gore ekranda uygulamalarin butonunu yaratan fonksiyon
  Widget buildButton(BuildContext context, String title, String imagePath,
      String iconPath, String url) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: SizedBox(
          width: 300,
          height: 200,
          child: ElevatedButton(
            onPressed: () {
              UrlLauncher(url);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[400],
              elevation: 20,
            ),
            child: Image.network(
              imagePath,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) {
                  return child;
                } else {
                  return const CircularProgressIndicator();
                }
              },
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.error);
              },
            ),
          ),
        ),
      ),
    );
  }

//apiden gelen uygulama bilgilerine gore ekranda list  sekilde uygulamalarin butonunu yaratan fonksiyon

  Widget buildButtonList(BuildContext context, String title, String imagePath,
      String iconPath, String url) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        width: 400,
        height: 70,
        child: TextButton(
          onPressed: () {
            UrlLauncher(url);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[400],
            elevation: 20,
          ),
          child: Row(
            children: [
              Image.network(
                imagePath,
                alignment: Alignment.centerLeft,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return const CircularProgressIndicator();
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
                height: 70,
                width: 70,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }

//sol ustte yerlesen fotografa tiklaninca profil ekranini acan fonksiyon
  void openProfilePreview(BuildContext context) {
    if (isSwitchOn == false) {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.transparent,
                    backgroundImage: const AssetImage('assets/gigity.png'),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 68, 54, 97),
                          width: 5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    extractNameFromUsername(userName ?? 'N/A'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    color: const Color.fromARGB(255, 243, 242, 242),
                    child: Text(
                      '$userEmail',
                      style: const TextStyle(
                          fontSize: 20, color: Color.fromARGB(255, 48, 48, 54)),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.grey.shade700,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Container(
              padding: const EdgeInsets.all(5),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: Colors.transparent,
                    backgroundImage: const AssetImage('assets/gigity.png'),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color.fromARGB(255, 68, 54, 97),
                          width: 5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    extractNameFromUsername(userName ?? 'N/A'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    //  color: Colors.white,
                    child: Text(
                      '$userEmail',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}
