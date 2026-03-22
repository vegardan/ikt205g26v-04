import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:ikt205g26v_04/pages/login.dart';
import 'package:ikt205g26v_04/utils/snackbar_utils.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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
      appBar: AppBar(elevation: 6, title: Text('Signup')),
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
                            await Supabase.instance.client.auth.signUp(email: _emailController.text.trim(), password: _passwordController.text.trim());

                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));

                            SnackBarUtils.infoSnackBar(context, 'Email verification sent');
                          } catch (e) {
                            SnackBarUtils.errorSnackBar(context, 'Signup failed');

                            setState(() {
                              _loading = false;
                            });
                          }
                        },
                        icon: Icon(Icons.login),
                        label: Text('Signup'),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginPage()));
                        },
                        child: Text('Already have an account?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
