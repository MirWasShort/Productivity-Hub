import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passswordReset() async {
    try {
      FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(content: Text('We sent an email to reset your password. Check your mailbox!'));
        },
      );
    } on FirebaseAuthException catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(content: Text(e.message.toString()));
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Enter your email. A link for password reset will be sent to your address',
            style: TextStyle(
              fontSize: 24,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color.fromARGB(255, 85, 6, 84)),
                  borderRadius: BorderRadius.circular(12),
                ),
                hintText: 'Email',
                hintStyle: TextStyle(fontSize: 18),
                fillColor: Color.fromARGB(255, 85, 6, 84),
                filled: true,
              ),
            ),
          ),
          SizedBox(height: 12),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: WidgetStatePropertyAll(
                Color.fromARGB(255, 85, 6, 84),
              ),
            ),
            onPressed: () {},
            child: Text(
              'Reset Password.',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}
