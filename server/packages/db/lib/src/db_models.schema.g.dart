// ignore_for_file: prefer_relative_imports
import 'package:stormberry/internals.dart';

import 'db_models.dart';

extension Repositories on Database {
  UserRepository get users => UserRepository._(this);
}

final registry = ModelRegistry({});

abstract class UserRepository
    implements
        ModelRepository,
        KeyedModelRepositoryInsert<UserInsertRequest>,
        ModelRepositoryUpdate<UserUpdateRequest>,
        ModelRepositoryDelete<int> {
  factory UserRepository._(Database db) = _UserRepository;

  Future<User?> queryUser(int id);
  Future<List<User>> queryUsers([QueryParams? params]);
}

class _UserRepository extends BaseRepository
    with
        KeyedRepositoryInsertMixin<UserInsertRequest>,
        RepositoryUpdateMixin<UserUpdateRequest>,
        RepositoryDeleteMixin<int>
    implements UserRepository {
  _UserRepository(Database db) : super(db: db);

  @override
  Future<User?> queryUser(int id) {
    return queryOne(id, UserQueryable());
  }

  @override
  Future<List<User>> queryUsers([QueryParams? params]) {
    return queryMany(UserQueryable(), params);
  }

  @override
  Future<List<int>> insert(Database db, List<UserInsertRequest> requests) async {
    if (requests.isEmpty) return [];
    var rows = await db.query(requests.map((r) => "SELECT nextval('users_id_seq') as \"id\"").join('\nUNION ALL\n'));
    var autoIncrements = rows.map((r) => r.toColumnMap()).toList();

    await db.query(
      'INSERT INTO "users" ( "id", "name" )\n'
      'VALUES ${requests.map((r) => '( ${registry.encode(autoIncrements[requests.indexOf(r)]['id'])}, ${registry.encode(r.name)} )').join(', ')}\n',
    );

    return autoIncrements.map<int>((m) => registry.decode(m['id'])).toList();
  }

  @override
  Future<void> update(Database db, List<UserUpdateRequest> requests) async {
    if (requests.isEmpty) return;
    await db.query(
      'UPDATE "users"\n'
      'SET "name" = COALESCE(UPDATED."name"::text, "users"."name")\n'
      'FROM ( VALUES ${requests.map((r) => '( ${registry.encode(r.id)}, ${registry.encode(r.name)} )').join(', ')} )\n'
      'AS UPDATED("id", "name")\n'
      'WHERE "users"."id" = UPDATED."id"',
    );
  }

  @override
  Future<void> delete(Database db, List<int> keys) async {
    if (keys.isEmpty) return;
    await db.query(
      'DELETE FROM "users"\n'
      'WHERE "users"."id" IN ( ${keys.map((k) => registry.encode(k)).join(',')} )',
    );
  }
}

class UserInsertRequest {
  UserInsertRequest({required this.name});
  String name;
}

class UserUpdateRequest {
  UserUpdateRequest({required this.id, this.name});
  int id;
  String? name;
}

class UserQueryable extends KeyedViewQueryable<User, int> {
  @override
  String get keyName => 'id';

  @override
  String encodeKey(int key) => registry.encode(key);

  @override
  String get tableName => 'users_view';

  @override
  String get tableAlias => 'users';

  @override
  User decode(TypedMap map) => UserView(id: map.get('id', registry.decode), name: map.get('name', registry.decode));
}

class UserView implements User {
  UserView({required this.id, required this.name});

  @override
  final int id;
  @override
  final String name;
}
