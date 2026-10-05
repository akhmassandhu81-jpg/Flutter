// Legacy sync engine superseded by local-first SQLite architecture.
class SyncEngine {
  int get pendingCount => 0;
  Future<void> processSyncQueue() async {}
}
