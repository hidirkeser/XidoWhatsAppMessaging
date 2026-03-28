import 'package:flutter/material.dart';
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
        onPressed: () => context.push('/delegations/create'),
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
                _buildList(_received, _loadingReceived,
                    emptyText: s.noReceivedDelegations),
              ],
            ),
          ),
        ],
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
              onTap: () => context.push('/delegations/${item['id']}'),
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
