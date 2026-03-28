import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/delegation_status_badge.dart';

class DelegationDetailPage extends StatefulWidget {
  final String delegationId;

  const DelegationDetailPage({super.key, required this.delegationId});

  @override
  State<DelegationDetailPage> createState() => _DelegationDetailPageState();
}

class _DelegationDetailPageState extends State<DelegationDetailPage> {
  Map<String, dynamic>? _delegation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDelegation();
  }

  Future<void> _loadDelegation() async {
    try {
      final response = await sl<ApiClient>().dio.get(ApiEndpoints.delegationById(widget.delegationId));
      setState(() {
        _delegation = response.data;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_delegation == null) return const Center(child: Text('Delegation not found'));

    final s = AppL10n.of(context)!;
    final d = _delegation!;
    final status = d['status'] as String? ?? '';

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.status, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          DelegationStatusBadge(status: status),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(s.credits, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${d['creditsDeducted']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Parties
            _buildInfoCard(s.grantor, d['grantorName'] ?? '', Icons.person),
            _buildInfoCard(s.delegatePerson, d['delegateName'] ?? '', Icons.person_outline),
            _buildInfoCard(s.organization, d['organizationName'] ?? '', Icons.business),

            // Duration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(s.validityPeriod, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          Text('${_formatDateTime(d['validFrom'])} - ${_formatDateTime(d['validTo'])}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Operations
            const SizedBox(height: 8),
            Text(s.operationTypes, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...(d['operations'] as List? ?? []).map((op) => Card(
              child: ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green[400]),
                title: Text(op['operationName'] ?? ''),
              ),
            )),

            // Notes
            if (d['notes'] != null && (d['notes'] as String).isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.note, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(d['notes']),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Action buttons
            if (status.toLowerCase() == 'pendingapproval') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _action('accept', s.delegationAccepted),
                      icon: const Icon(Icons.check),
                      label: Text(s.accept),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _action('reject', s.delegationRejected),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: Text(s.reject, style: const TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ],
            if (status.toLowerCase() == 'active') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _action('revoke', s.delegationRevoked),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                  label: Text(s.revokeDelegation, style: const TextStyle(color: Colors.red)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _action(String action, String successMessage) async {
    try {
      await sl<ApiClient>().dio.post(
        '/delegations/${widget.delegationId}/$action',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final s = AppL10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.errorOccurred(e.toString())), backgroundColor: Colors.red),
        );
      }
    }
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(value,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String? dateStr) {
    if (dateStr == null) return '-';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return '-';
    return '${date.day}.${date.month}.${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
