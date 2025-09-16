import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  static const String _apiBase = 'http://localhost:5000';

  Future<void> _sendCode() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    try {
      final uri = Uri.parse('$_apiBase/api/users/forgot');
      final res = await http.post(
        uri,
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({ 'email': _emailController.text.trim() }),
      );

      if (!mounted) return;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reset code sent to your email')));
        Navigator.of(context).pushReplacementNamed('/verify');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed (${res.statusCode}) to send code')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),
              Center(child: Text('Forgot password?', style: Theme.of(context).textTheme.headlineMedium)),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email address'),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter your email';
                        if (!v.contains('@')) return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _sendCode,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Send Code'),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                child: const Text('Already have an account? Sign in'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
