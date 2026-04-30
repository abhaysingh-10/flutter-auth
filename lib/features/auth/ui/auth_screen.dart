import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';
import '../models/auth_state.dart';
import 'widgets/custom_text_field.dart';
import 'widgets/auth_button.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _identifierController = TextEditingController(); // For Email or Username
  final _passwordController = TextEditingController();

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_isLogin) {
      ref.read(authProvider.notifier).login(
            _identifierController.text.trim(),
            _passwordController.text.trim(),
          );
    } else {
      ref.read(authProvider.notifier).register(
            _nameController.text.trim(),
            _usernameController.text.trim(),
            _identifierController.text.trim(), // Use as Email in registration
            _passwordController.text.trim(),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    ref.listen(authProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message), backgroundColor: Colors.red),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_person_rounded,
                      size: 50,
                      color: Colors.deepPurple,
                    ),
                  )
                  .animate()
                  .scale(duration: 600.ms, curve: Curves.easeOutBack)
                  .rotate(begin: -0.1, end: 0, duration: 600.ms),
                ),
                const SizedBox(height: 30),
                Text(
                  _isLogin ? 'Welcome Back!' : 'Create Account',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2),
                Text(
                  _isLogin 
                    ? 'Please sign in to continue' 
                    : 'Fill in the details to get started',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.2),
                const SizedBox(height: 30),
                if (!_isLogin) ...[
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    icon: Icons.person_outline,
                    validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: 15),
                  CustomTextField(
                    controller: _usernameController,
                    label: 'Username',
                    icon: Icons.alternate_email,
                    validator: (val) => val!.isEmpty ? 'Enter a username' : null,
                  ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.1),
                  const SizedBox(height: 15),
                ],
                CustomTextField(
                  controller: _identifierController,
                  label: _isLogin ? 'Email or Username' : 'Email Address',
                  icon: _isLogin ? Icons.login : Icons.email_outlined,
                  validator: (val) {
                    if (val!.isEmpty) return 'This field is required';
                    if (!_isLogin && !val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                const SizedBox(height: 15),
                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (val) => val!.length < 8 
                      ? 'Password must be at least 8 chars' : null,
                ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
                const SizedBox(height: 30),
                AuthButton(
                  text: _isLogin ? 'Login' : 'Sign Up',
                  isLoading: state is AuthLoading,
                  onPressed: _submit,
                ).animate().fadeIn(delay: 700.ms).scale(),
                const SizedBox(height: 20),
                
                // Social Login Options
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text('OR', style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _socialButton(
                      icon: Icons.g_mobiledata_rounded,
                      label: 'Google',
                      onTap: state is AuthLoading 
                          ? () {} 
                          : () => ref.read(authProvider.notifier).loginWithGoogle(),
                    ),
                    _socialButton(
                      icon: Icons.apple,
                      label: 'Apple',
                      onTap: state is AuthLoading 
                          ? () {} 
                          : () => ref.read(authProvider.notifier).loginWithApple(),
                    ),
                  ],
                ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: _toggleAuthMode,
                    child: RichText(
                      text: TextSpan(
                        text: _isLogin 
                            ? "Don't have an account? " 
                            : "Already have an account? ",
                        style: GoogleFonts.poppins(color: Colors.grey[600]),
                        children: [
                          TextSpan(
                            text: _isLogin ? 'Sign Up' : 'Login',
                            style: GoogleFonts.poppins(
                              color: Colors.deepPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 1000.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _socialButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
