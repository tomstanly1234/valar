import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  bool isLogin       = true;
  bool isLoading     = false;
  bool _showPassword = false; // ← controls eye icon

  // Valar brand colours
  static const Color _brandBlue     = Color(0xFF2A7FC1);
  static const Color _brandBlueDark = Color(0xFF1A5F96);
  static const Color _brandBluePale = Color(0xFFD6EDFB);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError("Please enter email and password.");
      return;
    }

    try {
      setState(() => isLoading = true);

      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password,
        );
      } else {
        final cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email, password: password,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set({
          'email':     cred.user!.email,
          'createdAt': Timestamp.now(),
        });
      }
      // Navigation handled by StreamBuilder in main.dart
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? 'Authentication failed.');
    } catch (e) {
      showError(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [

          // ── Background image ──────────────────────────────────────────
          Positioned.fill(
            child: Image.asset(
              'assets/images/valar_bg.jpeg',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),

          // ── Left-to-right gradient overlay ───────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _brandBlueDark.withOpacity(0.92),
                    _brandBlue.withOpacity(0.55),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 0.75],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),

          // ── Top/bottom vignette ───────────────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.15),
                    Colors.transparent,
                    Colors.black.withOpacity(0.10),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // ── Main content ──────────────────────────────────────────────
          Positioned.fill(
            child: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 32),
                  child: Align(
                    alignment: size.width > 700
                        ? Alignment.centerLeft
                        : Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          // ── Valar branding ─────────────────────────
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Valar",
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Built By Medical Minds, For Modern Parents.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // ── Login card ─────────────────────────────
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.93),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 40,
                                  spreadRadius: -4,
                                  color: _brandBlueDark.withOpacity(0.35),
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                // Title
                                Text(
                                  isLogin ? "Welcome to Valar 👋" : "Create account",
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: _brandBlueDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isLogin
                                      ? "Sign in to track your child's growth"
                                      : "Start your child's growth journey",
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey.shade500),
                                ),

                                const SizedBox(height: 24),

                                // Email field
                                _buildInput(
                                  "Email",
                                  emailController,
                                  icon: Icons.email_outlined,
                                ),
                                const SizedBox(height: 14),

                                // Password field with show/hide toggle
                                _buildPasswordInput(),

                                const SizedBox(height: 24),

                                // Sign In / Sign Up button
                                SizedBox(
                                  height: 52,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : submit,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _brandBlue,
                                      foregroundColor: Colors.white,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            isLogin ? "Sign In" : "Sign Up",
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 16),

                                // Toggle login ↔ signup
                                Center(
                                  child: TextButton(
                                    onPressed: isLoading
                                        ? null
                                        : () => setState(
                                            () => isLogin = !isLogin),
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey.shade600),
                                        children: [
                                          TextSpan(
                                            text: isLogin
                                                ? "Don't have an account? "
                                                : "Already have an account? ",
                                          ),
                                          TextSpan(
                                            text: isLogin
                                                ? "Sign Up"
                                                : "Sign In",
                                            style: const TextStyle(
                                              color: _brandBlue,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Regular text input ──────────────────────────────────────────────────
  Widget _buildInput(
    String label,
    TextEditingController controller, {
    IconData? icon,
    bool obscure = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null
            ? Icon(icon, color: _brandBlue, size: 20)
            : null,
        filled: true,
        fillColor: _brandBluePale.withOpacity(0.5),
        labelStyle:
            TextStyle(color: Colors.grey.shade500, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _brandBlue, width: 1.5),
        ),
      ),
    );
  }

  // ── Password input with show/hide eye icon ──────────────────────────────
  Widget _buildPasswordInput() {
    return TextField(
      controller: passwordController,
      obscureText: !_showPassword, // hidden unless toggled
      decoration: InputDecoration(
        labelText: "Password",
        prefixIcon:
            const Icon(Icons.lock_outline, color: _brandBlue, size: 20),
        // Eye toggle button on the right
        suffixIcon: IconButton(
          icon: Icon(
            _showPassword
                ? Icons.visibility_outlined      // eye open
                : Icons.visibility_off_outlined, // eye closed
            color: Colors.grey.shade500,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _showPassword = !_showPassword),
          tooltip: _showPassword ? "Hide password" : "Show password",
        ),
        filled: true,
        fillColor: _brandBluePale.withOpacity(0.5),
        labelStyle:
            TextStyle(color: Colors.grey.shade500, fontSize: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: _brandBlue, width: 1.5),
        ),
      ),
    );
  }
}