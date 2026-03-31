import 'package:flutter/material.dart';
import '../../../../core/widgets/app_dialog.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../widgets/delegation_status_badge.dart';

class DelegationsPage extends StatefulWidget {
  const DelegationsPage({super.key});

  @override
  State<DelegationsPage> createState() => _DelegationsPageState();
}

class _DelegationsPageState extends State<DelegationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _granted = [];
  List<dynamic> _received = [];
  bool _loadingGranted = true;
  bool _loadingReceived = true;
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    _loadGranted();
    _loadReceived();
  }

  Future<void> _loadGranted() async {
    setState(() => _loadingGranted = true);
    try {
      var url = ApiEndpoints.delegationsGranted;
      if (_statusFilter != null) url += '?status=$_statusFilter';
      final response = await sl<ApiClient>().dio.get(url);
      setState(() {
        _granted = response.data['items'] as List;
        _loadingGranted = false;
      });
    } catch (_) {
      setState(() => _loadingGranted = false);
    }
  }

  Future<void> _loadReceived() async {
    setState(() => _loadingReceived = true);
    try {
      var url = ApiEndpoints.delegationsReceived;
      if (_statusFilter != null) url += '?status=$_statusFilter';
      final response = await sl<ApiClient>().dio.get(url);
      setState(() {
        _received = response.data['items'] as List;
        _loadingReceived = false;
      });
    } catch (_) {
      setState(() => _loadingReceived = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;

    return Scaffold(
      // Shell provides the top AppBar; this Scaffold is only for the FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await context.push<bool>('/delegations/create');
          if (result == true && mounted) _loadData();
        },
        icon: const Icon(Icons.add),
        label: Text(s.grantDelegation),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: s.grantedDelegations(_granted.length)),
                Tab(text: s.receivedDelegations(_received.length)),
              ],
            ),
          ),
          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _filterChip(s.all, null),
                _filterChip(s.active, 'Active'),
                _filterChip(s.pending, 'PendingApproval'),
                _filterChip(s.rejected, 'Rejected'),
                _filterChip(s.revoked, 'Revoked'),
                _filterChip(s.expired, 'Expired'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildList(_granted, _loadingGranted,
                    emptyText: s.noGrantedDelegations),
                _buildReceivedTab(s),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Received tab: pending banner + full list ────────────────────────────────
  Widget _buildReceivedTab(AppL10n s) {
    if (_loadingReceived) return const Center(child: CircularProgressIndicator());

    final pending = _received
        .where((d) => (d['status'] as String? ?? '') == 'PendingApproval')
        .toList();

    if (_received.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(s.noReceivedDelegations,
                style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // ── Pending approval banner ──────────────────────────────────────
          if (pending.isNotEmpty) ...[
            _buildPendingBanner(pending, s),
            const SizedBox(height: 16),
          ],

          // ── All received delegations ─────────────────────────────────────
          ..._received.map((item) => _buildReceivedCard(item)),
        ],
      ),
    );
  }

  Widget _buildPendingBanner(List<dynamic> pending, AppL10n s) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cs.primary.withValues(alpha: 0.12), cs.secondary.withValues(alpha: 0.08)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${pending.length}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  pending.length == 1
                      ? 'Onay bekleyen 1 yetki talebiniz var'
                      : 'Onay bekleyen ${pending.length} yetki talebiniz var',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: cs.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...pending.map((item) => _buildPendingItem(item, cs)),
        ],
      ),
    );
  }

  Widget _buildPendingItem(dynamic item, ColorScheme cs) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        onTap: () async {
              final result = await context.push<bool>('/delegations/${item['id']}');
              if (result == true && mounted) _loadData();
            },
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: cs.primaryContainer,
          radius: 20,
          child: Text(
            (item['counterpartyName'] as String? ?? '?')[0].toUpperCase(),
            style: TextStyle(color: cs.primary, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          item['counterpartyName'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          item['organizationName'] ?? '',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _quickActionBtn(
              icon: Icons.check,
              color: Colors.green,
              onTap: () => _quickAction(item['id'], 'accept'),
            ),
            const SizedBox(width: 6),
            _quickActionBtn(
              icon: Icons.close,
              color: Colors.red,
              onTap: () => _quickAction(item['id'], 'reject'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickActionBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Icon(icon, size: 18, color: color),
      ),
    );
  }

  Future<void> _quickAction(String delegationId, String action) async {
    if (!mounted) return;
    final s = AppL10n.of(context)!;
    final confirmMsg = action == 'accept' ? s.acceptConfirm : s.rejectConfirm;
    final confirmed = await AppDialog.confirm(context, message: confirmMsg);
    if (!confirmed || !mounted) return;

    try {
      await sl<ApiClient>().dio.post('/delegations/$delegationId/$action');
      if (mounted) {
        final msg = action == 'accept' ? s.delegationAccepted : s.delegationRejected;
        await AppDialog.showSuccess(context, msg);
        if (mounted) _loadReceived();
      }
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    }
  }

  Widget _buildReceivedCard(dynamic item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () async {
              final result = await context.push<bool>('/delegations/${item['id']}');
              if (result == true && mounted) _loadData();
            },
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            (item['counterpartyName'] as String? ?? '?')[0].toUpperCase(),
            style: TextStyle(color: Theme.of(context).colorScheme.primary),
          ),
        ),
        title: Text(item['counterpartyName'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item['organizationName'] ?? '',
                style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            Text(
              '${_formatDate(item['validFrom'])} – ${_formatDate(item['validTo'])}',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
          ],
        ),
        trailing: DelegationStatusBadge(status: item['status'] ?? ''),
        isThreeLine: true,
      ),
    );
  }

  Widget _filterChip(String label, String? value) {
    final isSelected = _statusFilter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label,
            style: TextStyle(
                fontSize: 12, color: isSelected ? Colors.white : null)),
        selected: isSelected,
        onSelected: (_) {
          setState(() => _statusFilter = value);
          _loadData();
        },
        selectedColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildList(List<dynamic> items, bool loading,
      {required String emptyText}) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(emptyText,
                style: TextStyle(fontSize: 16, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              onTap: () async {
              final result = await context.push<bool>('/delegations/${item['id']}');
              if (result == true && mounted) _loadData();
            },
              leading: CircleAvatar(
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  (item['counterpartyName'] as String? ?? '?')[0]
                      .toUpperCase(),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary),
                ),
              ),
              title: Text(item['counterpartyName'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['organizationName'] ?? '',
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600])),
                  Text(
                    '${_formatDate(item['validFrom'])} – ${_formatDate(item['validTo'])}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              trailing: DelegationStatusBadge(status: item['status'] ?? ''),
              isThreeLine: true,
            ),
          );
        },
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '-';
    return '${d.day}.${d.month}.${d.year}';
  }
}
