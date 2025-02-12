import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isEmailVerified = false;
  bool _isEmailSent = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                suffixIcon: _isEmailSent 
                  ? Icon(Icons.check_circle, color: Colors.green)
                  : IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () => _sendVerificationEmail(context),
                    ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            if (_isEmailSent && !_isEmailVerified)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Please check your email and verify your account',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _checkEmailVerification(context),
                      child: Text('Check Verification'),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
              enabled: _isEmailVerified, // Only enable if email is verified
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isEmailVerified ? () => _signUp(context) : null,
              child: _isLoading 
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendVerificationEmail(BuildContext context) async {
    final String email = _emailController.text.trim();
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      // Check if email is already in use
      List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      if (signInMethods.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This email is already registered. Please use a different email.')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Create a temporary user with email and random password
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email, 
              password: 'temporary${DateTime.now().millisecondsSinceEpoch}', // unique temporary password
          );

      // Send verification email
      await userCredential.user!.sendEmailVerification();
      
      // Store the temporary user UID in Firestore with a timestamp
      await FirebaseFirestore.instance.collection('tempUsers').doc(userCredential.user!.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'isVerified': false
      });
      
      setState(() {
        _isEmailSent = true;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification email sent. Please check your inbox and click the verification link.'),
          duration: Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String message = 'An error occurred';
      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered. Please use a different email.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _checkEmailVerification(BuildContext context) async {
    final String email = _emailController.text.trim();
    
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an email address')),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please send verification email first')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // Reload user to get latest verification status
      await currentUser.reload();
      currentUser = FirebaseAuth.instance.currentUser; // Get fresh user object

      if (currentUser?.emailVerified == true) {
        // Update temp user document
        await FirebaseFirestore.instance.collection('tempUsers')
            .doc(currentUser!.uid)
            .update({'isVerified': true});

        setState(() {
          _isEmailVerified = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please click the verification link sent to your email'),
            backgroundColor: Colors.orange,
          ),
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  void dispose() {
    // Clean up temporary user if verification wasn't completed
    _cleanupTempUser();
    super.dispose();
  }

  Future<void> _cleanupTempUser() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && !_isEmailVerified) {
        // Delete the temporary user document
        await FirebaseFirestore.instance.collection('tempUsers')
            .doc(currentUser.uid)
            .delete();
        // Delete the temporary user account
        await currentUser.delete();
      }
    } catch (e) {
      print('Error cleaning up temporary user: $e');
    }
  }

  Future<void> _signUp(BuildContext context) async {
    if (!_isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please verify your email first')),
      );
      return;
    }

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get the current user (which should be our verified temporary user)
      User? currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        // Update the password for the existing user
        await currentUser.updatePassword(password);
        
        // Update the user status in Firestore
        await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).set({
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
          'isVerified': true,
        });

        // Delete the temporary user document
        await FirebaseFirestore.instance.collection('tempUsers')
            .doc(currentUser.uid)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration Successful'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context);
      } else {
        throw Exception('No verified user found');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing registration: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
} 