import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../models/token_data.dart';

class TicketFormatter {
  static String formatDate(DateTime dt) {
    final year = dt.year.toString().padLeft(4, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static Future<List<int>> generateTokenTicket({
    required TokenData token,
    PaperSize paperSize = PaperSize.mm58,
    required String shopName,
    required String address,
    required String phone,
    bool includeQr = true,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    // Reset printer
    bytes += generator.reset();

    // 1. Shop / Business Header
    bytes += generator.text(
      token.shopName ?? shopName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
        width: PosTextSize.size1,
      ),
      linesAfter: 1,
    );

    // 2. Address
    final displayAddress = token.address ?? address;
    if (displayAddress.isNotEmpty) {
      bytes += generator.text(
        displayAddress,
        styles: const PosStyles(align: PosAlign.center),
      );
    }

    // 3. Phone
    final displayPhone = token.phone ?? phone;
    if (displayPhone.isNotEmpty) {
      bytes += generator.text(
        'Tel: $displayPhone',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      );
    }

    // Divider
    bytes += generator.hr(ch: '=');

    // 4. Token Number * (Prominent)
    bytes += generator.text(
      'TOKEN NUMBER',
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

    // 5. Serial Number *
    bytes += generator.text(
      'SERIAL NO: ${token.serialNumber}',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
      linesAfter: 1,
    );

    bytes += generator.hr(ch: '-');

    // 6. Customer Name (Optional)
    if (token.customerName != null && token.customerName!.trim().isNotEmpty) {
      bytes += generator.text(
        'Customer: ${token.customerName!.trim()}',
        styles: const PosStyles(align: PosAlign.left),
      );
    }

    // 7. Contact Number (Optional)
    if (token.contactNumber != null && token.contactNumber!.trim().isNotEmpty) {
      bytes += generator.text(
        'Contact: ${token.contactNumber!.trim()}',
        styles: const PosStyles(align: PosAlign.left),
      );
    }

    // 8. Time * & Date
    bytes += generator.text(
      'Time: ${token.time}',
      styles: const PosStyles(
        align: PosAlign.left,
        bold: true,
      ),
    );
    bytes += generator.text(
      'Date: ${formatDate(token.date)}',
      styles: const PosStyles(align: PosAlign.left),
      linesAfter: 1,
    );

    // 9. QR Code (optional)
    if (includeQr) {
      bytes += generator.qrcode(
        'TOKEN:${token.tokenNumber}|SN:${token.serialNumber}|TIME:${token.time}',
        size: QRSize.size3,
      );
      bytes += generator.feed(1);
    }

    // Footer notice
    bytes += generator.hr(ch: '-');
    bytes += generator.text(
      'Please wait for your call',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Thank you!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
      linesAfter: 2,
    );

    // Cut paper
    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }

  static Future<List<int>> generateTestTicket({
    PaperSize paperSize = PaperSize.mm58,
    required String shopName,
    required String address,
    required String phone,
  }) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(paperSize, profile);
    List<int> bytes = [];

    bytes += generator.reset();
    bytes += generator.text(
      shopName,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size2,
      ),
      linesAfter: 1,
    );

    if (address.isNotEmpty) {
      bytes += generator.text(address, styles: const PosStyles(align: PosAlign.center));
    }
    if (phone.isNotEmpty) {
      bytes += generator.text('Tel: $phone', styles: const PosStyles(align: PosAlign.center));
    }

    bytes += generator.hr(ch: '=');
    bytes += generator.text(
      'TEST PRINT SUCCESS',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
      ),
      linesAfter: 1,
    );
    bytes += generator.text(
      'Paper: ${paperSize == PaperSize.mm58 ? '58mm' : '80mm'}',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      'Status: 🟢 Connected',
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.hr(ch: '-');
    bytes += generator.text(
      'Thermal printer is operating correctly.',
      styles: const PosStyles(align: PosAlign.center),
      linesAfter: 2,
    );

    bytes += generator.feed(2);
    bytes += generator.cut();

    return bytes;
  }
}
