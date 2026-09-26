import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../services/printer_service.dart';
import '../services/settings_service.dart';
import '../utils/ticket_formatter.dart';

class PrinterScreen extends StatefulWidget {
  final PrinterService printerService;

  const PrinterScreen({
    super.key,
    required this.printerService,
  });

  @override
  State<PrinterScreen> createState() => _PrinterScreenState();
}

class _PrinterScreenState extends State<PrinterScreen> {
  final SettingsService _settingsService = SettingsService();
  bool _isScanning = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _scanPrinters();
  }

  Future<void> _scanPrinters() async {
    setState(() => _isScanning = true);
    await widget.printerService.scanDevices();
    if (mounted) {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _testPrint() async {
    setState(() => _isTesting = true);
    try {
      final bytes = await TicketFormatter.generateTestTicket(
        paperSize: _settingsService.paperSize,
        shopName: _settingsService.shopName,
        address: _settingsService.address,
        phone: _settingsService.phone,
      );
      final ok = await widget.printerService.printBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Test ticket printed successfully!' : 'Failed to send test print data'),
            backgroundColor: ok ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Test print error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isTesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.printerService,
      builder: (context, child) {
        final devices = widget.printerService.availableDevices;
        final connectedDevice = widget.printerService.connectedDevice;
        final isConnected = widget.printerService.isConnected;
        final isConnecting = widget.printerService.connectionState == PrinterConnectionState.connecting;

        return Scaffold(
          appBar: AppBar(
            title: const Text('🖨 Printer'),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Scan Bluetooth Printers',
                onPressed: _isScanning ? null : _scanPrinters,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Connection Status Header Banner
              Card(
                color: isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isConnected ? Colors.green.shade400 : Colors.red.shade300,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            isConnected ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: isConnected ? Colors.green : Colors.red,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isConnected ? '🟢 Connected' : '🔴 Not Connected',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isConnected ? Colors.green.shade900 : Colors.red.shade900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isConnected
                                      ? '${connectedDevice?.name} (${connectedDevice?.macAdress})'
                                      : 'No thermal printer linked yet',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (isConnected) ...[
                        const Divider(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.link_off, color: Colors.red),
                                label: const Text('Disconnect', style: TextStyle(color: Colors.red)),
                                onPressed: () => widget.printerService.disconnect(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: _isTesting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.receipt_long),
                                label: const Text('Test Print'),
                                onPressed: _isTesting ? null : _testPrint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Scan Action Button
              ElevatedButton.icon(
                onPressed: _isScanning ? null : _scanPrinters,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: _isScanning
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.bluetooth_searching),
                label: Text(
                  _isScanning ? 'Scanning Bluetooth Printers...' : 'Scan Bluetooth Printers',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 24),

              // Available Printers Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Available Printers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${devices.length} found',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (devices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.print_disabled_outlined, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text(
                        'No Bluetooth thermal printers found',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1. Turn ON your 58mm/80mm thermal printer.\n2. Pair it via your device Bluetooth settings.\n3. Tap "Scan Bluetooth Printers" above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                ...devices.map((BluetoothInfo device) {
                  final isCurrent = connectedDevice?.macAdress == device.macAdress;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isCurrent ? Colors.green : Colors.grey.shade300,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.print,
                        color: isCurrent ? Colors.green : Colors.grey[700],
                      ),
                      title: Text(
                        device.name.isEmpty ? 'Thermal Printer' : device.name,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'MAC: ${device.macAdress}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: isCurrent
                          ? OutlinedButton(
                              onPressed: () => widget.printerService.disconnect(),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                              child: const Text('Disconnect'),
                            )
                          : ElevatedButton(
                              onPressed: isConnecting
                                  ? null
                                  : () => widget.printerService.connect(device),
                              child: const Text('Connect'),
                            ),
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
