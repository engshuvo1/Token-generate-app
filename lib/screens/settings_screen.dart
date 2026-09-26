import 'package:flutter/material.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  final SettingsService settingsService;

  const SettingsScreen({super.key, required this.settingsService});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _shopNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(
      text: widget.settingsService.shopName,
    );
    _addressController = TextEditingController(
      text: widget.settingsService.address,
    );
    _phoneController = TextEditingController(
      text: widget.settingsService.phone,
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    widget.settingsService.updateSettings(
      organizationName: _shopNameController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.settingsService,
      builder: (context, child) {
        final copies = widget.settingsService.printCopies;
        final paperSize = widget.settingsService.paperSize;

        return Scaffold(
          appBar: AppBar(title: const Text('⚙️ Settings')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Shop / Business Name
              const Text(
                'Shop / Business Details',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Shop / Business Name *',
                  hintText: 'e.g. eng_shuvo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.storefront_rounded),
                ),
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 12),

              // 2. Address
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'e.g. 123 Main Street, Dhaka',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 12),

              // 3. Phone
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  hintText: 'e.g. 017XXXXXXXX',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                onChanged: (_) => _onFieldChanged(),
              ),
              const SizedBox(height: 20),

              // 4. Print Copies & Options
              const Text(
                'Print Configuration',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    // Print Copies Stepper
                    ListTile(
                      leading: const Icon(Icons.copy_rounded),
                      title: const Text('Print Copies'),
                      subtitle: Text(
                        '$copies copy${copies > 1 ? 'ies' : ''} per token print',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.remove, size: 18),
                            onPressed: copies > 1
                                ? () => widget.settingsService.updateSettings(
                                    printCopies: copies - 1,
                                  )
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(
                              '$copies',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.add, size: 18),
                            onPressed: () => widget.settingsService
                                .updateSettings(printCopies: copies + 1),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),

                    // Paper Width
                    ListTile(
                      leading: const Icon(Icons.aspect_ratio),
                      title: const Text('Paper Size'),
                      subtitle: Text(
                        paperSize == PaperSize.mm58
                            ? '58 mm (Standard)'
                            : '80 mm (Wide POS)',
                      ),
                      trailing: SegmentedButton<PaperSize>(
                        segments: const [
                          ButtonSegment(
                            value: PaperSize.mm58,
                            label: Text('58mm'),
                          ),
                          ButtonSegment(
                            value: PaperSize.mm80,
                            label: Text('80mm'),
                          ),
                        ],
                        selected: {paperSize},
                        onSelectionChanged: (set) {
                          widget.settingsService.updateSettings(
                            paperSize: set.first,
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),

                    // Auto-increment
                    SwitchListTile(
                      secondary: const Icon(Icons.auto_mode),
                      title: const Text('Auto-Increment on Print'),
                      subtitle: const Text(
                        'Advance token sequence automatically after printing',
                      ),
                      value: widget.settingsService.autoIncrementToken,
                      onChanged: (val) {
                        widget.settingsService.updateSettings(
                          autoIncrementToken: val,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. Ticket Preview
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ticket Preview',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      paperSize == PaperSize.mm58
                          ? '58mm Thermal'
                          : '80mm Thermal',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Thermal Receipt Visual Simulation
              Center(
                child: Container(
                  width: paperSize == PaperSize.mm58 ? 280 : 340,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Organization Name
                      Text(
                        widget.settingsService.organizationName.isEmpty
                            ? 'ORGANIZATION NAME'
                            : widget.settingsService.organizationName
                                  .toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                      if (widget.settingsService.address.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.settingsService.address,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                      if (widget.settingsService.phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Tel: ${widget.settingsService.phone}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '============================',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 6),

                      const Text(
                        'TOKEN NUMBER',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          letterSpacing: 1,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '001',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'SERIAL NO: A-015',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '----------------------------',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Customer Details
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Customer: John Doe',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Contact: 017XXXXXXXX',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Time: 02:30 PM',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}
