import 'package:flutter_riverpod/flutter_riverpod.dart';

final syncStatusProvider = StateNotifierProvider<SyncStatusNotifier, int>((ref) {
  return SyncStatusNotifier();
});

class SyncStatusNotifier extends StateNotifier<int> {
  SyncStatusNotifier() : super(0);

  Future<void> processSyncQueue() async {
    state = 0;
  }

  Future<void> triggerSync() async {
    state = 0;
  }
}
