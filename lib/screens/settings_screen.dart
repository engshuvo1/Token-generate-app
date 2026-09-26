import 'package:flutter/material.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class AppSettings {
  String businessName;
  String subtitle;
  String footerMessage;
  PaperSize paperSize;
  bool autoIncrement;
  bool includeQrCode;
  String counterName;

  AppSettings({
    this.businessName = 'SMART TOKEN QUEUE',
    this.subtitle = 'Customer Care Service',
    this.footerMessage = 'Please retain this slip until your number is called.',
    this.paperSize = PaperSize.mm58,
    this.autoIncrement = true,
    this.includeQrCode = true,
    this.counterName = 'Desk 1',
  });
}

class SettingsScreen extends StatefulWidget {
  final AppSettings settings;
  final ValueChanged<AppSettings> onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _businessController;
  late TextEditingController _subtitleController;
  late TextEditingController _footerController;
  late TextEditingController _counterController;
  late PaperSize _paperSize;
  late bool _autoIncrement;
  late bool _includeQrCode;

  @override
  void initState() {
    super.initState();
    _businessController = TextEditingController(text: widget.settings.businessName);
    _subtitleController = TextEditingController(text: widget.settings.subtitle);
    _footerController = TextEditingController(text: widget.settings.footerMessage);
    _counterController = TextEditingController(text: widget.settings.counterName);
    _paperSize = widget.settings.paperSize;
    _autoIncrement = widget.settings.autoIncrement;
    _includeQrCode = widget.settings.includeQrCode;
  }

  @override
  void dispose() {
    _businessController.dispose();
    _subtitleController.dispose();
    _footerController.dispose();
    _counterController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    final updated = AppSettings(
      businessName: _businessController.text.trim().isEmpty
          ? 'SMART TOKEN QUEUE'
          : _businessController.text.trim(),
      subtitle: _subtitleController.text.trim(),
      footerMessage: _footerController.text.trim(),
      counterName: _counterController.text.trim(),
      paperSize: _paperSize,
      autoIncrement: _autoIncrement,
      includeQrCode: _includeQrCode,
    );
    widget.onSettingsChanged(updated);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Printer & Token Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save Settings',
            onPressed: _saveSettings,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Header & Business Info',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _businessController,
            decoration: const InputDecoration(
              labelText: 'Business / Organization Name',
              hintText: 'e.g. City Hospital / Bank / Store',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.business),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _subtitleController,
            decoration: const InputDecoration(
              labelText: 'Sub-header / Branch',
              hintText: 'e.g. Main Branch, Floor 2',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.subtitles),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _counterController,
            decoration: const InputDecoration(
              labelText: 'Counter / Desk Name',
              hintText: 'e.g. Counter 1, Window A',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.desktop_windows),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Ticket Details & Footer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _footerController,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Footer Notice Message',
              hintText: 'e.g. Please retain this slip until your number is called.',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.message),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Printing Configuration',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  title: const Text('Thermal Paper Width'),
                  subtitle: Text(_paperSize == PaperSize.mm58 ? '58 mm (Standard Mobile)' : '80 mm (Desktop POS)'),
                  trailing: SegmentedButton<PaperSize>(
                    segments: const [
                      ButtonSegment(value: PaperSize.mm58, label: Text('58mm')),
                      ButtonSegment(value: PaperSize.mm80, label: Text('80mm')),
                    ],
                    selected: {_paperSize},
                    onSelectionChanged: (set) {
                      setState(() => _paperSize = set.first);
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Auto-Increment on Print'),
                  subtitle: const Text('Automatically advance token number after printing'),
                  value: _autoIncrement,
                  onChanged: (val) => setState(() => _autoIncrement = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Include QR Code'),
                  subtitle: const Text('Print a verifiable QR code on each token slip'),
                  value: _includeQrCode,
                  onChanged: (val) => setState(() => _includeQrCode = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.save),
            label: const Text('Save Settings'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: _saveSettings,
          ),
        ],
      ),
    );
  }
}
