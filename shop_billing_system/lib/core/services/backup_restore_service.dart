import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'sqlite_database_service.dart';

class BackupRestoreService {
  static final BackupRestoreService _instance = BackupRestoreService._internal();
  factory BackupRestoreService() => _instance;
  BackupRestoreService._internal();

  /// Get the active SQLite database file path on the client's Windows PC
  Future<String> getActiveDatabasePath() async {
    Directory appDocDir = await getApplicationSupportDirectory();
    return join(appDocDir.path, 'ShopBilling', 'shop_billing.db');
  }

  /// Get the local backup directory path
  Future<Directory> getLocalBackupDirectory() async {
    Directory appDocDir = await getApplicationSupportDirectory();
    final dir = Directory(join(appDocDir.path, 'ShopBilling', 'Backups'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Verify SQLite database integrity using PRAGMA integrity_check
  Future<bool> verifyDatabaseIntegrity(String dbPath) async {
    try {
      final db = await openDatabase(dbPath, readOnly: true);
      final result = await db.rawQuery('PRAGMA integrity_check;');
      await db.close();
      if (result.isNotEmpty && result.first.values.first.toString().toLowerCase() == 'ok') {
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Create a professional manual backup of the active database
  Future<String?> createManualBackup(String destinationFilePath) async {
    try {
      final activePath = await getActiveDatabasePath();
      final activeFile = File(activePath);

      if (!await activeFile.exists()) {
        throw Exception('Active database file not found.');
      }

      // Check integrity before backup
      bool isHealthy = await verifyDatabaseIntegrity(activePath);
      if (!isHealthy) {
        throw Exception('Database integrity check failed. Cannot create backup.');
      }

      // Close active database connections temporarily to ensure file consistency
      final sqliteService = SqliteDatabaseService();
      final db = await sqliteService.database;
      // Execute WAL checkpoint if applicable
      await db.rawQuery('PRAGMA wal_checkpoint(FULL);');

      // Copy file to destination
      await activeFile.copy(destinationFilePath);
      return destinationFilePath;
    } catch (e) {
      throw Exception('Backup failed: $e');
    }
  }

  /// Create an automatic Pre-Restore safety backup
  Future<String> createPreRestoreSafetyBackup() async {
    final backupDir = await getLocalBackupDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(RegExp(r'[:T-]'), '').substring(0, 14);
    final safetyPath = join(backupDir.path, 'PreRestore_Backup_$timestamp.sbbak');
    await createManualBackup(safetyPath);
    return safetyPath;
  }

  /// Restore database from a selected backup file with safety verification
  Future<void> restoreDatabase(String backupFilePath) async {
    try {
      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        throw Exception('Selected backup file does not exist.');
      }

      // 1. Verify integrity of the backup file
      bool isValid = await verifyDatabaseIntegrity(backupFilePath);
      if (!isValid) {
        throw Exception('Selected backup file is corrupted or invalid SQLite database.');
      }

      // 2. Validate essential table schema in the backup
      final testDb = await openDatabase(backupFilePath, readOnly: true);
      final tables = await testDb.rawQuery("SELECT name FROM sqlite_master WHERE type='table';");
      await testDb.close();

      final tableNames = tables.map((t) => t['name']?.toString()).toList();
      const requiredTables = ['products', 'categories', 'customers', 'suppliers', 'sales', 'purchases', 'expenses', 'settings'];
      for (var req in requiredTables) {
        if (!tableNames.contains(req)) {
          throw Exception('Invalid backup: Missing required business table "$req".');
        }
      }

      // 3. Create pre-restore safety backup of current active database
      await createPreRestoreSafetyBackup();

      // 4. Close current active database instance
      final activePath = await getActiveDatabasePath();
      final sqliteService = SqliteDatabaseService();
      final currentDb = await sqliteService.database;
      await currentDb.close();

      // 5. Replace active database file with the backup file
      await backupFile.copy(activePath);
    } catch (e) {
      throw Exception('Restore failed: $e');
    }
  }
}
