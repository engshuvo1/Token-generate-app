import 'package:flutter/material.dart';

class PrintButtonWidget extends StatelessWidget {
  final bool isPrinting;
  final bool isConnected;
  final String tokenPreview;
  final VoidCallback onPrint;

  const PrintButtonWidget({
    super.key,
    required this.isPrinting,
    required this.isConnected,
    required this.tokenPreview,
    required this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: ElevatedButton(
        onPressed: isPrinting ? null : onPrint,
        style: ElevatedButton.styleFrom(
          backgroundColor: isConnected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          foregroundColor: isConnected
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: isConnected ? 4 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isPrinting
            ? const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'PRINTING TICKET...',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isConnected ? Icons.print_rounded : Icons.print_disabled,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isConnected
                        ? 'PRINT TICKET  ($tokenPreview)'
                        : 'CONNECT PRINTER TO PRINT',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
