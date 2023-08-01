import 'package:flutter/material.dart';
import 'package:flutter_application_1/logout.dart';
import 'package:flutter_application_1/main.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'sidemenu.dart';
import 'intercepter.dart';

class LoggedPage extends StatefulWidget {
  const LoggedPage({Key? key}) : super(key: key);

  @override
  State<LoggedPage> createState() => LoggedPageState();
}

class LoggedPageState extends State<LoggedPage> {
  bool _isSwitchOn = false;
  String? apiToken;
  String? refreshToken;
  String? userName;
  String? userEmail;

  List<Widget> appButtons = [];

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
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

  void printUserInfo() {
    print('API Token from shared preferences: $apiToken');
    print('User Name from shared preferences: $userName');
    print('User Email from shared preferences: $userEmail');
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            SizedBox(width: 80),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: TextField(
                  autofocus: false,
                  controller: _searchController,
                  onChanged: (value) {
                    print('SEARCH SEARCH SEARCH SEARCH SEARCH SEARCH');
                    print(value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Ara...',
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: 30)),
                    suffixIcon: IconButton(
                      onPressed: () {
                        _searchController.clear();
                        print('SEARCH SEARCH SEARCH SEARCH SEARCH SEARCH');
                        print('');
                        FocusScope.of(context).unfocus();
                      },
                      icon: Icon(Icons.clear),
                    ),
                  ),
                ),
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
                  _isSwitchOn = !_isSwitchOn;
                  getApps();
                });
              },
              icon: Icon(
                _isSwitchOn ? Icons.list_alt_outlined : Icons.apps_outlined,
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
              if (_isSwitchOn)
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
    );
  }

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
          if (_isSwitchOn) {
            Widget button =
                buildButtonList(context, title, imageUrl, iconUrl, url);
            appButtons.add(button);
          } else {
            Widget button = buildButton(context, title, imageUrl, iconUrl, url);
            appButtons.add(button);
          }
        }
      });
    } else {
      print(header);
    }
  }

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

  void openProfilePreview(BuildContext context) {
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
                    fontSize: 10,
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
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          logout(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.exit_to_app,
                          color: Colors.black,
                        ),
                        label: const Text(
                          "Çıkış yap",
                          style: TextStyle(fontSize: 15, color: Colors.black),
                        ),
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.grey[200]),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
