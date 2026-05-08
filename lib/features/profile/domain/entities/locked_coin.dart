class LockedCoinsResponseEntity {
  final bool success;
  final int lockedBalance;
  final List<LockedCoinItemEntity> items;

  const LockedCoinsResponseEntity({
    required this.success,
    required this.lockedBalance,
    required this.items,
  });
}

class LockedCoinItemEntity {
  final String? orderID;
  final int coins;
  final DateTime? redeemableAt;

  const LockedCoinItemEntity({
    this.orderID,
    required this.coins,
    this.redeemableAt,
  });
}
