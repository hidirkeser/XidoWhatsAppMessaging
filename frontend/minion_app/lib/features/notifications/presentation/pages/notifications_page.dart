import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<dynamic> _notifications = [];
  bool _loading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final responses = await Future.wait([
        sl<ApiClient>().dio.get(ApiEndpoints.notifications),
        sl<ApiClient>().dio.get(ApiEndpoints.notificationsUnreadCount),
      ]);
      setState(() {
        _notifications = responses[0].data['items'] as List;
        _unreadCount = responses[1].data['count'] as int;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  Future<void> _markAllRead() async {
    try {
      await sl<ApiClient>().dio.post('/notifications/mark-all-read');
      _loadNotifications();
    } catch (_) {}
  }

  Future<void> _markRead(String id) async {
    try {
      await sl<ApiClient>().dio.patch('/notifications/$id/read');
      _loadNotifications();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;

    return Column(
      children: [
        // Header row with unread count + mark all
        if (_unreadCount > 0)
          Container(
            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.mark_email_read_outlined,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  '$_unreadCount ${s.notifications}',
                  style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _markAllRead,
                  child: Text(s.markAllRead,
                      style: const TextStyle(fontSize: 13)),
                ),
              ],
            ),
          ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _notifications.isEmpty
                  ? _buildEmpty(s)
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        itemCount: _notifications.length,
                        itemBuilder: (context, i) =>
                            _buildTile(_notifications[i]),
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _buildEmpty(AppL10n s) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(s.noNotifications,
              style: TextStyle(fontSize: 16, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildTile(dynamic n) {
    final isRead = n['isRead'] as bool? ?? false;
    final type = n['type'] as String? ?? '';
    final referenceId = n['referenceId'] as String?;

    return Container(
      color: isRead ? null : Colors.blue.withOpacity(0.04),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _typeColor(type).withOpacity(0.15),
          child: Icon(_typeIcon(type), color: _typeColor(type), size: 20),
        ),
        title: Text(
          n['title'] ?? '',
          style: TextStyle(
              fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(n['body'] ?? '',
                maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(_formatTime(n['createdAt']),
                style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        trailing: isRead
            ? null
            : Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                    color: Colors.blue, shape: BoxShape.circle),
              ),
        isThreeLine: true,
        onTap: () {
          if (!isRead) _markRead(n['id']);
          if (referenceId != null && type.contains('Delegation')) {
            context.push('/delegations/$referenceId');
          }
        },
      ),
    );
  }

  Color _typeColor(String t) {
    if (t.contains('Accepted')) return Colors.green;
    if (t.contains('Rejected')) return Colors.red;
    if (t.contains('Revoked')) return Colors.orange;
    if (t.contains('Expired') || t.contains('Expiring')) return Colors.amber;
    if (t.contains('Credit') || t.contains('LowCredit')) return Colors.purple;
    return Colors.blue;
  }

  IconData _typeIcon(String t) {
    if (t.contains('Granted')) return Icons.assignment_add;
    if (t.contains('Accepted')) return Icons.check_circle;
    if (t.contains('Rejected')) return Icons.cancel;
    if (t.contains('Revoked')) return Icons.block;
    if (t.contains('Expired') || t.contains('Expiring')) return Icons.timer_off;
    if (t.contains('CreditPurchase')) return Icons.shopping_cart;
    if (t.contains('LowCredit')) return Icons.warning;
    return Icons.notifications;
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${date.day}.${date.month}.${date.year}';
  }
}
