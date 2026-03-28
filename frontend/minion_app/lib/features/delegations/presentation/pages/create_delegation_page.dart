import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../l10n/generated/app_localizations.dart';

class CreateDelegationPage extends StatefulWidget {
  const CreateDelegationPage({super.key});

  @override
  State<CreateDelegationPage> createState() => _CreateDelegationPageState();
}

class _CreateDelegationPageState extends State<CreateDelegationPage> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? _selectedUser;
  Map<String, dynamic>? _selectedOrg;
  List<dynamic> _organizations = [];
  List<dynamic> _operationTypes = [];
  final Set<String> _selectedOpTypeIds = {};
  String _durationType = 'hours';
  final _durationController = TextEditingController(text: '1');
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _useDateRange = false;
  final _notesController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _searching = false;
  bool _submitting = false;
  int _creditBalance = 0;

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
    _loadBalance();
  }

  Future<void> _loadOrganizations() async {
    try {
      final response = await sl<ApiClient>().dio.get(ApiEndpoints.usersMyOrgs);
      setState(() => _organizations = response.data as List);
    } catch (_) {}
  }

  Future<void> _loadBalance() async {
    try {
      final response = await sl<ApiClient>().dio.get(ApiEndpoints.creditsBalance);
      setState(() => _creditBalance = response.data['balance'] as int);
    } catch (_) {}
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) return;
    setState(() => _searching = true);
    try {
      final response = await sl<ApiClient>().dio.get('${ApiEndpoints.usersSearch}?q=$query');
      setState(() {
        _searchResults = response.data as List;
        _searching = false;
      });
    } catch (_) {
      setState(() => _searching = false);
    }
  }

  Future<void> _loadOperationTypes(String orgId) async {
    try {
      final response = await sl<ApiClient>().dio.get('/organizations/$orgId/operation-types');
      setState(() {
        _operationTypes = (response.data as List).where((ot) => ot['isActive'] == true).toList();
        _selectedOpTypeIds.clear();
      });
    } catch (_) {}
  }

  int get _totalCreditCost {
    return _operationTypes
        .where((ot) => _selectedOpTypeIds.contains(ot['id']))
        .fold(0, (sum, ot) => sum + (ot['creditCost'] as int? ?? 1));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Credit balance
            Card(
              color: _creditBalance < _totalCreditCost
                  ? Colors.red.shade50
                  : Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet),
                    const SizedBox(width: 8),
                    Text('${s.credits}: $_creditBalance',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    if (_totalCreditCost > 0)
                      Text('$_totalCreditCost ${s.credits}',
                          style: TextStyle(color: Colors.grey[700])),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // User search
            _buildSectionTitle(s.personSelection),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: s.searchByPersonnummer,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searching ? const SizedBox(width: 20, height: 20,
                    child: Padding(padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2))) : null,
              ),
              onChanged: _searchUsers,
            ),
            if (_selectedUser != null)
              Card(
                color: Colors.blue.shade50,
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('${_selectedUser!['firstName']} ${_selectedUser!['lastName']}'),
                  subtitle: Text(_selectedUser!['personalNumber'] ?? ''),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => _selectedUser = null),
                  ),
                ),
              ),
            if (_searchResults.isNotEmpty && _selectedUser == null)
              ...(_searchResults.map((u) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text('${u['firstName']} ${u['lastName']}'),
                subtitle: Text(u['personalNumber'] ?? ''),
                onTap: () => setState(() {
                  _selectedUser = u;
                  _searchResults = [];
                  _searchController.clear();
                }),
              ))),
            const SizedBox(height: 20),

            // Organization
            _buildSectionTitle(s.organization),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(hintText: s.selectOrganization),
              items: _organizations.map((o) => DropdownMenuItem<String>(
                value: o['id'] as String,
                child: Text(o['name'] as String),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedOrg = _organizations.firstWhere((o) => o['id'] == value));
                  _loadOperationTypes(value);
                }
              },
            ),
            const SizedBox(height: 20),

            // Operation types
            if (_operationTypes.isNotEmpty) ...[
              _buildSectionTitle(s.operationTypes),
              ..._operationTypes.map((ot) => CheckboxListTile(
                title: Text(ot['name'] as String),
                subtitle: Text('${ot['creditCost']} ${s.credits}'),
                secondary: Icon(_getIconData(ot['icon'])),
                value: _selectedOpTypeIds.contains(ot['id']),
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selectedOpTypeIds.add(ot['id'] as String);
                    } else {
                      _selectedOpTypeIds.remove(ot['id']);
                    }
                  });
                },
              )),
              const SizedBox(height: 20),
            ],

            // Duration
            _buildSectionTitle(s.duration),
            SwitchListTile(
              title: Text(s.selectDateRange),
              value: _useDateRange,
              onChanged: (v) => setState(() => _useDateRange = v),
            ),
            if (_useDateRange) ...[
              Row(
                children: [
                  Expanded(child: _buildDateButton(s.start, _dateFrom, (d) => setState(() => _dateFrom = d))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDateButton(s.end, _dateTo, (d) => setState(() => _dateTo = d))),
                ],
              ),
            ] else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _durationController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: s.value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _durationType,
                      decoration: InputDecoration(labelText: s.duration),
                      items: [
                        DropdownMenuItem(value: 'minutes', child: Text(s.minutes)),
                        DropdownMenuItem(value: 'hours', child: Text(s.hours)),
                        DropdownMenuItem(value: 'days', child: Text(s.days)),
                      ],
                      onChanged: (v) => setState(() => _durationType = v ?? 'hours'),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // Notes
            TextField(
              controller: _notesController,
              decoration: InputDecoration(labelText: s.noteOptional),
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            // Submit
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _canSubmit ? _submit : null,
                icon: _submitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send),
                label: Text(_submitting ? s.sending : s.grantDelegationBtn(_totalCreditCost)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _canSubmit =>
      !_submitting &&
      _selectedUser != null &&
      _selectedOrg != null &&
      _selectedOpTypeIds.isNotEmpty &&
      _creditBalance >= _totalCreditCost;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await sl<ApiClient>().dio.post(ApiEndpoints.delegations, data: {
        'delegateUserId': _selectedUser!['id'],
        'organizationId': _selectedOrg!['id'],
        'operationTypeIds': _selectedOpTypeIds.toList(),
        'durationType': _useDateRange ? 'range' : _durationType,
        'durationValue': _useDateRange ? null : int.tryParse(_durationController.text),
        'dateFrom': _dateFrom?.toIso8601String(),
        'dateTo': _dateTo?.toIso8601String(),
        'notes': _notesController.text.isEmpty ? null : _notesController.text,
      });

      if (mounted) {
        final s = AppL10n.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(s.delegationCreated), backgroundColor: Colors.green),
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
    setState(() => _submitting = false);
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildDateButton(String label, DateTime? date, ValueChanged<DateTime> onSelected) {
    return OutlinedButton.icon(
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onSelected(picked);
      },
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(date != null ? '${date.day}.${date.month}.${date.year}' : label),
    );
  }

  IconData _getIconData(String? icon) {
    return switch (icon) {
      'sign' => Icons.draw,
      'approve' => Icons.check_circle,
      'finance' => Icons.attach_money,
      'contract' => Icons.description,
      'hr' => Icons.people,
      _ => Icons.assignment,
    };
  }

  @override
  void dispose() {
    _searchController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
