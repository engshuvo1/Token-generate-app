import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

enum PrinterConnectionState {
  disconnected,
  connecting,
  connected,
}

class PrinterService extends ChangeNotifier {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  BluetoothInfo? _connectedDevice;
  PrinterConnectionState _connectionState = PrinterConnectionState.disconnected;
  List<BluetoothInfo> _availableDevices = [];
  bool _isBluetoothEnabled = false;
  bool _hasPermission = false;
  String _statusMessage = 'Ready';

  BluetoothInfo? get connectedDevice => _connectedDevice;
  PrinterConnectionState get connectionState => _connectionState;
  List<BluetoothInfo> get availableDevices => _availableDevices;
  bool get isBluetoothEnabled => _isBluetoothEnabled;
  bool get hasPermission => _hasPermission;
  String get statusMessage => _statusMessage;
  bool get isConnected => _connectionState == PrinterConnectionState.connected;

  Future<void> checkStatus() async {
    if (kIsWeb) {
      _hasPermission = true;
      _isBluetoothEnabled = true;
      _statusMessage = 'Web mode (Virtual printer ready)';
      notifyListeners();
      return;
    }

    try {
      _hasPermission = await PrintBluetoothThermal.isPermissionBluetoothGranted;
      _isBluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      final connected = await PrintBluetoothThermal.connectionStatus;
      
      if (connected) {
        _connectionState = PrinterConnectionState.connected;
      } else if (_connectionState == PrinterConnectionState.connected) {
        _connectionState = PrinterConnectionState.disconnected;
        _connectedDevice = null;
      }
      notifyListeners();
    } catch (e) {
      _statusMessage = 'Status check failed: $e';
      notifyListeners();
    }
  }

  Future<List<BluetoothInfo>> scanDevices() async {
    if (kIsWeb) {
      _availableDevices = [
        BluetoothInfo(name: 'Virtual Thermal Printer (58mm)', macAdress: '00:11:22:33:44:55'),
        BluetoothInfo(name: 'Virtual POS Printer (80mm)', macAdress: '66:77:88:99:AA:BB'),
      ];
      _statusMessage = 'Found ${_availableDevices.length} virtual printer(s)';
      notifyListeners();
      return _availableDevices;
    }

    try {
      await checkStatus();
      if (!_isBluetoothEnabled) {
        _statusMessage = 'Bluetooth is turned off. Please enable it.';
        notifyListeners();
        return [];
      }

      final devices = await PrintBluetoothThermal.pairedBluetooths;
      _availableDevices = devices;
      _statusMessage = 'Found ${devices.length} paired device(s).';
      notifyListeners();
      return devices;
    } catch (e) {
      _statusMessage = 'Failed to scan devices: $e';
      notifyListeners();
      return [];
    }
  }

  Future<bool> connect(BluetoothInfo device) async {
    _connectionState = PrinterConnectionState.connecting;
    _statusMessage = 'Connecting to ${device.name}...';
    notifyListeners();

    if (kIsWeb) {
      await Future.delayed(const Duration(milliseconds: 400));
      _connectedDevice = device;
      _connectionState = PrinterConnectionState.connected;
      _statusMessage = 'Connected to ${device.name}';
      notifyListeners();
      return true;
    }

    try {
      final bool result = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );

      if (result) {
        _connectedDevice = device;
        _connectionState = PrinterConnectionState.connected;
        _statusMessage = 'Connected to ${device.name}';
      } else {
        _connectionState = PrinterConnectionState.disconnected;
        _statusMessage = 'Connection to ${device.name} failed';
      }
      notifyListeners();
      return result;
    } catch (e) {
      _connectionState = PrinterConnectionState.disconnected;
      _statusMessage = 'Connection error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> disconnect() async {
    if (kIsWeb) {
      _connectedDevice = null;
      _connectionState = PrinterConnectionState.disconnected;
      _statusMessage = 'Printer disconnected';
      notifyListeners();
      return true;
    }

    try {
      final bool result = await PrintBluetoothThermal.disconnect;
      _connectedDevice = null;
      _connectionState = PrinterConnectionState.disconnected;
      _statusMessage = 'Printer disconnected';
      notifyListeners();
      return result;
    } catch (e) {
      _statusMessage = 'Disconnect error: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> printBytes(List<int> bytes) async {
    if (_connectionState != PrinterConnectionState.connected) {
      _statusMessage = 'No printer connected!';
      notifyListeners();
      return false;
    }

    if (kIsWeb) {
      _statusMessage = 'Printed successfully (Virtual Device)';
      notifyListeners();
      return true;
    }

    try {
      final bool result = await PrintBluetoothThermal.writeBytes(bytes);
      if (result) {
        _statusMessage = 'Printed successfully';
      } else {
        _statusMessage = 'Failed to send data to printer';
      }
      notifyListeners();
      return result;
    } catch (e) {
      _statusMessage = 'Print error: $e';
      notifyListeners();
      return false;
    }
  }
}
