import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../widgets/controle_acesso.dart';

class FuncionariosScreen extends StatefulWidget {
  const FuncionariosScreen({super.key});

  @override
  State<FuncionariosScreen> createState() => _FuncionariosScreenState();
}

class _FuncionariosScreenState extends State<FuncionariosScreen> {
  int _activeTab = 0; // 0 = Funcionários & Permissões, 1 = Cadastrar Funções

  List<UserProfile> _funcionarios = [];
  int _selectedIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  late String _editingTipo;
  late UserPermissions _editingPermissions;

  // Aba Funções
  List<JobFunction> _functions = [];
  final _fnNameController = TextEditingController();
  final _fnDeptController = TextEditingController(text: 'Folks RH - Recrutamento & Seleção');
  String _newFnTipo = 'analista';
  UserPermissions _newFnPermissions = UserPermissions.forTipo('analista');
  bool _isCreatingFn = false;

  static const List<Map<String, String>> _niveis = [
    {'value': 'admin', 'label': 'Administrador (Acesso Total)'},
    {'value': 'gestor', 'label': 'Gestor (Nível Gerencial)'},
    {'value': 'analista', 'label': 'Analista (Nível Intermediário)'},
    {'value': 'assistente', 'label': 'Assistente (Nível Operacional)'},
    {'value': 'auxiliar', 'label': 'Auxiliar (Nível Básico)'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _fnNameController.dispose();
    _fnDeptController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final results = await Future.wait([
      ApiService.listarFuncionarios(),
      ApiService.listarFuncoes(),
    ]);

    if (!mounted) return;
    setState(() {
      _funcionarios = List.from(results[0] as List<UserProfile>);
      _functions = List.from(results[1] as List<JobFunction>);
      _isLoading = false;
      if (_funcionarios.isNotEmpty) {
        _selectFuncionario(0);
      }
    });
  }

  void _selectFuncionario(int index) {
    final f = _funcionarios[index];
    setState(() {
      _selectedIndex = index;
      _editingTipo = f.tipo.toLowerCase();
      _editingPermissions = f.permissions;
    });
  }

  Future<void> _salvarPermissoes() async {
    if (_funcionarios.isEmpty) return;
    final target = _funcionarios[_selectedIndex];
    final id = target.id ?? (_selectedIndex + 1);

    setState(() => _isSaving = true);
    final updated = await ApiService.salvarPermissoes(
      userId: id,
      tipo: _editingTipo,
      permissions: _editingPermissions,
    );

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (updated != null) {
        _funcionarios[_selectedIndex] = updated;
      }
    });

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permissões de ${target.name} salvas com sucesso no MySQL!'),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _createFunction() async {
    final name = _fnNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe o nome da função.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isCreatingFn = true);
    final created = await ApiService.cadastrarFuncao(
      nome: name,
      tipo: _newFnTipo,
      departamento: _fnDeptController.text.trim().isEmpty
          ? 'Folks RH - Recrutamento & Seleção'
          : _fnDeptController.text.trim(),
      permissions: _newFnPermissions,
    );

    if (!mounted) return;
    setState(() {
      _isCreatingFn = false;
      _functions = List.from(FunctionSession.functions);
      _fnNameController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Função "${created.nome}" cadastrada com sucesso!'),
        backgroundColor: AppColors.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.current;
    final temPermissao = user.permissions.funcionarios || user.isAdmin;

    return ControleAcessoGuard(
      hasPermission: temPermissao,
      moduloNome: 'Funcionários e Permissões',
      child: Scaffold(
        backgroundColor: AppColors.bgMain,
        appBar: AppBar(
          backgroundColor: AppColors.bgMain,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'GESTÃO DE FUNCIONÁRIOS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                children: [
                  // Seletor de abas
                  Container(
                    height: 40,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.bgCard,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeTab = 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _activeTab == 0 ? AppColors.primaryNavy : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Funcionários & Permissões',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeTab = 1),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _activeTab == 1 ? AppColors.primaryNavy : Colors.transparent,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Cadastrar Funções',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_activeTab == 0) _buildFuncionariosTab() else _buildFuncoesTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildFuncionariosTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'SELECIONE O FUNCIONÁRIO:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 68,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _funcionarios.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final f = _funcionarios[index];
              final isSelected = index == _selectedIndex;

              return InkWell(
                onTap: () => _selectFuncionario(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryNavy : AppColors.bgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.borderFocused : AppColors.borderSubtle,
                      width: isSelected ? 1.4 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: f.isAdmin ? Colors.amber.shade700 : Colors.white24,
                        child: Text(
                          f.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            f.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${f.role} • ${f.tipo.toUpperCase()}',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'NÍVEL DE ACESSO DO FUNCIONÁRIO:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: AppColors.bgInput,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _niveis.any((n) => n['value'] == _editingTipo) ? _editingTipo : 'assistente',
              dropdownColor: AppColors.bgInput,
              isExpanded: true,
              style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w600),
              items: _niveis
                  .map(
                    (n) => DropdownMenuItem<String>(
                      value: n['value'],
                      child: Text(n['label']!),
                    ),
                  )
                  .toList(),
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  _editingTipo = val;
                  _editingPermissions = UserPermissions.forTipo(val);
                });
              },
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'PERMISSÕES DE MÓDULOS (CONTROLE DO SISTEMA):',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              _buildPermSwitch(
                title: 'Módulo de Clientes',
                subtitle: 'Permite visualizar e cadastrar clientes',
                icon: Icons.people_outline,
                value: _editingPermissions.clientes,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(clientes: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Módulo de Tarefas',
                subtitle: 'Permite acessar e gerenciar tarefas da equipe',
                icon: Icons.assignment_outlined,
                value: _editingPermissions.tarefas,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(tarefas: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Módulo de Notificações',
                subtitle: 'Permite receber e gerenciar notificações push',
                icon: Icons.notifications_none_outlined,
                value: _editingPermissions.notificacoes,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(notificacoes: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Módulo de Funcionários (Administrador)',
                subtitle: 'Permite gerenciar funcionários, cargos e permissões',
                icon: Icons.admin_panel_settings_outlined,
                value: _editingPermissions.funcionarios,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(funcionarios: v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SUB-PERMISSÕES ESPECÍFICAS DE TAREFAS:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            children: [
              _buildPermSwitch(
                title: 'Criar Novas Tarefas',
                subtitle: 'Permite cadastrar novas demandas na equipe',
                icon: Icons.add_task,
                value: _editingPermissions.criarTarefas,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(criarTarefas: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Editar Tarefas',
                subtitle: 'Permite alterar título, prioridade, prazo e gestor',
                icon: Icons.edit_note,
                value: _editingPermissions.editarTarefas,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(editarTarefas: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Excluir Tarefas',
                subtitle: 'Permite deletar tarefas do sistema',
                icon: Icons.delete_outline,
                value: _editingPermissions.excluirTarefas,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(excluirTarefas: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Alterar Status de Tarefas',
                subtitle: 'Permite transitar entre Pendente, Em Andamento e Concluído',
                icon: Icons.sync_alt,
                value: _editingPermissions.alterarStatus,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(alterarStatus: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Visualizar Desempenho e Métricas',
                subtitle: 'Libera acesso aos indicadores da equipe',
                icon: Icons.pie_chart_outline,
                value: _editingPermissions.verDesempenho,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(verDesempenho: v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _salvarPermissoes,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_outlined, color: Colors.white),
          label: Text(
            _isSaving ? 'SALVANDO NO BANCO...' : 'SALVAR PERMISSÕES NO MYSQL',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryNavy,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: AppColors.borderStrong),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFuncoesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CADASTRAR NOVA FUNÇÃO / CARGO',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _fnNameController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: AppColors.darkInputDecoration(
                  labelText: 'Nome da Função *',
                  hintText: 'Ex: Coordenador de Recrutamento',
                  prefixIcon: Icons.work_outline,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _newFnTipo,
                dropdownColor: AppColors.bgCard,
                decoration: AppColors.darkInputDecoration(
                  labelText: 'Nível Base de Permissão',
                  prefixIcon: Icons.badge_outlined,
                ),
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                items: _niveis
                    .map((n) => DropdownMenuItem(
                          value: n['value'],
                          child: Text(n['label']!, style: const TextStyle(color: Colors.white)),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _newFnTipo = val;
                      _newFnPermissions = UserPermissions.forTipo(val);
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _fnDeptController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: AppColors.darkInputDecoration(
                  labelText: 'Setor / Departamento',
                  prefixIcon: Icons.business_outlined,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _isCreatingFn ? null : _createFunction,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  _isCreatingFn ? 'CADASTRANDO...' : 'CADASTRAR FUNÇÃO',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: AppColors.borderStrong),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'FUNÇÕES ATIVAS NO BANCO DE DADOS:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ..._functions.map((fn) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(
                children: [
                  const Icon(Icons.work_outline, color: Colors.white70, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fn.nome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${fn.departamento} • ${fn.tipo.toUpperCase()}',
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildPermSwitch({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      dense: true,
      secondary: Icon(icon, color: value ? Colors.amberAccent : Colors.white54, size: 20),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 11),
      ),
      value: value,
      activeThumbColor: Colors.greenAccent,
      onChanged: onChanged,
    );
  }
}
