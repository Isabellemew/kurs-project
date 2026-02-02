import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = false;
  bool soundEnabled = false;
  bool systemNotificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _buildSettingRow(
                'Уведомления',
                notificationsEnabled,
                (value) => setState(() => notificationsEnabled = value),
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                'Звук',
                soundEnabled,
                (value) => setState(() => soundEnabled = value),
              ),
              const SizedBox(height: 16),
              _buildSettingRow(
                'Системные уведомления',
                systemNotificationsEnabled,
                (value) => setState(() => systemNotificationsEnabled = value),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Выйти из аккаунта'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingRow(String title, bool value, Function(bool) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primaryPink,
          ),
        ],
      ),
    );
  }
}
