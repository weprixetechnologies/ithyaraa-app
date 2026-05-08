class CoinBalanceEntity {
  final int balance;
  final int redeemableBalance;
  final int lockedBalance;

  const CoinBalanceEntity({
    required this.balance,
    required this.redeemableBalance,
    required this.lockedBalance,
  });
}
