enum SyncStatus { pending, syncing, synced, failed }
enum OperationType { create, update, delete }

class SyncOperation {
  final String id;
  final String entityType; // product, category, sale, purchase, customer, supplier, expense, settings
  final String entityId;
  final OperationType operationType;
  final Map<String, dynamic> payload;
  final DateTime timestamp;
  final SyncStatus status;
  final int retryCount;
  final String? lastError;

  SyncOperation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
    DateTime? timestamp,
    this.status = SyncStatus.pending,
    this.retryCount = 0,
    this.lastError,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'operationType': operationType.name,
      'payload': payload,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'retryCount': retryCount,
      'lastError': lastError,
    };
  }

  factory SyncOperation.fromMap(Map<dynamic, dynamic> map) {
    return SyncOperation(
      id: map['id']?.toString() ?? '',
      entityType: map['entityType']?.toString() ?? '',
      entityId: map['entityId']?.toString() ?? '',
      operationType: OperationType.values.firstWhere(
        (e) => e.name == map['operationType'],
        orElse: () => OperationType.create,
      ),
      payload: map['payload'] != null ? Map<String, dynamic>.from(map['payload'] as Map) : {},
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: SyncStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => SyncStatus.pending,
      ),
      retryCount: (map['retryCount'] as num?)?.toInt() ?? 0,
      lastError: map['lastError']?.toString(),
    );
  }

  SyncOperation copyWith({
    SyncStatus? status,
    int? retryCount,
    String? lastError,
  }) {
    return SyncOperation(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payload: payload,
      timestamp: timestamp,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
    );
  }
}
