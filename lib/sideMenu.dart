import 'package:flutter/material.dart';
import 'intercepter.dart';
import 'package:flutter_application_1/logout.dart';
import 'package:flutter_application_1/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  State<NavDrawer> createState() => NavDrawerState();
}

class NavDrawerState extends State<NavDrawer> {
  Apps apps = Apps();
  List<String>? names;
  List<String>? iconUrls;
  List<String>? urls;
  String? selectedApp;

  Future<void> loadUserInfo(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? userName = prefs.getString('userName');
    String? userEmail = prefs.getString('userEmail');

    openProfilePreview(context, userName ?? 'N/A', userEmail ?? 'N/A');
  }

  @override
  void initState() {
    super.initState();
    loadApps();
  }

  Future<void> loadApps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    names = prefs.getStringList('names');
    iconUrls = prefs.getStringList('images');
    urls = prefs.getStringList('urls');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.indigo,
              image: DecorationImage(
                fit: BoxFit.fill,
                image: AssetImage('assets/wheat.jpg'),
              ),
            ),
            child: Container(),
          ),
          ListTile(
            leading: const Icon(Icons.person_outlined, size: 35),
            title: const Text('Profile'),
            onTap: () {
              printAllShared();
              loadUserInfo(context);
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.apps, size: 35),
            title: const Text('Uygulamalar'),
            children: [
              if (names != null)
                for (int i = 0; i < names!.length; i++)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: Colors.indigo,
                      backgroundColor: Colors.indigo[100],
                    ),
                    onPressed: () {
                      UrlLauncher(urls![i]);
                      setState(() {
                        selectedApp = names![i];
                      });
                      Navigator.of(context).pop();
                    },
                    child: Row(
                      children: [
                        Image.network(
                          iconUrls![i],
                          height: 32,
                          width: 32,
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Text(
                          names![i],
                          style: const TextStyle(
                              color: Color.fromARGB(255, 65, 9, 70),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
            leading: const Icon(Icons.border_color),
            title: const Text('Feedback'),
            onTap: () => Navigator.of(context).pop(),
          ),
          ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () async {
                logout(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginPage(),
                  ),
                );
              }),
        ],
      ),
    );
  }

  void openProfilePreview(
      BuildContext context, String userName, String userEmail) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: const AssetImage('assets/gigity.png'),
                  child: Container(
                    width: 100,
                    height: 100,
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
                  extractNameFromUsername(userName ?? 'BOŞ'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mail: $userEmail',
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color.fromARGB(255, 48, 48, 54),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Apps {
  Future<void> displayApps(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? names = prefs.getStringList('names');
    List<String>? iconUrls = prefs.getStringList('iconUrls');
    List<String>? urls = prefs.getStringList('urls');

    if (names == null ||
        iconUrls == null ||
        urls == null ||
        names.isEmpty ||
        iconUrls.isEmpty ||
        urls.isEmpty) {
      print('Uygulama yok.');
    } else {
      Navigator.of(context).pop();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AppsScreen(
            names: names,
            iconUrls: iconUrls,
            urls: urls,
          ),
        ),
      );
    }
  }
}

class AppsScreen extends StatelessWidget {
  final List<String>? names;
  final List<String>? iconUrls;
  final List<String>? urls;

  const AppsScreen(
      {Key? key,
      required this.names,
      required this.iconUrls,
      required this.urls})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apps'),
      ),
      body: ListView.builder(
        itemCount: names!.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(
              iconUrls![index],
              height: 32,
              width: 32,
            ),
            onTap: () {
              print('test from onTap() call');
            },
            title: Text(names![index]),
          );
        },
      ),
    );
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
