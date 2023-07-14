import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googlecloudstoragedemo/main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              String emailAddress = 'test@gamil.com';
              String password = '598423Test';
              // createUser(emailAddress, password);
              userLogin(emailAddress, password);
            },
            child: const Text('创建账号'),
          )
        ],
      ),
    );
  }

  void createUser(String emailAddress, String password) {
    try {
      FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailAddress, password: password).then((value) {
        userLogin(emailAddress, password);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print('macy777 -----createUser------ $e');
    }
  }

  void userLogin(String emailAddress, String password) {
    try {
      FirebaseAuth.instance.signInWithEmailAndPassword(email: emailAddress, password: password).then((value) {
        Navigator.push(context, MaterialPageRoute(
          builder: (_) {
            return const MyHomePage(title: 'Home Page');
          },
        ));
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print('macy777 -----userLogin------ $e');
    }
  }
}
