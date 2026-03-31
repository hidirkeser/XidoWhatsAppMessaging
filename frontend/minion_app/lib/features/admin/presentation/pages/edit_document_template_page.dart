import 'package:flutter/material.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../l10n/generated/app_localizations.dart';

class EditDocumentTemplatePage extends StatefulWidget {
  final String? templateId; // null = create new

  const EditDocumentTemplatePage({super.key, this.templateId});

  bool get isNew => templateId == null || templateId == 'new';

  @override
  State<EditDocumentTemplatePage> createState() => _EditDocumentTemplatePageState();
}

class _EditDocumentTemplatePageState extends State<EditDocumentTemplatePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _contentController = TextEditingController();
  final _versionController = TextEditingController(text: '1.0');
  String _language = 'en';
  String _languageName = 'English';
  bool _loading = true;
  bool _saving = false;
  String? _previewHtml;

  static const _languages = {
    'en': 'English',
    'sv': 'Svenska',
    'tr': 'Turkce',
    'de': 'Deutsch',
    'es': 'Espanol',
    'fr': 'Francais',
  };

  static const _placeholders = [
    '{{GrantorName}}',
    '{{GrantorPersonalNumber}}',
    '{{DelegateName}}',
    '{{DelegatePersonalNumber}}',
    '{{OrganizationName}}',
    '{{OrganizationNumber}}',
    '{{Operations}}',
    '{{ValidFrom}}',
    '{{ValidTo}}',
    '{{Notes}}',
    '{{VerificationCode}}',
    '{{QrCodeUrl}}',
    '{{CreatedAt}}',
    '{{DocumentVersion}}',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    if (!widget.isNew) {
      _loadTemplate();
    } else {
      _loading = false;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _contentController.dispose();
    _versionController.dispose();
    super.dispose();
  }

  Future<void> _loadTemplate() async {
    try {
      final res = await sl<ApiClient>().dio.get('/admin/document-templates/${widget.templateId}');
      final data = res.data;
      setState(() {
        _language = data['language'];
        _languageName = data['languageName'];
        _contentController.text = data['templateContent'];
        _versionController.text = data['version'];
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) await AppDialog.showError(context, e);
    }
  }

  Future<void> _save() async {
    if (_contentController.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      if (widget.isNew) {
        await sl<ApiClient>().dio.post('/admin/document-templates', data: {
          'language': _language,
          'languageName': _languageName,
          'templateContent': _contentController.text,
          'version': _versionController.text,
        });
      } else {
        await sl<ApiClient>().dio.put('/admin/document-templates/${widget.templateId}', data: {
          'languageName': _languageName,
          'templateContent': _contentController.text,
          'version': _versionController.text,
        });
      }
      if (mounted) {
        await AppDialog.showSuccess(context, widget.isNew ? 'Template created.' : 'Template updated.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _preview() async {
    try {
      final endpoint = widget.isNew
          ? '/admin/document-templates/${_placeholders.hashCode}/preview'  // Won't actually use ID for new
          : '/admin/document-templates/${widget.templateId}/preview';

      final res = await sl<ApiClient>().dio.post(
        widget.isNew ? '/admin/document-templates/00000000-0000-0000-0000-000000000000/preview' : endpoint,
        data: {'templateContent': _contentController.text},
      );
      setState(() {
        _previewHtml = res.data['renderedContent'];
        _tabController.animateTo(2); // Switch to preview tab
      });
    } catch (e) {
      if (mounted) await AppDialog.showError(context, e);
    }
  }

  void _insertPlaceholder(String placeholder) {
    final text = _contentController.text;
    final selection = _contentController.selection;
    final newText = text.replaceRange(
      selection.start,
      selection.end,
      placeholder,
    );
    _contentController.text = newText;
    _contentController.selection = TextSelection.collapsed(
      offset: selection.start + placeholder.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppL10n.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.isNew ? s.createTemplate : s.editTemplate)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isNew ? s.createTemplate : s.editTemplate),
        actions: [
          TextButton.icon(
            onPressed: _preview,
            icon: const Icon(Icons.preview, size: 18),
            label: Text(s.previewTemplate),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 16, height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(s.save),
          ),
          const SizedBox(width: 12),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: s.settings),
            Tab(text: 'HTML'),
            Tab(text: s.previewTemplate),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ── Tab 1: Settings ─────────────────────────────────
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Language selector
              Text(s.language, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _language,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _languages.entries.map((e) => DropdownMenuItem(
                  value: e.key,
                  child: Text('${e.value} (${e.key.toUpperCase()})'),
                )).toList(),
                onChanged: widget.isNew ? (val) {
                  setState(() {
                    _language = val!;
                    _languageName = _languages[val]!;
                  });
                } : null,
              ),
              const SizedBox(height: 16),

              // Version
              Text(s.version, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _versionController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: '1.0',
                ),
              ),
              const SizedBox(height: 24),

              // Placeholder reference
              Text(s.templatePlaceholders,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(s.templatePlaceholdersDescription,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _placeholders.map((p) => ActionChip(
                  label: Text(p, style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                  onPressed: () {
                    _insertPlaceholder(p);
                    _tabController.animateTo(1); // Go to HTML tab
                  },
                  backgroundColor: cs.surfaceContainerHighest,
                )).toList(),
              ),
            ],
          ),

          // ── Tab 2: HTML Editor ──────────────────────────────
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextFormField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: '<div>\n  <!-- HTML template content -->\n</div>',
                hintStyle: TextStyle(color: Colors.grey[400]),
              ),
            ),
          ),

          // ── Tab 3: Preview ──────────────────────────────────
          _previewHtml == null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.preview_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Text(s.previewTemplateHint,
                          style: TextStyle(color: Colors.grey[600])),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _preview,
                        icon: const Icon(Icons.refresh),
                        label: Text(s.previewTemplate),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(8),
                  child: SelectableText(
                    _previewHtml!,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
        ],
      ),
    );
  }
}
