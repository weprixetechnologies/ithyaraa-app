import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/coin_balance.dart';
import '../../domain/entities/coin_history.dart';
import '../../domain/entities/locked_coin.dart';
import '../providers/profile_api_providers.dart';

/// Controller for managing Ithyaraa Coins balance
final coinBalanceProvider = AsyncNotifierProvider<CoinBalanceController, CoinBalanceEntity>(() {
  return CoinBalanceController();
});

class CoinBalanceController extends AsyncNotifier<CoinBalanceEntity> {
  @override
  Future<CoinBalanceEntity> build() async {
    final repository = ref.read(profileRepositoryProvider);
    return await repository.getCoinBalance();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      return await repository.getCoinBalance();
    });
  }

  Future<void> redeemCoins(int coins) async {
    final repository = ref.read(profileRepositoryProvider);
    await repository.redeemCoins(coins);
    await refresh();
  }
}

/// Controller for managing Ithyaraa Coins history
final coinHistoryProvider = AsyncNotifierProvider.family<CoinHistoryController, CoinHistoryResponseEntity, int>(
  CoinHistoryController.new,
);

class CoinHistoryController extends FamilyAsyncNotifier<CoinHistoryResponseEntity, int> {
  @override
  Future<CoinHistoryResponseEntity> build(int arg) async {
    final repository = ref.read(profileRepositoryProvider);
    return await repository.getCoinHistory(arg);
  }
}

/// Controller for managing locked coins breakdown
final lockedCoinsProvider = AsyncNotifierProvider<LockedCoinsController, LockedCoinsResponseEntity>(() {
  return LockedCoinsController();
});

class LockedCoinsController extends AsyncNotifier<LockedCoinsResponseEntity> {
  @override
  Future<LockedCoinsResponseEntity> build() async {
    final repository = ref.read(profileRepositoryProvider);
    return await repository.getLockedCoinsBreakdown();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      return await repository.getLockedCoinsBreakdown();
    });
  }
}
