import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key});

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  static const String _apiBase = 'http://localhost:5000';
  final _emailController = TextEditingController();

  @override
  void dispose() {
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _controllers.map((c) => c.text).join();
    final email = _emailController.text.trim();
    if (code.length != 6 || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter email and 6-digit code')));
      return;
    }

    try {
      final uri = Uri.parse('$_apiBase/api/users/verify-code');
      final res = await http.post(
        uri,
        headers: { 'Content-Type': 'application/json' },
        body: jsonEncode({ 'email': email, 'code': code }),
      );

      if (!mounted) return;
      if (res.statusCode >= 200 && res.statusCode < 300) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code verified. Now reset your password')));
        // For simplicity navigate back to login after verify
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid code (${res.statusCode})')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildBox(int index) {
    return SizedBox(
      width: 44,
      child: TextField(
        controller: _controllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        decoration: const InputDecoration(counterText: ''),
        onChanged: (v) {
          if (v.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          }
          if (v.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
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
              const SizedBox(height: 60),
              Center(child: Text('Check Your Email', style: Theme.of(context).textTheme.headlineMedium)),
              const SizedBox(height: 12),
              Center(child: Text('We\'ve just sent your email verification code.')),
              const SizedBox(height: 24),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email used for reset'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) => Padding(padding: const EdgeInsets.symmetric(horizontal:6.0), child: _buildBox(i))),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _verify,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Verify'),
              ),
              TextButton(onPressed: () {}, child: const Text('Resend the code')),
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
