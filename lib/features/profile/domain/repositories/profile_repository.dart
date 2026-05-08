import '../entities/profile.dart';
import '../entities/coin_balance.dart';
import '../entities/coin_history.dart';
import '../entities/locked_coin.dart';
import '../entities/return_history.dart';

/// Profile repository interface (domain layer)
abstract class ProfileRepository {
  Future<ProfileEntity> getProfileDetails();
  Future<ProfileEntity> updateProfile({
    String? name,
    String? profilePhoto,
  });
  Future<void> sendVerificationOtp(String identifier);
  Future<void> verifyOtp(String identifier, String otp);

  // Coins
  Future<CoinBalanceEntity> getCoinBalance();
  Future<CoinHistoryResponseEntity> getCoinHistory(int page);
  Future<LockedCoinsResponseEntity> getLockedCoinsBreakdown();
  Future<void> redeemCoins(int coins);

  // Returns
  Future<ReturnHistoryResponseEntity> getReturnHistory();
}
