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

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final response =
          await sl<ApiClient>().dio.get(ApiEndpoints.creditsHistory);
      setState(() {
        _transactions = response.data['items'] as List;
        _loading = false;
      });
    } catch (_) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;

    if (_loading) return const Center(child: CircularProgressIndicator());

    if (_transactions.isEmpty) {
      return Center(
        child: Text(s.noTransactionsYet,
            style: TextStyle(color: Colors.grey[500])),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final tx = _transactions[index];
        final amount = tx['amount'] as int;
        final isPositive = amount > 0;
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isPositive
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            child: Icon(
              isPositive ? Icons.add : Icons.remove,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
          title: Text(tx['description'] ?? tx['transactionType']),
          subtitle:
              Text(tx['createdAt'].toString().substring(0, 16)),
          trailing: Text(
            '${isPositive ? '+' : ''}$amount',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        );
      },
    );
  }
}
