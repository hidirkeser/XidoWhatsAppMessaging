import 'package:flutter/material.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';

class CreditHistoryPage extends StatefulWidget {
  const CreditHistoryPage({super.key});

  @override
  State<CreditHistoryPage> createState() => _CreditHistoryPageState();
}

class _CreditHistoryPageState extends State<CreditHistoryPage> {
  List<dynamic> _transactions = [];
  bool _loading = true;
  int _balance = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        sl<ApiClient>().dio.get(ApiEndpoints.creditsHistory),
        sl<ApiClient>().dio.get(ApiEndpoints.creditsBalance),
      ]);
      setState(() {
        _transactions = results[0].data['items'] as List? ?? [];
        _balance = results[1].data['balance'] as int? ?? 0;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(s.creditHistory)),
      body: Column(
        children: [
          // Balance banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            color: cs.primaryContainer,
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet, color: cs.primary, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.currentBalance,
                        style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer.withValues(alpha: 0.7))),
                    Text('$_balance ${s.credits}',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: cs.primary)),
                  ],
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? Center(child: Text(s.noTransactions, style: TextStyle(color: Colors.grey[500])))
                    : RefreshIndicator(
                        onRefresh: _load,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _transactions.length,
                          separatorBuilder: (context, i) => const Divider(height: 1, indent: 72),
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            return _TransactionTile(tx: tx);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TransactionTile({required this.tx});

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final type = tx['transactionType'] as String? ?? '';
    final amount = tx['amount'] as int? ?? 0;
    final balance = tx['balanceAfter'] as int? ?? 0;
    final date = _formatDate(tx['createdAt']);

    final isDebit = amount < 0;
    final amountColor = isDebit ? Colors.red.shade600 : Colors.green.shade600;
    final amountStr = isDebit ? '$amount' : '+$amount';

    IconData icon;
    String label;
    switch (type) {
      case 'Purchase':
        icon = Icons.add_card;
        label = s.txPurchase;
        break;
      case 'Deduction':
        icon = Icons.assignment_turned_in_outlined;
        label = s.txDelegationDeduction;
        break;
      case 'Refund':
        icon = Icons.replay;
        label = s.txRefund;
        break;
      case 'ManualAdjustment':
        icon = Icons.admin_panel_settings_outlined;
        label = s.txManualAdjustment;
        break;
      default:
        icon = Icons.swap_horiz;
        label = type;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isDebit ? Colors.red.shade50 : Colors.green.shade50,
        child: Icon(icon, color: isDebit ? Colors.red.shade400 : Colors.green.shade600, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amountStr,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: amountColor)),
          Text('${s.balance}: $balance',
              style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    final d = DateTime.tryParse(dateStr);
    if (d == null) return '-';
    return '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}  ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
  }
}
