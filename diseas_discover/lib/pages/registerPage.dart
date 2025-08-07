import 'package:diseas_discover/pages/LoginPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:diseas_discover/pages/homePage.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validation failed, do not proceed.
    }

    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await userCredential.user!
            .updateDisplayName(usernameController.text.trim());
      }

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'فشل في إنشاء الحساب. يرجى المحاولة مرة أخرى.';
      if (e.code == 'weak-password') {
        errorMessage = 'كلمة المرور التي أدخلتها ضعيفة جدًا.';
      } else if (e.code == 'email-already-in-use') {
        errorMessage = 'هذا البريد الإلكتروني مسجل بالفعل.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'البريد الإلكتروني الذي أدخلته غير صالح.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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

    return Scaffold(
      appBar: AppBar(
        // Add a back button and a transparent app bar for better UX
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: BackButton(color: theme.colorScheme.primary),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- 1. THEMED HEADER ---
                  Icon(
                    CupertinoIcons.person_add_solid,
                    size: 50,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'إنشاء حساب جديد',
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'املأ الحقول التالية للانضمام إلينا',
                    textAlign: TextAlign.center,
                    style: textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 32),

                  // --- 2. THEMED TEXTFORMFIELDS ---
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: Icon(CupertinoIcons.person_fill),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'من فضلك ادخل اسم المستخدم';
                      }
                      if (value.trim().length < 3) {
                        return 'اسم المستخدم يجب ان يحتوي على 3 حروف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: Icon(CupertinoIcons.mail_solid),
                    ),
                    validator: (value) {
                      if (value == null ||
                          !RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                              .hasMatch(value)) {
                        return 'الرجاء إدخال بريد إلكتروني صحيح';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة السر',
                      prefixIcon: const Icon(CupertinoIcons.lock_fill),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword
                            ? CupertinoIcons.eye_slash_fill
                            : CupertinoIcons.eye_fill),
                        onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'كلمة السر يجب ان تحتوي على 6 أحرف على الأقل';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'تأكيد كلمة السر',
                      prefixIcon: const Icon(CupertinoIcons.lock_shield_fill),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword
                            ? CupertinoIcons.eye_slash_fill
                            : CupertinoIcons.eye_fill),
                        onPressed: () => setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                    ),
                    validator: (value) {
                      if (value != passwordController.text) {
                        return 'كلمة السر غير متطابقة';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // --- 3. THEMED REGISTER BUTTON ---
                  ElevatedButton(
                    onPressed: isLoading ? null : _register,
                    child: isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3),
                          )
                        : const Text('إنشاء حساب'),
                  ),
                  const SizedBox(height: 24),

                  // --- 4. THEMED LOGIN LINK ---
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: "لديك حساب بالفعل؟ ",
                      style: textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: 'تسجيل الدخول',
                          style: textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              if (!isLoading) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const LoginPage()),
                                );
                              }
                            },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
