import 'package:dotenv/dotenv.dart';
import 'package:mysql1/mysql1.dart';

class Database {
  static MySqlConnection? _connection;


  static Future<MySqlConnection> getConnection() async {

    if (_connection != null) {
      return _connection!;
    }


    final env = DotEnv(includePlatformEnvironment: true)..load();
    final host = env['DB_HOST'] ?? 'localhost';
    final port = int.tryParse(env['DB_PORT'] ?? '3306') ?? 3306;
    final db = env['DB_NAME'] ?? 'folks';
    final user = env['DB_USER'] ?? 'root';
    final password = env['DB_PASSWORD'] ?? '';

    final settings = ConnectionSettings(
      host: host,
      port: port,
      user: user,
      password: password,
      db: db,
    );

    try {
      _connection = await MySqlConnection.connect(settings);
      print('✅ [MySQL] Conectado com sucesso ao banco de dados "$db"!');
      return _connection!;
    } catch (e) {
      print('❌ [MySQL] Erro ao conectar ao MySQL: $e');
      rethrow;
    }
  }

  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
