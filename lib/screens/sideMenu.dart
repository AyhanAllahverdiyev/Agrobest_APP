import 'package:flutter/material.dart';
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
            leading: const Icon(Icons.person_outlined, size: 35),
            title: const Text('Profile'),
            onTap: () {
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
          ExpansionTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ayarlar'),
            onExpansionChanged: (expanded) {
              setState(() {
                isAyarlarExpanded = expanded;
              });
            },
            children: [
              if (isAyarlarExpanded)
                ListTile(
                  title: const Text('Button 1'),
                  onTap: () {
                    // Action for Button 1
                    // Example: Navigator.push(...);
                    Navigator.of(context).pop();
                  },
                ),
              if (isAyarlarExpanded)
                ListTile(
                  title: const Text('Button 2'),
                  onTap: () {
                    // Action for Button 2
                    // Example: Navigator.push(...);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
          ListTile(
            leading: const Icon(Icons.content_paste_search_outlined),
            title: const Text('Sorgu'),
            onTap: () {
              getData(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Çıkış yap'),
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
