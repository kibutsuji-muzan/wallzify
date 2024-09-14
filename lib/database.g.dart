// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  PictureDao? _pictureDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Picture` (`id` TEXT NOT NULL, `imageUrl` TEXT NOT NULL, `thumbnailUrl` TEXT NOT NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  PictureDao get pictureDao {
    return _pictureDaoInstance ??= _$PictureDao(database, changeListener);
  }
}

class _$PictureDao extends PictureDao {
  _$PictureDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database, changeListener),
        _pictureInsertionAdapter = InsertionAdapter(
            database,
            'Picture',
            (Picture item) => <String, Object?>{
                  'id': item.id,
                  'imageUrl': item.imageUrl,
                  'thumbnailUrl': item.thumbnailUrl
                },
            changeListener),
        _pictureDeletionAdapter = DeletionAdapter(
            database,
            'Picture',
            ['id'],
            (Picture item) => <String, Object?>{
                  'id': item.id,
                  'imageUrl': item.imageUrl,
                  'thumbnailUrl': item.thumbnailUrl
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Picture> _pictureInsertionAdapter;

  final DeletionAdapter<Picture> _pictureDeletionAdapter;

  @override
  Future<List<Picture>> getAllPictures() async {
    return _queryAdapter.queryList('SELECT * FROM Picture',
        mapper: (Map<String, Object?> row) => Picture(
            id: row['id'] as String,
            imageUrl: row['imageUrl'] as String,
            thumbnailUrl: row['thumbnailUrl'] as String));
  }

  @override
  Stream<Picture?> getPictureById(String id) {
    return _queryAdapter.queryStream('SELECT * FROM Picture WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Picture(
            id: row['id'] as String,
            imageUrl: row['imageUrl'] as String,
            thumbnailUrl: row['thumbnailUrl'] as String),
        arguments: [id],
        queryableName: 'Picture',
        isView: false);
  }

  @override
  Future<void> insertPicture(Picture pic) async {
    await _pictureInsertionAdapter.insert(pic, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePicture(Picture pic) async {
    await _pictureDeletionAdapter.delete(pic);
  }
}
