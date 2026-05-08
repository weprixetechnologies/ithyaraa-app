import '../../domain/entities/coin_history.dart';

class CoinHistoryResponse extends CoinHistoryResponseEntity {
  CoinHistoryResponse({
    required super.rows,
    required super.total,
  });

  factory CoinHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CoinHistoryResponse(
      rows: (json['rows'] as List? ?? [])
          .map((e) => CoinHistoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
    );
  }
}

class CoinHistoryModel extends CoinHistoryEntity {
  CoinHistoryModel({
    required super.txnID,
    required super.type,
    required super.coins,
    super.refType,
    super.refID,
    required super.createdAt,
  });

  factory CoinHistoryModel.fromJson(Map<String, dynamic> json) {
    return CoinHistoryModel(
      txnID: _parseInt(json['txnID']),
      type: json['type'] as String? ?? 'earn',
      coins: _parseInt(json['coins']),
      refType: json['refType'] as String?,
      refID: json['refID']?.toString(),
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
