import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/return_history.dart';
import '../providers/profile_api_providers.dart';

/// Controller for managing Return History
final returnHistoryProvider = AsyncNotifierProvider<ReturnHistoryController, ReturnHistoryResponseEntity>(() {
  return ReturnHistoryController();
});

class ReturnHistoryController extends AsyncNotifier<ReturnHistoryResponseEntity> {
  @override
  Future<ReturnHistoryResponseEntity> build() async {
    final repository = ref.read(profileRepositoryProvider);
    return await repository.getReturnHistory();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(profileRepositoryProvider);
      return await repository.getReturnHistory();
    });
  }
}
