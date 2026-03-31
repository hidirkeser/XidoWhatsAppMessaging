import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../l10n/generated/app_localizations.dart';

class ManageCorporateApplicationsPage extends StatefulWidget {
  const ManageCorporateApplicationsPage({super.key});

  @override
  State<ManageCorporateApplicationsPage> createState() => _ManageCorporateApplicationsPageState();
}

class _ManageCorporateApplicationsPageState extends State<ManageCorporateApplicationsPage> {
  List<dynamic> _applications = [];
  bool _loading = true;
  String _filter = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final query = _filter.isNotEmpty ? '?status=$_filter' : '';
      final response = await sl<ApiClient>().dio.get('${ApiEndpoints.adminCorporateApplications}$query');
      final data = response.data;
      setState(() {
        _applications = data['items'] as List? ?? [];
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip(s.all, ''),
                  const SizedBox(width: 8),
                  _filterChip(s.pending, 'Pending'),
                  const SizedBox(width: 8),
                  _filterChip(s.approved, 'Approved'),
                  const SizedBox(width: 8),
                  _filterChip(s.rejected, 'Rejected'),
                ],
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _applications.isEmpty
                    ? Center(child: Text(s.noApplications))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemCount: _applications.length,
                          itemBuilder: (context, i) => _buildApplicationCard(_applications[i]),
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    return FilterChip(
      selected: _filter == value,
      label: Text(label),
      onSelected: (_) {
        setState(() { _filter = value; _loading = true; });
        _load();
      },
    );
  }

  Widget _buildApplicationCard(dynamic app) {
    final s = AppL10n.of(context)!;
    final status = app['status'] as String? ?? 'Pending';

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'Approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'Rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(app['companyName'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${app['orgNumber']} | ${app['contactName']}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(Icons.email, app['contactEmail'] ?? ''),
                if (app['contactPhone'] != null) _infoRow(Icons.phone, app['contactPhone']),
                _infoRow(Icons.calendar_today, 'Submitted: ${_formatDate(app['createdAt'])}'),
                if (app['reviewNote'] != null) ...[
                  const Divider(),
                  _infoRow(Icons.note, '${s.reviewNote}: ${app['reviewNote']}'),
                ],
                if (status == 'Pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                          onPressed: () => _reviewApplication(app['id'], false),
                          icon: const Icon(Icons.close),
                          label: Text(s.reject),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(backgroundColor: Colors.green),
                          onPressed: () => _reviewApplication(app['id'], true),
                          icon: const Icon(Icons.check),
                          label: Text(s.approve),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    final date = DateTime.tryParse(dateStr);
    if (date == null) return dateStr;
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Future<void> _reviewApplication(String id, bool approve) async {
    final s = AppL10n.of(context)!;
    final noteC = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(approve ? s.approveApplication : s.rejectApplication),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(approve ? s.approveConfirmMessage : s.rejectConfirmMessage),
            const SizedBox(height: 16),
            TextField(
              controller: noteC,
              decoration: InputDecoration(labelText: s.reviewNote, hintText: s.optional),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(s.cancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: approve ? Colors.green : Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(approve ? s.approve : s.reject),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final endpoint = approve
          ? ApiEndpoints.adminCorporateApprove(id)
          : ApiEndpoints.adminCorporateReject(id);

      await sl<ApiClient>().dio.post(endpoint, data: {
        'reviewNote': noteC.text.isNotEmpty ? noteC.text : null,
      });
      _load();
    }
  }
}
