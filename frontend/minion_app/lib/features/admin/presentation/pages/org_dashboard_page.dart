import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';

class OrgDashboardPage extends StatefulWidget {
  final String orgId;
  const OrgDashboardPage({super.key, required this.orgId});

  @override
  State<OrgDashboardPage> createState() => _OrgDashboardPageState();
}

class _OrgDashboardPageState extends State<OrgDashboardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // Org info
  Map<String, dynamic>? _org;

  // Analytics
  Map<String, dynamic>? _analytics;
  bool _analyticsLoading = true;

  // Date range
  String _granularity = 'daily';
  DateTime _dateFrom = DateTime.now().subtract(const Duration(days: 30));
  DateTime _dateTo   = DateTime.now();

  // Callback URL editing
  final _callbackC = TextEditingController();
  bool _savingCallback = false;

  // Credit transactions
  List<dynamic> _credits = [];
  bool _creditsLoading = true;

  // Payment transactions
  List<dynamic> _payments = [];
  bool _paymentsLoading = true;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 5, vsync: this);
    _tabCtrl.addListener(() {
      if (!_tabCtrl.indexIsChanging) _onTabChange(_tabCtrl.index);
    });
    _loadOrg();
    _loadAnalytics();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _callbackC.dispose();
    super.dispose();
  }

  Future<void> _loadOrg() async {
    try {
      final res = await sl<ApiClient>().dio.get(
          ApiEndpoints.organizationById(widget.orgId));
      setState(() {
        _org = res.data as Map<String, dynamic>;
        _callbackC.text = _org!['callbackUrl'] ?? '';
      });
    } catch (_) {}
  }

  Future<void> _loadAnalytics() async {
    setState(() => _analyticsLoading = true);
    try {
      final fmt = DateFormat('yyyy-MM-dd');
      final res = await sl<ApiClient>().dio.get(
        ApiEndpoints.adminOrgAnalytics,
        queryParameters: {
          'orgId':       widget.orgId,
          'dateFrom':    fmt.format(_dateFrom),
          'dateTo':      fmt.format(_dateTo),
          'granularity': _granularity,
        },
      );
      setState(() { _analytics = res.data as Map<String, dynamic>; _analyticsLoading = false; });
    } catch (_) {
      setState(() => _analyticsLoading = false);
    }
  }

  Future<void> _loadCredits() async {
    if (!_creditsLoading && _credits.isNotEmpty) return;
    setState(() => _creditsLoading = true);
    try {
      final res = await sl<ApiClient>().dio.get(
        '/admin/organizations/${widget.orgId}/credit-transactions',
      );
      setState(() { _credits = res.data as List? ?? []; _creditsLoading = false; });
    } catch (_) {
      setState(() => _creditsLoading = false);
    }
  }

  Future<void> _loadPayments() async {
    if (!_paymentsLoading && _payments.isNotEmpty) return;
    setState(() => _paymentsLoading = true);
    try {
      final res = await sl<ApiClient>().dio.get(
        '/admin/organizations/${widget.orgId}/payment-transactions',
      );
      setState(() { _payments = res.data as List? ?? []; _paymentsLoading = false; });
    } catch (_) {
      setState(() => _paymentsLoading = false);
    }
  }

  void _onTabChange(int idx) {
    if (idx == 3) _loadCredits();
    if (idx == 4) _loadPayments();
  }

  Future<void> _saveCallbackUrl() async {
    setState(() => _savingCallback = true);
    try {
      await sl<ApiClient>().dio.put(
        ApiEndpoints.organizationById(widget.orgId),
        data: {'callbackUrl': _callbackC.text.trim()},
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Callback URL kaydedildi.')));
        setState(() => _org = {...?_org, 'callbackUrl': _callbackC.text.trim()});
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarısız.')));
    } finally {
      setState(() => _savingCallback = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final orgName = _org?['name'] as String? ?? 'Firma Detayı';

    return Scaffold(
      appBar: AppBar(
        title: Text(orgName),
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Genel'),
            Tab(icon: Icon(Icons.lock_outline), text: 'Güvenlik'),
            Tab(icon: Icon(Icons.link), text: 'Callback'),
            Tab(icon: Icon(Icons.toll), text: 'Kontör'),
            Tab(icon: Icon(Icons.payment), text: 'Ödeme'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildGeneralTab(theme),
          _buildSecurityTab(),
          _buildCallbackTab(theme),
          _buildCreditsTab(theme),
          _buildPaymentsTab(theme),
        ],
      ),
    );
  }

  // ── TAB 1: Genel ─────────────────────────────────────────────────────────

  Widget _buildGeneralTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date range + granularity controls
          _buildDateRangeBar(theme),
          const SizedBox(height: 16),

          if (_analyticsLoading)
            const Center(child: Padding(
              padding: EdgeInsets.all(48),
              child: CircularProgressIndicator(),
            ))
          else if (_analytics == null)
            const Center(child: Text('Veri yüklenemedi.'))
          else ...[
            // Summary cards
            Row(children: [
              _summaryCard('Delegasyon', '${_analytics!['totalDelegations'] ?? 0}',
                  Icons.assignment_turned_in, Colors.blue, theme),
              const SizedBox(width: 12),
              _summaryCard('Kontör', '${_analytics!['totalCreditsUsed'] ?? 0}',
                  Icons.toll, Colors.purple, theme),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _summaryCard('Gelir (SEK)',
                  '${(_analytics!['totalRevenueSEK'] ?? 0.0).toStringAsFixed(0)}',
                  Icons.attach_money, Colors.green, theme),
              const SizedBox(width: 12),
              _summaryCard('Başvuru', '${_analytics!['totalApplications'] ?? 0}',
                  Icons.folder_open, Colors.orange, theme),
            ]),
            const SizedBox(height: 24),

            // Chart
            if ((_analytics!['chart'] as List? ?? []).isNotEmpty) ...[
              Text('Delegasyon Grafiği',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: _buildBarChart(theme),
              ),
              const SizedBox(height: 24),
            ],

            // Per-org summaries
            if ((_analytics!['orgSummaries'] as List? ?? []).isNotEmpty) ...[
              Text('Firma Bazlı Özet',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...(_analytics!['orgSummaries'] as List).map((o) => Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.business, size: 18)),
                  title: Text(o['orgName'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text('${o['delegations']} delegasyon • ${o['creditsUsed']} kontör'),
                ),
              )),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildDateRangeBar(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Granularity chips
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _granularityChip('Günlük', 'daily'),
              const SizedBox(width: 6),
              _granularityChip('Haftalık', 'weekly'),
              const SizedBox(width: 6),
              _granularityChip('Aylık', 'monthly'),
              const SizedBox(width: 6),
              _granularityChip('Yıllık', 'yearly'),
              const SizedBox(width: 6),
              ActionChip(
                avatar: const Icon(Icons.date_range, size: 16),
                label: const Text('Özel'),
                onPressed: _pickCustomRange,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${DateFormat('dd.MM.yyyy').format(_dateFrom)} – ${DateFormat('dd.MM.yyyy').format(_dateTo)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _granularityChip(String label, String value) {
    final presets = <String, int>{'daily': 30, 'weekly': 90, 'monthly': 365, 'yearly': 1825};
    return FilterChip(
      selected: _granularity == value,
      label: Text(label),
      onSelected: (_) {
        final days = presets[value] ?? 30;
        setState(() {
          _granularity = value;
          _dateFrom = DateTime.now().subtract(Duration(days: days));
          _dateTo   = DateTime.now();
        });
        _loadAnalytics();
      },
    );
  }

  Future<void> _pickCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: _dateFrom, end: _dateTo),
    );
    if (range != null) {
      setState(() { _dateFrom = range.start; _dateTo = range.end; });
      _loadAnalytics();
    }
  }

  Widget _summaryCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(ThemeData theme) {
    final chartData = (_analytics!['chart'] as List).cast<Map<String, dynamic>>();
    if (chartData.isEmpty) return const SizedBox.shrink();

    final maxY = chartData.map((p) => (p['delegations'] as int? ?? 0).toDouble()).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxY > 0 ? maxY + 2 : 5,
        barGroups: chartData.asMap().entries.map((e) {
          final count = (e.value['delegations'] as int? ?? 0).toDouble();
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: count,
                color: theme.colorScheme.primary,
                width: chartData.length > 20 ? 6 : 14,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (chartData.length / 6).ceilToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= chartData.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(chartData[idx]['label'] ?? '', style: const TextStyle(fontSize: 9)),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  // ── TAB 2: Güvenlik ──────────────────────────────────────────────────────

  Widget _buildSecurityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.key, color: Colors.indigo),
              title: const Text('API Anahtarları'),
              subtitle: const Text('M2M entegrasyonu için token/secret üretimi'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/organizations/${widget.orgId}/api-keys'),
            ),
          ),
          if (_org != null) ...[
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Kurum Bilgileri',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Divider(height: 20),
                    _infoRow('Adı', _org!['name'] ?? '-'),
                    _infoRow('Sicil No', _org!['orgNumber'] ?? '-'),
                    _infoRow('E-posta', _org!['contactEmail'] ?? '-'),
                    _infoRow('Telefon', _org!['contactPhone'] ?? '-'),
                    _infoRow('Durum', (_org!['isActive'] as bool? ?? false) ? 'Aktif' : 'Pasif'),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── TAB 3: Callback URL ──────────────────────────────────────────────────

  Widget _buildCallbackTab(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: theme.colorScheme.primaryContainer.withOpacity(0.3),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary, size: 20),
                const SizedBox(width: 10),
                const Expanded(child: Text(
                  'Bir delegasyon kabul edildiğinde belirtilen URL\'ye POST isteği gönderilir.',
                  style: TextStyle(fontSize: 13),
                )),
              ]),
            ),
          ),
          const SizedBox(height: 20),
          Text('Callback URL', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _callbackC,
            decoration: InputDecoration(
              hintText: 'https://example.com/webhook',
              prefixIcon: const Icon(Icons.link),
              border: const OutlineInputBorder(),
              helperText: 'Boş bırakırsanız webhook devre dışı kalır.',
            ),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _savingCallback ? null : _saveCallbackUrl,
              icon: _savingCallback
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: const Text('Kaydet'),
            ),
          ),
          const SizedBox(height: 24),
          Text('Webhook Payload Örneği',
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: SelectableText(
              '{\n'
              '  "event": "delegation.accepted",\n'
              '  "organizationId": "...",\n'
              '  "delegationId": "...",\n'
              '  "verificationCode": "ABC123",\n'
              '  "timestamp": "2025-01-01T12:00:00Z"\n'
              '}',
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 4: Kontör ────────────────────────────────────────────────────────

  Widget _buildCreditsTab(ThemeData theme) {
    if (_creditsLoading && _credits.isEmpty) {
      _loadCredits();
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async { setState(() => _creditsLoading = true); await _loadCredits(); },
      child: _credits.isEmpty
          ? const Center(child: Text('Kontör işlemi bulunamadı.'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _credits.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final tx = _credits[i];
                final amount = tx['amount'] as int? ?? 0;
                final isCredit = amount > 0;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
                    child: Icon(
                      isCredit ? Icons.add_circle_outline : Icons.remove_circle_outline,
                      color: isCredit ? Colors.green : Colors.red,
                      size: 20,
                    ),
                  ),
                  title: Text(tx['description'] ?? (isCredit ? 'Yükleme' : 'Kullanım'),
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(_fmtDate(tx['createdAt'])),
                  trailing: Text(
                    '${isCredit ? '+' : ''}$amount',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isCredit ? Colors.green : Colors.red,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
    );
  }

  // ── TAB 5: Ödeme ─────────────────────────────────────────────────────────

  Widget _buildPaymentsTab(ThemeData theme) {
    if (_paymentsLoading && _payments.isEmpty) {
      _loadPayments();
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async { setState(() => _paymentsLoading = true); await _loadPayments(); },
      child: _payments.isEmpty
          ? const Center(child: Text('Ödeme işlemi bulunamadı.'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _payments.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final tx = _payments[i];
                final status = tx['status'] as String? ?? '';
                final amount = (tx['amountSEK'] as num? ?? 0).toStringAsFixed(2);
                final statusColor = status == 'Completed' ? Colors.green
                    : status == 'Failed' ? Colors.red : Colors.orange;
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.1),
                    child: Icon(Icons.receipt, color: statusColor, size: 20),
                  ),
                  title: Text('${tx['creditAmount'] ?? 0} kontör – $amount SEK',
                      style: const TextStyle(fontWeight: FontWeight.w500)),
                  subtitle: Text(_fmtDate(tx['completedAt'] ?? tx['createdAt'])),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(status,
                        style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600)),
                  ),
                );
              },
            ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );

  String _fmtDate(String? d) {
    if (d == null) return '-';
    final dt = DateTime.tryParse(d);
    if (dt == null) return d;
    return DateFormat('dd.MM.yyyy HH:mm').format(dt.toLocal());
  }
}
