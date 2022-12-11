import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:db/db.dart' as db;

part 'models.freezed.dart';

part 'models.g.dart';

@freezed
class User with _$User implements db.UserView {
  const factory User({
    required int id,
    required String name,
  }) = _USer;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  factory User.fromDb(db.User dbUser) {
    return User(
      id: dbUser.id,
      name: dbUser.name,
    );
  }
}
