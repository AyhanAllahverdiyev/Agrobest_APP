import 'package:flutter/material.dart';
import '../services/loginService.dart';
import '../services/refreshTokenService.dart';
import 'logged.dart';
import 'createAccount.dart';
import 'package:flutter_application_1/utils/generic.dart';

void main() {
  runApp(const LoginApp());
}

class LoginApp extends StatelessWidget {
  const LoginApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Page',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  final TextEditingController _mailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  bool _isResumingFromBackground = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      if (_isResumingFromBackground) {
        refresfTokens(context);
        print('Welcome back');
      }
      _isResumingFromBackground = false;
    } else if (state == AppLifecycleState.paused) {
      _isResumingFromBackground = true;
    }
  }

  void login(BuildContext context) async {
    setState(() {
      _isLoading = true;
    });

    final String mail = _mailController.text;
    final String password = _passwordController.text;

    try {
      Map<String, dynamic> userData =
          await loginInterceptor(mail, password, context);
      print(
          '++++++++++++++++++++++++++++++++++++++++USERDATA FROM API++++++++++++++++++++++++++++++++++++ ');
      print(userData);

      if (userData != null) {
        String apiToken = userData['accessToken'];
        String refreshToken = userData['refreshToken'];
        String userName = userData['userName'];
        await saveUserInfo(apiToken, refreshToken, userName, mail);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const LoggedPage(),
          ),
        );
      }
    } catch (e) {
      print('Error during login: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 120,
              child: Image.asset('assets/thumb.png'),
            ),
            const SizedBox(height: 10.0),
            TextField(
              controller: _mailController,
              decoration: InputDecoration(
                hintText: 'Mail',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Parola',
                prefixIcon: const Icon(Icons.lock),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.blue,
              thickness: 1,
              indent: 55,
              endIndent: 55,
            ),
            const SizedBox(height: 8.0),
            const SizedBox(),
            const SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      askLocationPermission(context).then((bool location) {
                        if (location) {
                          getUserLocation();

                          login(context);
                        } else {
                          print('Location erisimi kapali');
                        }
                      }).catchError((e) {
                        print('Error at main.dart line 130: $e');
                      });
                    },
              child: _isLoading
                  ? CircularProgressIndicator()
                  : const Text('LOGIN'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SignUpPage(),
                  ),
                );
              },
              child: const Text(
                'Hesap oluştur',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
