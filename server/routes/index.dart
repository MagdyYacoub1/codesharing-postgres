import 'dart:async';
import 'dart:convert';
import 'package:dart_frog/dart_frog.dart';
import 'package:db/db.dart' as db;
import 'package:shared/shared.dart';
import 'package:stormberry/internals.dart';

FutureOr<Response> onRequest(RequestContext context) async {
  final db = context.read<Database>();
  final dbUser = await db.users.queryUser(1);
  if (dbUser == null) {
    return Response(body: 'Not found', statusCode: 404);
  }

  final sharedUser = User.fromDb(dbUser);
  return Response.json(
    body: sharedUser.toJson(),
  );
}
