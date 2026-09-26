import 'package:flutter/material.dart';
import '../services/printer_service.dart';
import '../screens/printer_screen.dart';

class PrinterStatusWidget extends StatelessWidget {
  final PrinterService printerService;

  const PrinterStatusWidget({
    super.key,
    required this.printerService,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: printerService,
      builder: (context, child) {
        final isConnected = printerService.isConnected;
        final isConnecting = printerService.connectionState == PrinterConnectionState.connecting;
        final device = printerService.connectedDevice;

        final Color statusColor = isConnected
            ? Colors.green
            : isConnecting
                ? Colors.orange
                : Colors.redAccent;

        final String statusText = isConnected
            ? 'Connected: ${device?.name ?? "Thermal Printer"}'
            : isConnecting
                ? 'Connecting...'
                : 'No Printer Connected';

        final String subText = isConnected
            ? (device?.macAdress ?? '')
            : 'Tap to configure Bluetooth printer';

        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: statusColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PrinterScreen(printerService: printerService)),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isConnected ? Icons.print : Icons.print_disabled,
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                statusText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subText,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => PrinterScreen(printerService: printerService)),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(isConnected ? 'Change' : 'Connect'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
