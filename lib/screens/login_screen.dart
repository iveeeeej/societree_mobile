import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'societree/societree_dashboard.dart';
import '../services/api_service.dart';
import '../modules/elecom/elecom_admin/admin_home_screen.dart';
import 'package:centralized_societree/config/api_config.dart';
import 'package:centralized_societree/services/user_session.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// Student and Admin screens are now in separate files for clarity.

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  bool _acceptTerms = false;

  late final ApiService _api;

  @override
  void initState() {
    super.initState();
    _api = ApiService(baseUrl: apiBaseUrl);
  }

  Future<void> _forgotPassword() async {
    if (_loading) return;
    final idCtrl = TextEditingController(text: _emailCtrl.text.trim());
    String channel = 'email';
    final phoneCtrl = TextEditingController();
    final ok1 = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: StatefulBuilder(
            builder: (ctx, setState) => AlertDialog(
              title: const Text('Request OTP'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: idCtrl,
                    decoration: const InputDecoration(hintText: 'Enter your student ID'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: const Text('Email'),
                          value: 'email',
                          groupValue: channel,
                          onChanged: (v) => setState(() => channel = v ?? 'email'),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          dense: true,
                          visualDensity: VisualDensity.compact,
                          title: const Text('SMS'),
                          value: 'sms',
                          groupValue: channel,
                          onChanged: (v) => setState(() => channel = v ?? 'email'),
                        ),
                      ),
                    ],
                  ),
                  if (channel == 'sms') ...[
                    const SizedBox(height: 4),
                    TextField(
                      controller: phoneCtrl,
                      decoration: const InputDecoration(hintText: 'Phone number (e.g., 09XXXXXXXXX)'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
                ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('SEND')),
              ],
            ),
          ),
        );
      },
    );
    if (ok1 != true) return;
    final studentId = idCtrl.text.trim();
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your student ID')));
      return;
    }
    setState(() => _loading = true);
    try {
      final res = await _api.requestPasswordOtp(
        studentId: studentId,
        method: channel,
        phone: channel == 'sms' ? phoneCtrl.text.trim() : null,
      );
      if (res['success'] == true) {
        if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('OTP sent to your email')));
      } else {
        if (!mounted) return; ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((res['message'] ?? 'Failed to send OTP').toString())));
        if (mounted) setState(() => _loading = false);
        return;
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error sending OTP')));
        setState(() => _loading = false);
      }
      return;
    }

    final otpCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final ok2 = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            title: const Text('Reset Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: otpCtrl,
                  decoration: const InputDecoration(hintText: 'Enter 6-digit OTP'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: passCtrl,
                  decoration: const InputDecoration(hintText: 'New password'),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('RESET')),
            ],
          ),
        );
      },
    );
    if (ok2 == true) {
      try {
        final res2 = await _api.resetPasswordWithOtp(
          studentId: studentId,
          otp: otpCtrl.text.trim(),
          newPassword: passCtrl.text,
        );
        final success = res2['success'] == true;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text((res2['message'] ?? (success ? 'Password updated' : 'Reset failed')).toString())));
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error resetting password')));
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleAuth(bool isLogin) async {
    if (!_formKey.currentState!.validate()) return;
    if (isLogin && !_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please read and accept the Terms & Conditions')));
      return;
    }
    setState(() {
      _loading = true;
    });
    try {
      final studentId = _emailCtrl.text.trim();
      final password = _passwordCtrl.text;
      final res = isLogin
          ? await _api.login(studentId: studentId, password: password, acceptTerms: _acceptTerms)
          : await _api.register(studentId: studentId, password: password);
      final success = res['success'] == true;
      String msg = (res['message'] ?? (success ? 'Success' : 'Failed')).toString();
      if (!success) {
        final lower = msg.toLowerCase();
        if (lower.contains('wrong password')) {
          msg = 'Incorrect password';
        } else if (lower.contains('user not found')) {
          msg = 'User not registered';
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
        if (success && isLogin) {
          // Save session for downstream API calls
          UserSession.setFromResponse(res);
          if ((UserSession.studentId ?? '').isEmpty) {
            UserSession.studentId = studentId;
          }
          final role = (res['role'] ?? '').toString().toLowerCase();
          final Widget next = role == 'admin'
              ? const AdminHomeScreen()
              : const SocieTreeDashboard();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => next),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Network error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _showTermsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
          title: const Text('SocieTree Terms & Conditions'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('By using the SocieTree platform, you agree to:'),
                SizedBox(height: 8),
                Text('• Use your own account and keep your credentials confidential.'),
                Text('• Provide accurate information in your profile and submissions.'),
                Text('• Allow SocieTree to process and store your submitted data to deliver app features and improve the service.'),
                Text('• Use the platform responsibly (no abuse, harassment, or attempts to disrupt the service).'),
                Text('• Follow your institution’s policies and applicable laws.'),
                SizedBox(height: 12),
                Text('Privacy & Data:'),
                Text('SocieTree stores necessary data (e.g., account info and activity you submit) in order to operate. Your data is handled with care and used only for platform functionality and improvements.'),
                SizedBox(height: 12),
                Text('Changes:'),
                Text('These Terms may be updated from time to time. Continued use of SocieTree signifies acceptance of the latest version.'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CLOSE')),
            ElevatedButton(
              onPressed: () {
                setState(() => _acceptTerms = true);
                Navigator.pop(ctx);
              },
              child: const Text('I ACCEPT'),
            ),
          ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color.fromARGB(115, 89, 98, 105), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.asset(
                                'assets/images/Icon-NOBG.png',
                                height: 80,
                                width: 80,
                                fit: BoxFit.contain,
                                errorBuilder: (c, e, s) => const Icon(Icons.park, size: 72, color: Colors.green),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'WELCOME',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) => (v == null || v.isEmpty) ? 'Enter your student ID' : null,
                        decoration: InputDecoration(
                          hintText: 'STUDENT ID',
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Color.fromARGB(197, 76, 79, 82)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscure,
                        validator: (v) => (v == null || v.length < 6) ? 'Min 6 characters' : null,
                        decoration: InputDecoration(
                          hintText: 'PASSWORD',
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Color.fromARGB(153, 132, 150, 165)),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          suffixIcon: IconButton(
                            onPressed: _loading
                                ? null
                                : () {
                                    setState(() {
                                      _obscure = !_obscure;
                                    });
                                  },
                            icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _loading ? null : () => _handleAuth(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8BC34A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                            textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          ),
                          child: _loading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)))
                              : const Text('LOGIN'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          runSpacing: 0,
                          alignment: WrapAlignment.center,
                          children: [
                            SizedBox(
                              height: 20,
                              width: 20,
                              child: Checkbox(
                                value: _acceptTerms,
                                onChanged: _loading ? null : (v) => setState(() => _acceptTerms = v ?? false),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                            Text('I accept the', style: Theme.of(context).textTheme.bodySmall),
                            TextButton(
                              onPressed: _loading ? null : _showTermsDialog,
                              style: TextButton.styleFrom(padding: EdgeInsets.zero),
                              child: const Text('Terms & Conditions'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _loading ? null : _forgotPassword,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero),
                          child: Text(
                            'FORGOT PASSWORD?',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6A6FCF), fontWeight: FontWeight.w600),
                          ),
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
    );
  }
}

// Admin home screen moved to admin_home_screen.dart
