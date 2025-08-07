import 'package:diseas_discover/pages/homePage.dart';
import 'package:diseas_discover/pages/registerPage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart'; // For CupertinoIcons

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message ?? 'فشل تسجيل الدخول'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // This screen will now automatically have the theme's background color.
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- 1. ADDED A HEADER FOR VISUAL APPEAL ---
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  child: Icon(
                    CupertinoIcons.lock_shield_fill,
                    size: 45,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'تسجيل الدخول',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'مرحباً بعودتك! يرجى إدخال بياناتك',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 32),

                // --- 2. REPLACED CustomInputField WITH STANDARD TextFormField ---
                // These TextFormFields automatically get their style from the InputDecorationTheme in AppTheme.
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    prefixIcon: Icon(CupertinoIcons.mail_solid),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة السر',
                    prefixIcon: Icon(CupertinoIcons.lock_fill),
                  ),
                ),
                const SizedBox(height: 24),

                // --- 3. THEMED "CREATE ACCOUNT" LINK ---
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    text: "ليس لديك حساب؟ ",
                    style: textTheme.bodyMedium, // Uses themed text style
                    children: [
                      TextSpan(
                        text: 'إنشاء حساب',
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme
                              .colorScheme.primary, // Uses themed primary color
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: theme.colorScheme.primary,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            if (!isLoading) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>  Register()),
                              );
                            }
                          },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- 4. SIMPLIFIED AND THEMED LOGIN BUTTON ---
                // This button now fully inherits its style from the ElevatedButtonTheme.
                ElevatedButton(
                  onPressed: isLoading ? null : _login,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text('تسجيل الدخول'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
