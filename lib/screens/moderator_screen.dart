import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../services/auth_service.dart';

class ModeratorScreen extends StatefulWidget {
  const ModeratorScreen({super.key});

  @override
  State<ModeratorScreen> createState() => _ModeratorScreenState();
}

class _ModeratorScreenState extends State<ModeratorScreen> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Панель модератора'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                _authService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'На проверке', icon: Icon(Icons.pending_actions)),
              Tab(text: 'Все анкеты', icon: Icon(Icons.list_alt)),
            ],
            indicatorColor: AppColors.primaryPink,
            labelColor: AppColors.primaryPink,
            unselectedLabelColor: Colors.grey,
          ),
        ),
        body: TabBarView(
          children: [
            _buildAnketaList(isPendingOnly: true),
            _buildAnketaList(isPendingOnly: false),
          ],
        ),
      ),
    );
  }

  Widget _buildAnketaList({required bool isPendingOnly}) {
    return StreamBuilder<List<TutorAnketa>>(
      stream: isPendingOnly ? _authService.getPendingAnketas() : _authService.getAllAnketas(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Ошибка: ${snapshot.error}'));
        }
        
        final anketas = snapshot.data ?? [];

        if (anketas.isEmpty) {
          return Center(child: Text(isPendingOnly ? 'Нет анкет на проверку' : 'Список анкет пуст'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: anketas.length,
          itemBuilder: (context, index) {
            final anketa = anketas[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
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
                border: Border.all(
                  color: anketa.status == 'approved' 
                      ? Colors.green.withOpacity(0.3) 
                      : (anketa.status == 'pending' ? AppColors.primaryYellow.withOpacity(0.5) : Colors.orange.withOpacity(0.3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          anketa.tutorName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      _buildStatusBadge(anketa.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Предметы: ${anketa.subjects.join(", ")}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  Text(
                    'Опыт: ${anketa.experience}',
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (anketa.status == 'pending') ...[
                        _buildActionButton(
                          icon: Icons.check_circle,
                          color: Colors.green,
                          label: 'Одобрить',
                          onTap: () async {
                            await _authService.approveAnketa(anketa.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Анкета одобрена')));
                            }
                          },
                        ),
                        _buildActionButton(
                          icon: Icons.edit,
                          color: Colors.orange,
                          label: 'Правки',
                          onTap: () async {
                            await _authService.sendForRevision(anketa.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Отправлено на доработку')));
                            }
                          },
                        ),
                      ],
                      _buildActionButton(
                        icon: Icons.delete,
                        color: Colors.red,
                        label: 'Удалить',
                        onTap: () async {
                          final confirm = await _showDeleteDialog(anketa.tutorName);
                          if (confirm == true) {
                            await _authService.deleteAnketa(anketa.id);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Анкета удалена')));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = Colors.green;
        label = 'Одобрена';
        break;
      case 'pending':
        color = AppColors.primaryYellow;
        label = 'Новая';
        break;
      default:
        color = Colors.orange;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Future<bool?> _showDeleteDialog(String name) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удаление анкеты'),
        content: Text('Вы уверены, что хотите удалить анкету репетитора $name?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Отмена')),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text('Удалить', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required IconData icon, required Color color, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
