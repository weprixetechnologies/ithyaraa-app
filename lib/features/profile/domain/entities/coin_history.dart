class CoinHistoryResponseEntity {
  final List<CoinHistoryEntity> rows;
  final int total;

  const CoinHistoryResponseEntity({
    required this.rows,
    required this.total,
  });
}

class CoinHistoryEntity {
  final int txnID;
  final String type;
  final int coins;
  final String? refType;
  final String? refID;
  final DateTime createdAt;

  const CoinHistoryEntity({
    required this.txnID,
    required this.type,
    required this.coins,
    this.refType,
    this.refID,
    required this.createdAt,
  });
}
