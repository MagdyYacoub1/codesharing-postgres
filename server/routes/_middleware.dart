import 'package:dart_frog/dart_frog.dart';
import 'package:stormberry/stormberry.dart';

final db = Database(
  host: 'localhost',
  port: 5432,
  database: 'postgres',
  user: 'postgres',
  password: 'changeme',
  useSSL: false,
  isUnixSocket: false,
);

Handler middleware(Handler handler) {
  /*return (context) async {
    // Execute code before request is handled.

    // Forward the request to the respective handler.
    final response = await handler(context);

    // Execute code after request is handled.

    // Return a response.
    return response;
  };*/
  return handler.use(provider<Database>((context) => db));
}
