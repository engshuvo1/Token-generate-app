import 'package:flutter/material.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../services/printer_service.dart';
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
  bool _isScanning = false;
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _refreshPrinters();
  }

  Future<void> _refreshPrinters() async {
    setState(() => _isScanning = true);
    await widget.printerService.scanDevices();
    if (mounted) {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _testPrint() async {
    setState(() => _isTesting = true);
    try {
      final bytes = await TicketFormatter.generateTestTicket(paperSize: PaperSize.mm58);
      final ok = await widget.printerService.printBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok ? 'Test ticket printed!' : 'Failed to print test ticket'),
            backgroundColor: ok ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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
            title: const Text('Bluetooth Printers'),
            actions: [
              IconButton(
                icon: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.refresh),
                tooltip: 'Scan for devices',
                onPressed: _isScanning ? null : _refreshPrinters,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Bluetooth Status Card
              Card(
                color: widget.printerService.isBluetoothEnabled
                    ? Colors.green.shade50
                    : Colors.amber.shade50,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: widget.printerService.isBluetoothEnabled
                        ? Colors.green.shade200
                        : Colors.amber.shade300,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Row(
                    children: [
                      Icon(
                        widget.printerService.isBluetoothEnabled
                            ? Icons.bluetooth
                            : Icons.bluetooth_disabled,
                        color: widget.printerService.isBluetoothEnabled
                            ? Colors.green.shade700
                            : Colors.amber.shade800,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.printerService.isBluetoothEnabled
                                  ? 'Bluetooth is Enabled'
                                  : 'Bluetooth is Disabled',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.printerService.isBluetoothEnabled
                                    ? Colors.green.shade900
                                    : Colors.amber.shade900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              widget.printerService.statusMessage,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Active Connection Banner
              if (isConnected && connectedDevice != null) ...[
                Card(
                  elevation: 2,
                  color: Colors.blue.shade50,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.blue.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.blue, size: 28),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    connectedDevice.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'MAC: ${connectedDevice.macAdress}',
                                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
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
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.receipt_long),
                                label: const Text('Test Print'),
                                onPressed: _isTesting ? null : _testPrint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Paired Devices List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Paired Bluetooth Printers',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('Scan'),
                    onPressed: _isScanning ? null : _refreshPrinters,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (devices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.print_disabled, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      const Text(
                        'No paired thermal printers found.',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '1. Turn ON your thermal printer.\n2. Pair it via your device\'s Android Bluetooth settings.\n3. Return here and tap Scan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              else
                ...devices.map((device) {
                  final isCurrent = connectedDevice?.macAdress == device.macAdress;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isCurrent ? Colors.blue : Colors.grey.shade200,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: Icon(
                        Icons.print,
                        color: isCurrent ? Colors.blue : Colors.grey[700],
                      ),
                      title: Text(
                        device.name.isEmpty ? 'Unknown Printer' : device.name,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        'MAC: ${device.macAdress}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: isCurrent
                          ? const Chip(
                              label: Text('Connected', style: TextStyle(color: Colors.white, fontSize: 11)),
                              backgroundColor: Colors.blue,
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
