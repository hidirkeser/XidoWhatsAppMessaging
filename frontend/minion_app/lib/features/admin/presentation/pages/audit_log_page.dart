import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';

class AuditLogPage extends StatefulWidget {
  const AuditLogPage({super.key});

  @override
  State<AuditLogPage> createState() => _AuditLogPageState();
}

class _AuditLogPageState extends State<AuditLogPage> {
  List<dynamic> _logs = [];
  bool _loading = true;
  String? _actionFilter;
  int _page = 1;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    try {
      var url = '/admin/audit-logs?page=$_page&pageSize=30';
      if (_actionFilter != null) url += '&action=$_actionFilter';
      final response = await sl<ApiClient>().dio.get(url);
      setState(() {
        _logs = response.data['items'] as List;
        _totalPages = response.data['totalPages'] as int;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    return Scaffold(
      body: Column(
        children: [
          // Action filter
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _chip('All', null),
                _chip('Login', 'Login'),
                _chip(s.grantDelegation, 'Grant'),
                _chip(s.accept, 'Accept'),
                _chip(s.reject, 'Reject'),
                _chip(s.revokeDelegation, 'Revoke'),
                _chip(s.credits, 'CreditPurchase'),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _logs.isEmpty
                    ? Center(child: Text(s.noTransactionsYet, style: TextStyle(color: Colors.grey[500])))
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) => _buildLogTile(_logs[index]),
                      ),
          ),
          // Pagination
          if (_totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _page > 1 ? () { _page--; _loadLogs(); } : null,
                  ),
                  Text('$_page / $_totalPages'),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _page < _totalPages ? () { _page++; _loadLogs(); } : null,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _chip(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 12)),
        selected: _actionFilter == value,
        onSelected: (_) {
          _actionFilter = value;
          _page = 1;
          _loadLogs();
        },
        selectedColor: Theme.of(context).colorScheme.primary,
        labelStyle: TextStyle(color: _actionFilter == value ? Colors.white : null),
      ),
    );
  }

  Widget _buildLogTile(dynamic log) {
    final action = log['action'] as String? ?? '';
    return ListTile(
      dense: true,
      leading: CircleAvatar(
        radius: 16,
        backgroundColor: _actionColor(action).withValues(alpha: 0.15),
        child: Icon(_actionIcon(action), size: 16, color: _actionColor(action)),
      ),
      title: Text('${log['actorName'] ?? 'System'} — $action',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      subtitle: Text(
        '${log['organizationName'] ?? ''} ${_formatTime(log['timestamp'])}',
        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
      ),
      trailing: log['ipAddress'] != null
          ? Text(log['ipAddress'], style: TextStyle(fontSize: 10, color: Colors.grey[400]))
          : null,
    );
  }

  Color _actionColor(String action) {
    if (action.contains('Login')) return Colors.blue;
    if (action.contains('Grant')) return Colors.green;
    if (action.contains('Accept')) return Colors.teal;
    if (action.contains('Reject')) return Colors.red;
    if (action.contains('Revoke')) return Colors.orange;
    if (action.contains('Credit')) return Colors.purple;
    if (action.contains('Expire')) return Colors.grey;
    return Colors.blueGrey;
  }

  IconData _actionIcon(String action) {
    if (action.contains('Login')) return Icons.login;
    if (action.contains('Grant')) return Icons.add_circle;
    if (action.contains('Accept')) return Icons.check;
    if (action.contains('Reject')) return Icons.close;
    if (action.contains('Revoke')) return Icons.block;
    if (action.contains('Credit')) return Icons.monetization_on;
    if (action.contains('Expire')) return Icons.timer_off;
    return Icons.info;
  }

  String _formatTime(String? dateStr) {
    if (dateStr == null) return '';
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '';
    return '${d.day}.${d.month}.${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
