import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/logged.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/getSQLservice.dart';
import '../services/logoutService.dart';
import '../utils/generic.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({Key? key}) : super(key: key);

  @override
  State<NavDrawer> createState() => NavDrawerState();
}

class NavDrawerState extends State<NavDrawer> {
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
    bool isAyarlarExpanded = false;

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
            leading: const Icon(Icons.person_outlined, size: 30),
            title: const Text(
              'Profil',
              style: TextStyle(fontSize: 17),
            ),
            onTap: () {
              loadUserInfo(context);
            },
          ),
          ExpansionTile(
            leading: const Icon(Icons.apps, size: 30),
            title: const Text(
              'Uygulamalar',
              style: TextStyle(fontSize: 17),
            ),
            children: [
              if (names != null)
                for (int i = 0; i < names!.length; i++)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shadowColor: const Color.fromARGB(0, 63, 81, 181),
                      backgroundColor: const Color.fromARGB(0, 197, 202, 233),
                    ),
                    onPressed: () {
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
                              color: Color.fromARGB(255, 86, 105, 211),
                              fontWeight: FontWeight.bold,
                              fontSize: 17),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
          ExpansionTile(
            leading: const Icon(Icons.settings, size: 30),
            title: const Text(
              'Ayarlar',
              style: TextStyle(fontSize: 17),
            ),
            children: [
              //IconButton(onPressed: () {}, icon: Icons.dark_mode_outlined)
            ],
          ),
          ListTile(
            leading: const Icon(Icons.content_paste_search_outlined, size: 30),
            title: const Text(
              'Sorgu',
              style: TextStyle(fontSize: 17),
            ),
            onTap: () {
              getData(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app, size: 30),
            title: const Text(
              'Çıkış yap',
              style: TextStyle(fontSize: 17),
            ),
            onTap: () async {
              logout(context);
              Navigator.of(context).pop();
            },
          ),
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
