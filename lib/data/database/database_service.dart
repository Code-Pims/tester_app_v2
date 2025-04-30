import 'dart:async';

import 'package:dojodex_common/models/sp_message/sp_message_converter.dart';
import 'package:dojodex_instructor/data/database/databases.dart';
import 'package:logger/logger.dart';
import 'package:mutex/mutex.dart';
import 'package:sembast/sembast_io.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// TABLES are defined by of [Model]s class you want to store
class DatabaseService {
  final Database db;
  final Logger logger;
  final Mutex mutex = Mutex();

  DatabaseService({required this.db, required this.logger});

  Future<Map<String, dynamic>?> get(String table, String id) async {
    Map<String, dynamic>? value =
        await stringMapStoreFactory.store('Store $table').record(id).get(db);
    return value;
  }

  /// Gets multiple values
  /// [finder] serves for queries
  Future<List<Map<String, dynamic>>?> getAll(
    String table, {
    Finder? finder,
  }) async {
    var snapshots = await stringMapStoreFactory.store('Store $table').find(
          db,
          finder: finder,
        );
    List<Map<String, dynamic>> records = snapshots.map((e) => e.value).toList();
    return records;
  }

  Future<void> insertOrUpdate(
    String table,
    String id,
    Map<String, dynamic> value, {
    DatabaseClient? txn,
  }) async {
    await stringMapStoreFactory
        .store('Store $table')
        .record(id)
        .put(txn ?? db, value);
  }

  /// Inserts multiple values
  /// NOTE: This partly assumes each value has id. If none it stores without id
  Future<void> insertAll(
    String table,
    List<Map<String, dynamic>> values, {
    DatabaseClient? txn,
  }) async {
    StoreRef store = stringMapStoreFactory.store('Store $table');

    Future execute(DatabaseClient txn) async {
      for (Map<String, dynamic> record in values) {
        var id = record['id'];

        if (id != null) {
          await store.record(id).put(txn, record);
        } else {
          await store.add(txn, record);
        }
      }
    }

    try {
      if (txn != null) {
        await execute(txn);
      } else {
        await db.transaction((Transaction txn) async {
          await execute(txn);
        });
      }
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> delete(
    String table,
    String id, {
    DatabaseClient? txn,
  }) async {
    await stringMapStoreFactory
        .store('Store $table')
        .record(id)
        .delete(txn ?? db);
  }

  Future<void> deleteAll(
    String table, {
    Finder? finder,
    DatabaseClient? txn,
  }) async {
    if (finder != null) {
      List<RecordSnapshot<String, dynamic>> snapshots =
          await stringMapStoreFactory.store('Store $table').find(
                db,
                finder: finder,
              );

      Future execute(DatabaseClient txn) async {
        for (var record in snapshots) {
          await record.ref.delete(txn);
        }
      }

      if (txn != null) {
        await execute(txn);
      } else {
        await db.transaction((Transaction txn) async {
          await execute(txn);
        });
      }

      logger.w("Delete in $table executed: ${snapshots.length}");
    } else {
      StoreRef store = stringMapStoreFactory.store('Store $table');
      await store.delete(txn ?? db);
    }
  }

  /// Listens to a single value stream
  Stream<Map<String, dynamic>?> singleListen(String table, String id) {
    return stringMapStoreFactory
        .store('Store $table')
        .record(id)
        .onSnapshot(db)
        .map((event) => event?.value);
  }

  /// Listens to multiple values stream
  /// [finder] serves for queries
  Stream<List<Map<String, dynamic>>> multipleListen(
    String table, {
    Finder? finder,
  }) {
    return stringMapStoreFactory
        .store('Store $table')
        .query(
          finder: finder,
        )
        .onSnapshots(db)
        .map((event) => event.map((e) => e.value).toList());
  }

  Future<void> executeTransaction(
      FutureOr Function(DatabaseClient) transaction) async {
    try {
      await mutex.acquire();
      await db.transaction(transaction);
    } finally {
      mutex.release();
    }
  }

  /// Insert from Supabase
  Future<void> eventFromPostgressPayload(
    PostgresChangePayload payload,
  ) async {
    String table = payload.table;
    final data = const SPMessageConverter().fromJson(payload.newRecord);

    switch (payload.eventType) {
      case PostgresChangeEvent.insert || PostgresChangeEvent.update:
        await insertOrUpdate(
          table,
          data.id.toString(),
          data.toJson(),
        );
        break;
      case PostgresChangeEvent.delete:
        await delete(
          table,
          data.id.toString(),
        );
        break;

      default:
    }
  }

  /// WARNING: deletes everything and recreates database
  Future<void> clearDatabase() async {
    String path = db.path;
    await databaseFactoryIo.deleteDatabase(path);
    await databaseFactoryIo.openDatabase(path);
  }

  Future<void> deleteAllTables() async {
    List<String> tables = [
      UserDatabase().name,
      CurrentClub().name,
    ];
    for (String table in tables) {
      await deleteAll(table);
    }
  }
}
