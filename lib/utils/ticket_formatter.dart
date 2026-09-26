import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../models/token_data.dart';

class TicketFormatter {
  static String formatDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');
    return '$year-$month-$day $hour:$minute:$second';
  }

  static Future<List<int>> generateTokenTicket({
    required TokenData token,
    PaperSize paperSize = PaperSize.mm58,
    String businessName = 'TOKEN MANAGEMENT',
    String? subtitle = 'Queue Token System',
    String? footerMessage = 'Please wait for your number to be called.',
    bool includeQr = true,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    // Reset printer state
    bytes += generator.reset();

    // Business Header
    bytes += generator.text(
      token.businessName ?? businessName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size1,
      ),
      linesAfter: 1,
    );

    if (subtitle != null && subtitle.isNotEmpty) {
      bytes += generator.text(
        subtitle,
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Divider
    bytes += generator.hr(ch: '=');

    // Department / Category
    bytes += generator.text(
      'DEPARTMENT: ${token.department.toUpperCase()}',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
      linesAfter: 1,
    );

    if (token.counter != null && token.counter!.isNotEmpty) {
      bytes += generator.text(
        'Counter: ${token.counter}',
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // Main Token Number Display
    bytes += generator.feed(1);
    bytes += generator.text(
      'YOUR TOKEN',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: false,
      ),
    );

    bytes += generator.text(
      token.tokenNumber,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size3,
        width: PosTextSize.size3,
      ),
      linesAfter: 1,
    );

    // Timestamp
    bytes += generator.hr(ch: '-');
    bytes += generator.text(
      'Time: ${formatDate(token.timestamp)}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    if (token.note != null && token.note!.isNotEmpty) {
      bytes += generator.text(
        token.note!,
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // QR Code (optional)
    if (includeQr) {
      bytes += generator.qrcode(
        'TOKEN:${token.tokenNumber}|DEPT:${token.department}|DATE:${token.timestamp.millisecondsSinceEpoch}',
        size: QRSize.size3,
      );
      bytes += generator.feed(1);
    }

    // Footer Message
    if (footerMessage != null && footerMessage.isNotEmpty) {
      bytes += generator.text(
        footerMessage,
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    bytes += generator.text(
      '*** THANK YOU ***',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
      linesAfter: 1,
    );

    // Feed and cut paper
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  static Future<List<int>> generateTestTicket({
    PaperSize paperSize = PaperSize.mm58,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    bytes += generator.reset();
    bytes += generator.text(
      'PRINTER TEST',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    bytes += generator.hr();
    bytes += generator.text(
      'Paper Size: ${paperSize == PaperSize.mm58 ? '58mm' : '80mm'}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Status: CONNECTED OK',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Date: ${formatDate(DateTime.now())}',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 1,
    );

    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      'Thermal Printer is working!',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 2,
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
