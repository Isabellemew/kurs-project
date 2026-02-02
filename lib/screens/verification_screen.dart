import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

class VerificationScreen extends StatefulWidget {
  final String email;
  final VoidCallback onVerified;

  const VerificationScreen({
    super.key,
    required this.email,
    required this.onVerified,
  });

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _timerSeconds = 59;
  Timer? _timer;
  bool _isLoading = false;
  Timer? _verificationCheckTimer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
    // Начинаем периодическую проверку статуса подтверждения
    _verificationCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _checkEmailVerified();
    });
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        _verificationCheckTimer?.cancel();
        widget.onVerified();
      }
    }
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _timerSeconds = 59);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _verificationCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _resendEmail() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();
      _startResendTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ссылка отправлена повторно!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Подтверждение')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mark_email_read_outlined, size: 100, color: AppColors.primaryYellow),
              const SizedBox(height: 32),
              const Text(
                'Проверьте почту',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'Мы отправили ссылку для подтверждения на\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 40),
              
              const CircularProgressIndicator(color: AppColors.primaryPink),
              const SizedBox(height: 24),
              const Text(
                'Ожидание подтверждения...',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
              
              const SizedBox(height: 60),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _checkEmailVerified,
                  child: const Text('Я подтвердил почту'),
                ),
              ),
              
              const SizedBox(height: 24),
              
              TextButton(
                onPressed: (_timerSeconds == 0 && !_isLoading) ? _resendEmail : null,
                child: Text(
                  _timerSeconds > 0 
                    ? 'Отправить ссылку повторно через $_timerSeconds сек'
                    : 'Отправить ссылку повторно',
                  style: TextStyle(
                    color: (_timerSeconds > 0 || _isLoading) ? Colors.grey : AppColors.primaryPink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
