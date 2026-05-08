import '../../domain/entities/coin_balance.dart';

class CoinBalanceModel extends CoinBalanceEntity {
  CoinBalanceModel({
    required super.balance,
    required super.redeemableBalance,
    required super.lockedBalance,
  });

  factory CoinBalanceModel.fromJson(Map<String, dynamic> json) {
    return CoinBalanceModel(
      balance: _parseInt(json['balance']),
      redeemableBalance: _parseInt(json['redeemableBalance']),
      lockedBalance: _parseInt(json['lockedBalance']),
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
