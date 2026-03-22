import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:ikt205g26v_04/pages/home.dart';
import 'package:ikt205g26v_04/pages/signup.dart';
import 'package:ikt205g26v_04/utils/snackbar_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 6, title: Text('Login')),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        maxLines: 1,
                        decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Email field is empty'
                            : !EmailValidator.validate(value)
                            ? 'Email address is invalid'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        maxLines: 1,
                        decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                        validator: (value) => value == null || value.isEmpty ? 'Password field is empty' : null,
                      ),
                      const SizedBox(height: 12),
                      FilledButton.tonalIcon(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          }

                          setState(() {
                            _loading = true;
                          });

                          try {
                            await Supabase.instance.client.auth.signInWithPassword(email: _emailController.text.trim(), password: _passwordController.text.trim());

                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const HomePage()));

                            SnackBarUtils.infoSnackBar(context, 'Login successful');
                          } catch (e) {
                            SnackBarUtils.errorSnackBar(context, 'Login failed');

                            setState(() {
                              _loading = false;
                            });
                          }
                        },
                        icon: Icon(Icons.login),
                        label: Text('Login'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const SignupPage()));
                        },
                        child: Text('Don\'t have an account?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
