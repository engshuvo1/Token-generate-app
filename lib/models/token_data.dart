class TokenData {
  final String id;
  final String tokenNumber; // Required *, e.g. "001"
  final String serialNumber; // Required *, e.g. "A-015"
  final String? customerName; // Optional, e.g. "Shuvo"
  final String? contactNumber; // Optional, e.g. "017XXXXXXXX"
  final String? amount; // Optional, e.g. "500"
  final String time; // Required *, e.g. "02:30 PM"
  final DateTime date;
  final String? shopName;
  final String? address;
  final String? phone;

  const TokenData({
    required this.id,
    required this.tokenNumber,
    required this.serialNumber,
    this.customerName,
    this.contactNumber,
    this.amount,
    required this.time,
    required this.date,
    this.shopName,
    this.address,
    this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tokenNumber': tokenNumber,
      'serialNumber': serialNumber,
      'customerName': customerName,
      'contactNumber': contactNumber,
      'amount': amount,
      'time': time,
      'date': date.toIso8601String(),
      'shopName': shopName,
      'address': address,
      'phone': phone,
    };
  }

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      id: json['id'] as String,
      tokenNumber: json['tokenNumber'] as String,
      serialNumber: json['serialNumber'] as String? ?? '',
      customerName: json['customerName'] as String?,
      contactNumber: json['contactNumber'] as String?,
      amount: json['amount'] as String?,
      time: json['time'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      shopName: json['shopName'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
    );
  }

  TokenData copyWith({
    String? id,
    String? tokenNumber,
    String? serialNumber,
    String? customerName,
    String? contactNumber,
    String? amount,
    String? time,
    DateTime? date,
    String? shopName,
    String? address,
    String? phone,
  }) {
    return TokenData(
      id: id ?? this.id,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      serialNumber: serialNumber ?? this.serialNumber,
      customerName: customerName ?? this.customerName,
      contactNumber: contactNumber ?? this.contactNumber,
      amount: amount ?? this.amount,
      time: time ?? this.time,
      date: date ?? this.date,
      shopName: shopName ?? this.shopName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
    );
  }
}
