enum AppRoute {
  home('/'),
  welcome('/welcome'),
  login('/login'),
  cadastro('/cadastro'),
  inicio('/inicio'),
  dashboard('/dashboard'),
  funcionarios('/funcionarios'),
  clientes('/clientes'),
  tarefas('/tarefas'),
  desempenho('/desempenho'),
  notificacoes('/notificacoes'),
  perfil('/perfil'),
  notFound('/not-found');

  const AppRoute(this.path);

  final String path;
}
