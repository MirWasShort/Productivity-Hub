import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:tasks_manager/screens/reset_password_screen.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  var _isLogin = true;
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUsername = '';
  var _isAuthenticating = false;
  var _isObscured = true;

  final _googleSignIn = GoogleSignIn.instance;
  bool _googleSignInReady = false;

  Future<void> _ensureGoogleSignInReady() async {
    if (_googleSignInReady) return;
    await _googleSignIn.initialize(
      clientId:
          '388823757393-mqrte4mvr38pjiah4q0t9dueh3kdrlui.apps.googleusercontent.com',
    );
    _googleSignInReady = true;
  }

  Future<void> _ensureUserDocument({
    required String uid,
    required String? username,
    required String? email,
  }) async {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(uid);
    final existing = await userDoc.get();
    if (!existing.exists) {
      await userDoc.set({
        'username': username ?? email ?? 'user',
        'email': email ?? '',
      });
    }
  }

  void _submit() async {
    final isValid = _formKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    _formKey.currentState!.save();

    try {
      setState(() {
        _isAuthenticating = true;
      });

      if (_isLogin) {
        await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        //Username required for registration
        final userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        await _ensureUserDocument(
          uid: userCredentials.user!.uid,
          username: _enteredUsername,
          email: _enteredEmail,
        );
      }
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
      setState(() {
        _isAuthenticating = false;
      });
    }
  }

  void _submitWithGoogle() async {
    setState(() {
      _isAuthenticating = true;
    });

    try {
      await _ensureGoogleSignInReady();

      final googleUser = await _googleSignIn.authenticate();
      final googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebase.signInWithCredential(credential);

      await _ensureUserDocument(
        uid: userCredential.user!.uid,
        username: googleUser.displayName,
        email: googleUser.email,
      );
    } on GoogleSignInException catch (error) {
      // This error is simply going back from account selection
      if (error.code == GoogleSignInExceptionCode.canceled) {
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to LogIn using Google credentials: ${error.description ?? error.code.name}',
          ),
        ),
      );
    } on FirebaseAuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message ?? 'Authentication failed.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 45, 2, 48),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: 40,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Icon(Icons.lock, color: Colors.white, size: 150),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              icon: Icon(Icons.email_outlined),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !value.contains('@')) {
                                return 'Please enter a valid Email address';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredEmail = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Username',
                                icon: Icon(Icons.person),
                              ),
                              enableSuggestions: false,
                              validator: (value) {
                                if (value == null || value.trim().length < 4) {
                                  return 'Please enter a valid username. Must be at least 4 characters';
                                }

                                return null;
                              },
                              onSaved: (value) {
                                _enteredUsername = value!;
                              },
                            ),
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: 'Password',
                              icon: Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isObscured = !_isObscured;
                                  });
                                },
                                icon: _isObscured
                                    ? Icon(Icons.visibility_outlined)
                                    : Icon(Icons.visibility_off_outlined),
                              ),
                            ),
                            obscureText: _isObscured,
                            validator: (value) {
                              if (value == null || value.trim().length < 8) {
                                return 'Password must be at least 8 characters long';
                              }

                              return null;
                            },
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          SizedBox(height: 12),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return ResetPasswordScreen();
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          if (_isAuthenticating)
                            const CircularProgressIndicator(),
                          if (!_isAuthenticating)
                            ElevatedButton(
                              onPressed: _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                              ),
                              child: Text(
                                _isLogin ? 'Sign in' : 'Sign up',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          if (!_isAuthenticating)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isLogin = !_isLogin;
                                });
                              },
                              child: Text(
                                _isLogin
                                    ? 'Create an account'
                                    : 'I already have an account',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (!_isAuthenticating) ...[
                SizedBox(height: 18),
                GestureDetector(
                  onTap: _submitWithGoogle,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      border: BoxBorder.all(
                        color: const Color.fromARGB(255, 45, 2, 48),
                      ),
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                    ),
                    child: Image.asset('assets/images/google.webp', height: 40),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
