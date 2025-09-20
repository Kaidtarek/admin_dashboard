import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'auth_state.dart'; 

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstKeyController = TextEditingController();
  final _secondKeyController = TextEditingController();

  bool _loading = false;

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    await Future.delayed(const Duration(seconds: 1)); // simulate delay

    final firstKey = _firstKeyController.text.trim();
    final secondKey = _secondKeyController.text.trim();

    if (firstKey == '2222' && secondKey == 'xxxx') {
  AuthState.isLoggedIn = true; 
  if (mounted) context.go('/dashboard'); 
} else {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Invalid credentials')),
  );
}


    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 6,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 64, color: Colors.blue),
                    const SizedBox(height: 16),
                    Text(
                      'Secure Login',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: _firstKeyController,
                      decoration: const InputDecoration(
                        labelText: 'First Key',
                        prefixIcon: Icon(Icons.vpn_key),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter first key' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _secondKeyController,
                      decoration: const InputDecoration(
                        labelText: 'Second Key',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) =>
                          value!.isEmpty ? 'Enter second key' : null,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
