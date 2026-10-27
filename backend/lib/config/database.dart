import 'package:dotenv/dotenv.dart';
import 'package:mysql_client/mysql_client.dart';

class Database {
  static MySQLConnection? _connection;

  static Future<MySQLConnection> getConnection() async {
    if (_connection != null && _connection!.connected) {
      return _connection!;
    }

    final env = DotEnv(includePlatformEnvironment: true)..load();
    final rawHost = env['DB_HOST'] ?? '127.0.0.1';
    final host = rawHost == 'localhost' ? '127.0.0.1' : rawHost;
    final port = int.tryParse(env['DB_PORT'] ?? '3306') ?? 3306;
    final db = env['DB_NAME'] ?? 'folks';
    final user = env['DB_USER'] ?? 'root';
    final password = env['DB_PASSWORD'] ?? '';

    try {
      final conn = await MySQLConnection.createConnection(
        host: host,
        port: port,
        userName: user,
        password: password,
        databaseName: db,
        secure: false,
      );
      await conn.connect();
      _connection = conn;
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
