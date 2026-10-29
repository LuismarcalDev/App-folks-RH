import 'package:dotenv/dotenv.dart';
import 'package:mysql_client/mysql_client.dart';

class Database {
  static MySQLConnection? _connection;
  static bool _schemaChecked = false;

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

      if (!_schemaChecked) {
        await _ensureSchema(conn);
        _schemaChecked = true;
      }

      return _connection!;
    } catch (e) {
      print('❌ [MySQL] Erro ao conectar ao MySQL: $e');
      rethrow;
    }
  }

  static Future<void> _ensureSchema(MySQLConnection conn) async {
    try {
      await conn.execute('''
        CREATE TABLE IF NOT EXISTS permissoes_usuario (
          Usuario_Id INT NOT NULL PRIMARY KEY,
          Criar_Tarefas TINYINT(1) NOT NULL DEFAULT 0,
          Editar_Tarefas TINYINT(1) NOT NULL DEFAULT 1,
          Excluir_Tarefas TINYINT(1) NOT NULL DEFAULT 1,
          Alterar_Status TINYINT(1) NOT NULL DEFAULT 1,
          Ver_Desempenho TINYINT(1) NOT NULL DEFAULT 0,
          Gerenciar_Permissoes TINYINT(1) NOT NULL DEFAULT 0,
          CONSTRAINT fk_permissoes_usuario FOREIGN KEY (Usuario_Id) REFERENCES usuarios (Id) ON DELETE CASCADE ON UPDATE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
      ''');
    } catch (_) {}
  }

  static Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
