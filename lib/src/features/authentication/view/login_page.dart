import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../kalmora_app/view/journaling/dash_board.dart';
import '../controller/login_page_controller.dart';
import '../model/login_page_model.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final LoginPageController _controller = LoginPageController();
  bool _rememberMe = false;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
    _checkIfUserIsLoggedIn();
  }

  Future<void> _loadSavedCredentials() async {
    final Map<String, dynamic> prefs = await _controller.getRememberMePreference();
    if (mounted) {
      setState(() {
        _rememberMe = prefs['rememberMe'];
        if (_rememberMe) {
          _emailController.text = prefs['savedEmail'];
        }
      });
    }
  }

  Future<void> _checkIfUserIsLoggedIn() async {
    User? currentUser = await _controller.checkCurrentUser();
    if (currentUser != null && mounted) {
      // User is already logged in, navigate to home page
      // Uncomment and modify this to navigate to your home page
      // Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Handle login function to avoid async gap warning
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        UserCredential? userCredential = await _controller.loginWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (userCredential != null) {
          // Save remember me preference
          await _controller.saveRememberMePreference(_rememberMe, _emailController.text);

          // Save user model to Firestore
          LoginPageModel model = LoginPageModel(
            username: _usernameController.text.trim(),
            email: _emailController.text.trim(),
            rememberMe: _rememberMe,
          );

          await _controller.saveUserData(model, userCredential.user!.uid);

          // Navigate to dashboard
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardPage(), // Replace with your actual dashboard screen
            ),
          );
        }
      } catch (e) {
        String errorMessage = 'An error occurred during login.';
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'user-not-found':
              errorMessage = 'No user found with this email.';
              break;
            case 'wrong-password':
              errorMessage = 'Incorrect password.';
              break;
            case 'invalid-email':
              errorMessage = 'Invalid email address.';
              break;
            case 'user-disabled':
              errorMessage = 'This account has been disabled.';
              break;
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Handle forgot password function to avoid async gap warning
  void _handleForgotPassword() async {
    if (_emailController.text.isNotEmpty) {
      try {
        await _controller.sendPasswordResetEmail(_emailController.text);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!')),
        );
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email address')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Microphone icon
                    Icon(
                      Icons.mic_none_rounded,
                      size: 50,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontFamily: 'Cinzel',
                      ),
                    ),
                    const Text(
                      'BACK!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cinzel',
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Username field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5C9A6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          hintText: 'User Name',
                          prefixIcon: Icon(Icons.person_outline, color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        style: const TextStyle(color: Colors.black87),
                        validator: _controller.validateUsername,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Email field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5C9A6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          hintText: 'Email Address',
                          prefixIcon: Icon(Icons.email_outlined, color: Colors.black54),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        style: const TextStyle(color: Colors.black87),
                        keyboardType: TextInputType.emailAddress,
                        validator: _controller.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password field
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFD5C9A6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        style: const TextStyle(color: Colors.black87),
                        validator: _controller.validatePassword,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Remember me checkbox
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _rememberMe,
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value ?? false;
                              });
                            },
                            fillColor: WidgetStateProperty.resolveWith<Color>(
                                  (Set<WidgetState> states) {
                                if (states.contains(WidgetState.selected)) {
                                  return const Color(0xFFD5C9A6);
                                }
                                return Colors.transparent;
                              },
                            ),
                            side: const BorderSide(color: Color(0xFFD5C9A6)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'REMEMBER FOR 30 DAYS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Sign in button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD5C9A6),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBackgroundColor: const Color(0xFFD5C9A6).withValues(
                            red: 0xD5.toDouble(),
                            green: 0xC9.toDouble(),
                            blue: 0xA6.toDouble(),
                            alpha: (0.7 * 255), // Keep it as a double
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                            : const Text(
                          'SIGN IN',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Forgot password
                    GestureDetector(
                      onTap: _handleForgotPassword,
                      child: const Center(
                        child: Text(
                          'FORGOT PASSWORD?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Don't have an account
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'DON\'T HAVE AN ACCOUNT? ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Cinzel',
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to signup page
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignupPage()),
                            );
                          },
                          child: const Text(
                            'SIGN UP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              decoration: TextDecoration.underline,
                              fontFamily: 'Cinzel',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
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