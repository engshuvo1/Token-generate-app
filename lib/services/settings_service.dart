import 'package:flutter/foundation.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  String _shopName = 'MY SERVICE CENTER';
  String _organizationName = 'MY SERVICE CENTER';
  String _address = '';
  String _phone = '+880 1700-000000';
  int _printCopies = 1;
  PaperSize _paperSize = PaperSize.mm58;
  bool _includeQrCode = true;
  bool _autoIncrementToken = true;

  String get shopName => _shopName;
  String get organizationName => _organizationName;
  String get address => _address;
  String get phone => _phone;
  int get printCopies => _printCopies;
  PaperSize get paperSize => _paperSize;
  bool get includeQrCode => _includeQrCode;
  bool get autoIncrementToken => _autoIncrementToken;

  void updateSettings({
    String? shopName,
    String? organizationName,
    String? address,
    String? phone,
    int? printCopies,
    PaperSize? paperSize,
    bool? includeQrCode,
    bool? autoIncrementToken,
  }) {
    if (shopName != null) _shopName = shopName;
    if (organizationName != null) _organizationName = organizationName;
    if (address != null) _address = address;
    if (phone != null) _phone = phone;
    if (printCopies != null && printCopies > 0) _printCopies = printCopies;
    if (paperSize != null) _paperSize = paperSize;
    if (includeQrCode != null) _includeQrCode = includeQrCode;
    if (autoIncrementToken != null) _autoIncrementToken = autoIncrementToken;
    notifyListeners();
  }
}
