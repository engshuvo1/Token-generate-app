import 'package:flutter/material.dart';

import '../models/token_data.dart';
import '../services/printer_service.dart';
import '../services/settings_service.dart';
import '../utils/ticket_formatter.dart';
import '../widgets/printer_status.dart';

class HomeScreen extends StatefulWidget {
  final PrinterService printerService;
  final SettingsService settingsService;
  final VoidCallback onOpenPrinterTab;

  const HomeScreen({
    super.key,
    required this.printerService,
    required this.settingsService,
    required this.onOpenPrinterTab,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _tokenController = TextEditingController(
    text: '001',
  );
  final TextEditingController _serialController = TextEditingController(
    text: 'A-015',
  );
  final TextEditingController _customerController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isAutoTime = true;
  bool _isPrinting = false;
  final List<TokenData> _recentTokens = [];

  @override
  void dispose() {
    _tokenController.dispose();
    _serialController.dispose();
    _customerController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay tod) {
    final hour = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final minute = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:$minute $period';
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _isAutoTime = false;
      });
    }
  }

  void _stepToken(int delta) {
    final current = int.tryParse(_tokenController.text.trim()) ?? 1;
    final next = (current + delta).clamp(1, 9999);
    setState(() {
      _tokenController.text = next.toString().padLeft(3, '0');
    });
  }

  Future<void> _printToken({TokenData? reprintToken}) async {
    final tokenNumber =
        reprintToken?.tokenNumber ?? _tokenController.text.trim();
    final serialNumber =
        reprintToken?.serialNumber ?? _serialController.text.trim();
    final timeStr =
        reprintToken?.time ??
        (_isAutoTime
            ? _formatTimeOfDay(TimeOfDay.now())
            : _formatTimeOfDay(_selectedTime));

    if (tokenNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Token Number *'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (serialNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a Serial Number *'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!widget.printerService.isConnected) {
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('🔴 Printer Not Connected'),
          content: const Text(
            'No Bluetooth thermal printer is connected.\nWould you like to connect a printer now?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Go to Printer'),
            ),
          ],
        ),
      );
      if (open == true) {
        widget.onOpenPrinterTab();
      }
      return;
    }

    setState(() => _isPrinting = true);

    try {
      final tokenData =
          reprintToken ??
          TokenData(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            tokenNumber: tokenNumber,
            serialNumber: serialNumber,
            customerName: _customerController.text.trim().isEmpty
                ? null
                : _customerController.text.trim(),
            contactNumber: _contactController.text.trim().isEmpty
                ? null
                : _contactController.text.trim(),
            time: timeStr,
            date: DateTime.now(),
            shopName: widget.settingsService.shopName,
            address: widget.settingsService.address,
            phone: widget.settingsService.phone,
          );

      final bytes = await TicketFormatter.generateTokenTicket(
        token: tokenData,
        paperSize: widget.settingsService.paperSize,
        shopName: widget.settingsService.shopName,
        address: widget.settingsService.address,
        phone: widget.settingsService.phone,
        includeQr: widget.settingsService.includeQrCode,
      );

      final copies = widget.settingsService.printCopies;
      bool allSuccessful = true;

      for (int i = 0; i < copies; i++) {
        final ok = await widget.printerService.printBytes(bytes);
        if (!ok) allSuccessful = false;
        if (i < copies - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      if (mounted) {
        if (allSuccessful) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Printed $copies ticket(s) for Token #$tokenNumber',
              ),
              backgroundColor: Colors.green,
            ),
          );

          if (reprintToken == null) {
            setState(() {
              _recentTokens.insert(0, tokenData);
              if (widget.settingsService.autoIncrementToken) {
                _stepToken(1);
              }
              // Reset customer details for next customer
              _customerController.clear();
              _contactController.clear();
              _isAutoTime = true;
            });
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Print issue: ${widget.printerService.statusMessage}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error printing ticket: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTimeFormatted = _isAutoTime
        ? _formatTimeOfDay(TimeOfDay.now())
        : _formatTimeOfDay(_selectedTime);

    return Scaffold(
      appBar: AppBar(title: const Text('🏠 Home / Token Printer')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Printer Status (🟢 Connected / 🔴 Not Connected)
          PrinterStatusWidget(
            printerService: widget.printerService,
            onTap: widget.onOpenPrinterTab,
          ),
          const SizedBox(height: 8),

          // Main Form Card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Token Number * (Manual Input)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Token Number *',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton.filledTonal(
                            icon: const Icon(Icons.remove, size: 16),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _stepToken(-1),
                            tooltip: 'Decrease',
                          ),
                          const SizedBox(width: 4),
                          IconButton.filledTonal(
                            icon: const Icon(Icons.add, size: 16),
                            visualDensity: VisualDensity.compact,
                            onPressed: () => _stepToken(1),
                            tooltip: 'Increase',
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _tokenController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Example: 001',
                      prefixIcon: const Icon(Icons.confirmation_number_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 2. Serial Number * (Manual Input)
                  const Text(
                    'Serial Number *',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _serialController,
                    keyboardType: TextInputType.text,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Example: A-015',
                      prefixIcon: const Icon(Icons.tag_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Customer Name (Optional)
                  const Text(
                    'Customer Name (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _customerController,
                    decoration: InputDecoration(
                      hintText: 'Example: Shuvo',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Contact Number (Optional)
                  const Text(
                    'Contact Number (Optional)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _contactController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: 'Example: 017XXXXXXXX',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Time * (Time Picker)
                  const Text(
                    'Time *',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: _pickTime,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_rounded,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              currentTimeFormatted,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isAutoTime
                                  ? Colors.green.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _isAutoTime ? 'Live Auto' : 'Custom',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _isAutoTime
                                    ? Colors.green.shade800
                                    : Colors.blue.shade800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 6. 🖨 PRINT TOKEN Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isPrinting ? null : () => _printToken(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E56A0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      icon: _isPrinting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.print_rounded, size: 24),
                      label: Text(
                        _isPrinting ? 'PRINTING...' : '🖨 PRINT TOKEN',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Recent Printed Tokens
          if (_recentTokens.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Printed Tokens (${_recentTokens.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _recentTokens.clear()),
                    child: const Text('Clear', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
            ..._recentTokens.map((t) {
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      t.tokenNumber,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  title: Text(
                    'Token #${t.tokenNumber} • Serial: ${t.serialNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${t.customerName != null ? "${t.customerName} • " : ""}${t.time}',
                    style: const TextStyle(fontSize: 11),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.replay_rounded, size: 20),
                    tooltip: 'Reprint',
                    onPressed: _isPrinting
                        ? null
                        : () => _printToken(reprintToken: t),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
