import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/createAccountService.dart';
import 'package:flutter_application_1/services/getSQLservice.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  SignUpPageState createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController repeatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Oluştur'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Mail'),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Parola'),
            ),
            TextFormField(
              controller: repeatController,
              obscureText: true,
              decoration:
                  const InputDecoration(labelText: 'Parolayı tekrar edin'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                showSignUpDialog();
              },
              child: const Text('Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  void showSignUpDialog() async {
    String mail = emailController.text;
    String password = passwordController.text;
    String repeat = repeatController.text;

    if (mail.isEmpty || password.isEmpty || repeat.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(' Hata'),
            content: const Text('Lütfen bütün alanları doldurun'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      Map<String, dynamic>? responseData =
          await createAccountInterceptor(mail, password, repeat, context);
    }
  }
}
