import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_admin/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'Toast.dart';
import 'configuration.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/login' ,
      builder: FlutterSmartDialog.init(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => const LoginPage(title: 'Login'),
      }
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.title});


  final String title;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: LoginForm());
  }
}

class LoginForm extends StatefulWidget {
  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      final String username = _usernameController.text;
      final String password = _passwordController.text;

      // Replace the API endpoint and payload with your actual API details
      var baseUrl = Configuration.API_URL;
      final String apiUrl = baseUrl + '/admin_login';
      final Map<String, String> data = {'username': username, 'password': password};

      try {
        SmartDialog.showLoading(msg: 'Logging in...');
        final response = await http.post(Uri.parse(apiUrl), body: data);

        if (response.statusCode == 200) {
          // Successful login
          final Map<String, dynamic> responseBody = jsonDecode(response.body);
          var token = responseBody['accessToken']['token'];

          final prefs = await SharedPreferences.getInstance();
          prefs.setString(Configuration.TOKEN_NAME, token);

          // Do something with the token, e.g., save it for future requests
          print('Login successful. Token: $token');
          SmartDialog.dismiss();
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        } else {
          SmartDialog.dismiss();
          // Failed login
          print('Login failed. Status code: ${response.statusCode}');
          SmartDialog.showToast('',builder: (_)=>CustomToast('Login failed. Status code: ${response.statusCode}'));
        }
      } catch (error) {
        SmartDialog.dismiss();
        SmartDialog.showToast('',builder: (_)=>CustomToast('Login failed'));
        // Handle network or other errors
        print('Error during login: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold),),
        backgroundColor:Theme.of(context).primaryColor,),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 75,
                  backgroundImage: AssetImage('assets/images/admin.png'), // Replace with your admin image asset
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _usernameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if(value.length < 2){
                      return 'Password is too short';
                    }
                    return null;
                  },
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                  ),
                  onPressed: _login,
                  child: Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
