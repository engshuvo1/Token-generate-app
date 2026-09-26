import 'package:flutter/material.dart';
import '../services/printer_service.dart';

class PrinterStatusWidget extends StatelessWidget {
  final PrinterService printerService;
  final VoidCallback? onTap;

  const PrinterStatusWidget({
    super.key,
    required this.printerService,
    this.onTap,
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
            ? const Color(0xFF2E7D32)
            : isConnecting
                ? Colors.orange
                : const Color(0xFFD32F2F);

        final String statusLabel = isConnected
            ? '🟢 Connected'
            : isConnecting
                ? '🟡 Connecting...'
                : '🔴 Not Connected';

        final String statusDetail = isConnected
            ? '${device?.name ?? "Bluetooth Printer"} (${device?.macAdress ?? ""})'
            : isConnecting
                ? 'Establishing Bluetooth link...'
                : 'Tap to scan and connect Bluetooth thermal printer';

        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: statusColor.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          color: isConnected
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFFFEBEE),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    isConnected ? Icons.print_rounded : Icons.print_disabled_rounded,
                    color: statusColor,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusDetail,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null)
                    TextButton(
                      onPressed: onTap,
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        foregroundColor: statusColor,
                      ),
                      child: Text(isConnected ? 'Manage' : 'Connect'),
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
