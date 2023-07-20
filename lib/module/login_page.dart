import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googlecloudstoragedemo/config/sp_key.dart';
import 'package:googlecloudstoragedemo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? emailAddress;
  String? password;
  bool showLoading = true;
  bool isLogin = false;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    var sp = await SharedPreferences.getInstance();
    emailAddress = sp.getString(SpKey.emailAddress);
    password = sp.getString(SpKey.password);
    setState(() {
      isLogin = emailAddress?.isNotEmpty == true && password?.isNotEmpty == true;
      showLoading = false;
    });
  }

  void saveAccountInfo(String emailAddress, String password) async {
    var sp = await SharedPreferences.getInstance();
    await sp.setString(SpKey.emailAddress, emailAddress);
    await sp.setString(SpKey.password, password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            showLoading
                ? const CircularProgressIndicator()
                : isLogin
                    ? ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            showLoading = true;
                          });
                          userLogin(emailAddress!, password!);
                        },
                        child: const Text('登录账号'),
                      )
                    : ElevatedButton(
                        onPressed: () async {
                          createUser('test@gamil.com', '598423Test');
                        },
                        child: const Text('创建账号'),
                      )
          ],
        ),
      ),
    );
  }

  void createUser(String emailAddress, String password) async {
    try {
      setState(() {
        showLoading = true;
      });
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailAddress, password: password);
      userLogin(emailAddress, password);
    } on FirebaseAuthException catch (e) {
      print('macy777 ----> ${e.code}  ${e.message}');
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        setState(() {
          showLoading = false;
        });
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        //TODO
        userLogin(emailAddress, password);
      }
    } catch (e) {
      print('macy777 -----createUser------ $e');
      setState(() {
        showLoading = false;
      });
    }
  }

  void userLogin(String emailAddress, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailAddress, password: password);
      saveAccountInfo(emailAddress, password);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) {
              return const MyHomePage(title: 'Home Page');
            },
          ),
          (route) => false,
        );
        showLoading = false;
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        showLoading = false;
      });
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print('macy777 -----userLogin------ $e');
      setState(() {
        showLoading = false;
      });
    }
  }
}
