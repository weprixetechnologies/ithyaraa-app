import '../../domain/entities/locked_coin.dart';

class LockedCoinsResponse extends LockedCoinsResponseEntity {
  LockedCoinsResponse({
    required super.success,
    required super.lockedBalance,
    required super.items,
  });

  factory LockedCoinsResponse.fromJson(Map<String, dynamic> json) {
    return LockedCoinsResponse(
      success: json['success'] as bool? ?? false,
      lockedBalance: _parseInt(json['lockedBalance']),
      items: (json['items'] as List? ?? [])
          .map((e) => LockedCoinItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
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

class LockedCoinItemModel extends LockedCoinItemEntity {
  LockedCoinItemModel({
    super.orderID,
    required super.coins,
    super.redeemableAt,
  });

  factory LockedCoinItemModel.fromJson(Map<String, dynamic> json) {
    return LockedCoinItemModel(
      orderID: json['orderID']?.toString(),
      coins: (json['coins'] is String)
          ? int.tryParse(json['coins']) ?? 0
          : (json['coins'] as num? ?? 0).toInt(),
      redeemableAt: json['redeemableAt'] != null
          ? DateTime.parse(json['redeemableAt'] as String)
          : null,
    );
  }
}
