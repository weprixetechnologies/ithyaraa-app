import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/profile_model.dart';
import '../../domain/entities/coin_balance.dart';
import '../../domain/entities/coin_history.dart';
import '../../domain/entities/locked_coin.dart';
import '../../domain/entities/return_history.dart';

/// Profile repository implementation (data layer)
class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ProfileEntity> getProfileDetails() async {
    try {
      final profile = await remoteDataSource.getProfileDetails();
      return profile;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ProfileEntity> updateProfile({
    String? name,
    String? profilePhoto,
  }) async {
    try {
      final profile = await remoteDataSource.updateProfile(
        name: name,
        profilePhoto: profilePhoto,
      );
      return profile;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendVerificationOtp(String identifier) async {
    try {
      await remoteDataSource.sendVerificationOtp(identifier);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> verifyOtp(String identifier, String otp) async {
    try {
      await remoteDataSource.verifyOtp(identifier, otp);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CoinBalanceEntity> getCoinBalance() async {
    return await remoteDataSource.getCoinBalance();
  }

  @override
  Future<CoinHistoryResponseEntity> getCoinHistory(int page) async {
    return await remoteDataSource.getCoinHistory(page);
  }

  @override
  Future<LockedCoinsResponseEntity> getLockedCoinsBreakdown() async {
    return await remoteDataSource.getLockedCoinsBreakdown();
  }

  @override
  Future<void> redeemCoins(int coins) async {
    await remoteDataSource.redeemCoins(coins);
  }

  @override
  Future<ReturnHistoryResponseEntity> getReturnHistory() async {
    return await remoteDataSource.getReturnHistory();
  }
}
