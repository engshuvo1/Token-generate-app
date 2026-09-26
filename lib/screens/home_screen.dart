import 'package:flutter/material.dart';
import '../models/token_data.dart';
import '../services/printer_service.dart';
import '../utils/ticket_formatter.dart';
import '../widgets/printer_status.dart';
import '../widgets/token_input.dart';
import '../widgets/time_picker_field.dart';
import '../widgets/print_button.dart';
import 'printer_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PrinterService _printerService = PrinterService();
  AppSettings _settings = AppSettings();

  String _prefix = 'A';
  int _currentNumber = 1;
  String _selectedDepartment = 'General';
  bool _isPrinting = false;

  final List<String> _departments = [
    'General',
    'Cashier',
    'Billing',
    'Inquiry',
    'Support',
    'VIP',
  ];

  final List<TokenData> _printHistory = [];

  @override
  void initState() {
    super.initState();
    _printerService.checkStatus();
  }

  String get _formattedCurrentToken {
    return '$_prefix-${_currentNumber.toString().padLeft(3, '0')}';
  }

  Future<void> _printToken({TokenData? existingToken}) async {
    final tokenToPrint = existingToken ??
        TokenData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          tokenNumber: _formattedCurrentToken,
          department: _selectedDepartment,
          counter: _settings.counterName,
          timestamp: DateTime.now(),
          businessName: _settings.businessName,
        );

    setState(() => _isPrinting = true);

    try {
      if (!_printerService.isConnected) {
        // Open printer screen or warn user
        final shouldConnect = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.print_disabled, color: Colors.orange),
                SizedBox(width: 8),
                Text('Printer Not Connected'),
              ],
            ),
            content: const Text(
              'No Bluetooth thermal printer is currently connected.\nWould you like to connect a printer now?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Connect Printer'),
              ),
            ],
          ),
        );

        if (shouldConnect == true && mounted) {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrinterScreen(printerService: _printerService),
            ),
          );
        }
        return;
      }

      // Generate receipt bytes
      final bytes = await TicketFormatter.generateTokenTicket(
        token: tokenToPrint,
        paperSize: _settings.paperSize,
        businessName: _settings.businessName,
        subtitle: _settings.subtitle,
        footerMessage: _settings.footerMessage,
        includeQr: _settings.includeQrCode,
      );

      final success = await _printerService.printBytes(bytes);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Printed token ${tokenToPrint.tokenNumber} successfully!'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Add to history
        if (existingToken == null) {
          setState(() {
            _printHistory.insert(0, tokenToPrint);
            if (_settings.autoIncrement) {
              _currentNumber++;
            }
          });
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Print failed: ${_printerService.statusMessage}'),
              backgroundColor: Colors.red,
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

  void _resetCounter() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Counter'),
        content: Text('Reset token number sequence for prefix $_prefix back to 1?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _currentNumber = 1);
              Navigator.pop(ctx);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _printerService,
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.confirmation_number_outlined),
                SizedBox(width: 8),
                Text('Token Generator'),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.print),
                tooltip: 'Printers',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrinterScreen(printerService: _printerService),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsScreen(
                        settings: _settings,
                        onSettingsChanged: (updated) {
                          setState(() => _settings = updated);
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      // Printer Status Widget
                      PrinterStatusWidget(printerService: _printerService),

                      // Live Time Ticker
                      const TimePickerField(),

                      // Token Input & Preview
                      TokenInputWidget(
                        prefix: _prefix,
                        currentNumber: _currentNumber,
                        selectedDepartment: _selectedDepartment,
                        counterText: _settings.counterName,
                        departments: _departments,
                        onPrefixChanged: (val) => setState(() => _prefix = val),
                        onNumberChanged: (val) => setState(() => _currentNumber = val),
                        onDepartmentChanged: (val) => setState(() => _selectedDepartment = val),
                        onCounterChanged: (val) => setState(() => _settings.counterName = val),
                        onIncrement: () => setState(() => _currentNumber++),
                        onDecrement: () => setState(() {
                          if (_currentNumber > 1) _currentNumber--;
                        }),
                        onReset: _resetCounter,
                      ),

                      // Print Button
                      PrintButtonWidget(
                        isPrinting: _isPrinting,
                        isConnected: _printerService.isConnected,
                        tokenPreview: _formattedCurrentToken,
                        onPrint: () => _printToken(),
                      ),

                      // Recent Tokens Print History
                      if (_printHistory.isNotEmpty) ...[
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Printed Tokens History (${_printHistory.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              TextButton(
                                onPressed: () => setState(() => _printHistory.clear()),
                                child: const Text('Clear', style: TextStyle(fontSize: 12)),
                              ),
                            ],
                          ),
                        ),
                        ..._printHistory.map((token) {
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 18,
                                child: Text(
                                  token.tokenNumber.split('-').first,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              title: Text(
                                token.tokenNumber,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${token.department} • ${TicketFormatter.formatDate(token.timestamp)}',
                                style: const TextStyle(fontSize: 11),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.replay_rounded, size: 20),
                                tooltip: 'Reprint',
                                onPressed: _isPrinting
                                    ? null
                                    : () => _printToken(existingToken: token),
                              ),
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
