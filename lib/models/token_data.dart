class TokenData {
  final String id;
  final String tokenNumber;
  final String department;
  final String? counter;
  final DateTime timestamp;
  final String? note;
  final String? businessName;

  const TokenData({
    required this.id,
    required this.tokenNumber,
    required this.department,
    this.counter,
    required this.timestamp,
    this.note,
    this.businessName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tokenNumber': tokenNumber,
      'department': department,
      'counter': counter,
      'timestamp': timestamp.toIso8601String(),
      'note': note,
      'businessName': businessName,
    };
  }

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      id: json['id'] as String,
      tokenNumber: json['tokenNumber'] as String,
      department: json['department'] as String? ?? 'General',
      counter: json['counter'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      note: json['note'] as String?,
      businessName: json['businessName'] as String?,
    );
  }

  TokenData copyWith({
    String? id,
    String? tokenNumber,
    String? department,
    String? counter,
    DateTime? timestamp,
    String? note,
    String? businessName,
  }) {
    return TokenData(
      id: id ?? this.id,
      tokenNumber: tokenNumber ?? this.tokenNumber,
      department: department ?? this.department,
      counter: counter ?? this.counter,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      businessName: businessName ?? this.businessName,
    );
  }
}
