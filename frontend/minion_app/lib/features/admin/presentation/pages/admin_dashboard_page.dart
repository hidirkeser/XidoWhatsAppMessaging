import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final response = await sl<ApiClient>().dio.get('/admin/dashboard');
      setState(() { _stats = response.data; _loading = false; });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats grid
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _buildStatCard(s.totalUsers, '${_stats?['totalUsers'] ?? 0}', Icons.people, Colors.blue),
                        _buildStatCard(s.totalOrganizations, '${_stats?['totalOrganizations'] ?? 0}', Icons.business, Colors.teal),
                        _buildStatCard(s.activeDelegations, '${_stats?['activeDelegations'] ?? 0}', Icons.assignment_turned_in, Colors.green),
                        _buildStatCard(s.pendingCount, '${_stats?['pendingDelegations'] ?? 0}', Icons.pending_actions, Colors.orange),
                        _buildStatCard(s.totalCredits, '${_stats?['totalCreditsSold'] ?? 0}', Icons.monetization_on, Colors.purple),
                        _buildStatCard(s.revenueSEK, '${(_stats?['totalRevenueSEK'] ?? 0).toStringAsFixed(0)}', Icons.attach_money, Colors.indigo),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Admin menu
                    Text(s.adminPanel, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    _buildMenuItem(Icons.business, s.organizationManagement, '/admin/organizations'),
                    _buildMenuItem(Icons.category, s.operationTypeManagement, '/admin/operation-types'),
                    _buildMenuItem(Icons.people, s.users, '/admin/user-orgs'),
                    _buildMenuItem(Icons.shopping_cart, s.creditPackageManagement, '/admin/credit-packages'),
                    _buildMenuItem(Icons.inventory, s.productManagement, '/admin/products'),
                    _buildMenuItem(Icons.business_center, s.corporateApplications, '/admin/corporate-applications'),
                    _buildMenuItem(Icons.domain, 'Firma İşlemleri', '/admin/firms'),
                    _buildMenuItem(Icons.notifications_active_outlined, 'Bildirim Ayarları', '/admin/notification-settings'),
                    _buildMenuItem(Icons.history, s.auditLog, '/admin/audit-logs'),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, String route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(route),
      ),
    );
  }
}
