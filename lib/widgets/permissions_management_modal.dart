import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class PermissionsManagementModal extends StatefulWidget {
  final VoidCallback? onPermissionsChanged;
  final int initialTab; // 0 = Permissões de Usuários, 1 = Cadastrar Funções

  const PermissionsManagementModal({
    super.key,
    this.onPermissionsChanged,
    this.initialTab = 0,
  });

  @override
  State<PermissionsManagementModal> createState() => _PermissionsManagementModalState();
}

class _PermissionsManagementModalState extends State<PermissionsManagementModal> {
  late int _activeTab;

  // Aba 0: Usuários
  List<UserProfile> _users = [];
  int _selectedUserIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  late String _editingTipo;
  late UserPermissions _editingPermissions;

  // Aba 1: Funções cadastradas pelo Admin
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
    _activeTab = widget.initialTab;
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
      ApiService.listarUsuarios(),
      ApiService.listarFuncoes(),
    ]);
    if (!mounted) return;
    setState(() {
      _users = List.from(results[0] as List<UserProfile>);
      _functions = List.from(results[1] as List<JobFunction>);
      _isLoading = false;
      if (_users.isNotEmpty) {
        _selectUser(0);
      }
    });
  }

  void _selectUser(int index) {
    final u = _users[index];
    setState(() {
      _selectedUserIndex = index;
      _editingTipo = u.tipo.toLowerCase();
      _editingPermissions = u.permissions;
    });
  }

  Future<void> _saveCurrentToDatabase() async {
    if (_users.isEmpty) return;
    final targetUser = _users[_selectedUserIndex];
    final userId = targetUser.id ?? (_selectedUserIndex + 1);

    setState(() => _isSaving = true);
    final updated = await ApiService.salvarPermissoes(
      userId: userId,
      tipo: _editingTipo,
      permissions: _editingPermissions,
    );
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (updated != null) {
        _users[_selectedUserIndex] = updated;
      }
    });

    widget.onPermissionsChanged?.call();

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Permissões de ${targetUser.name} salvas no banco MySQL (folks)!',
        ),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _createFunction() async {
    final name = _fnNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Informe o nome da função para cadastrar.'),
          backgroundColor: Colors.redAccent.shade700,
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

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Função "${created.nome}" cadastrada e disponível no Cadastro!'),
        backgroundColor: const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _deleteFunction(JobFunction fn) async {
    await ApiService.excluirFuncao(fn.id);
    if (!mounted) return;
    setState(() {
      _functions = List.from(FunctionSession.functions);
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Função "${fn.nome}" removida.'),
        backgroundColor: Colors.redAccent.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E24),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.16), width: 1.0),
          left: BorderSide(color: Colors.white.withValues(alpha: 0.16), width: 1.0),
          right: BorderSide(color: Colors.white.withValues(alpha: 0.16), width: 1.0),
        ),
      ),
      padding: EdgeInsets.only(
        top: 18,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: _isLoading
          ? const SizedBox(
              height: 240,
              child: Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.admin_panel_settings, color: Colors.amberAccent, size: 22),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'PAINEL DO ADMINISTRADOR',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),

                  // Abas: Usuários & Permissões | Cadastrar Funções
                  Container(
                    height: 38,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF27272F),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _activeTab = 0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: _activeTab == 0 ? const Color(0xFF1E2856) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Permissões de Usuários',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
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
                                color: _activeTab == 1 ? const Color(0xFF1E2856) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                'Cadastrar Funções',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_activeTab == 0)
                    _buildUsersPermissionsTab()
                  else
                    _buildFunctionsManagementTab(),
                ],
              ),
            ),
    );
  }

  Widget _buildUsersPermissionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2856),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 0.8,
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.storage_rounded, color: Colors.greenAccent, size: 15),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sincronizado com MySQL (Banco: folks • Tabela: permissoes_usuario)',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SELECIONE O USUÁRIO:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 66,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _users.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final u = _users[index];
              final selected = index == _selectedUserIndex;
              return InkWell(
                onTap: () => _selectUser(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF1E2856) : const Color(0xFF27272F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.12),
                      width: selected ? 1.3 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: u.isAdmin ? Colors.amber.shade700 : Colors.white24,
                        child: Text(
                          u.initials,
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
                            u.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${u.role} • ${u.email}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10.5,
                            ),
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
        const SizedBox(height: 16),
        const Text(
          'NÍVEL DE ACESSO / CARGO:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF27272F),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _niveis.any((n) => n['value'] == _editingTipo) ? _editingTipo : 'assistente',
              dropdownColor: const Color(0xFF27272F),
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
        const SizedBox(height: 16),
        const Text(
          'PERMISSÕES DETALHADAS DO USUÁRIO:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF27272F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: Column(
            children: [
              _buildPermSwitch(
                title: 'Criar Tarefas',
                subtitle: 'Permite cadastrar novas tarefas e demandas',
                icon: Icons.add_task,
                value: _editingPermissions.criarTarefas,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(criarTarefas: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Editar Tarefas',
                subtitle: 'Permite alterar título, prazo, prioridade e gestor',
                icon: Icons.edit_note,
                value: _editingPermissions.editarTarefas,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(editarTarefas: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Excluir Tarefas',
                subtitle: 'Permite remover tarefas do sistema',
                icon: Icons.delete_outline,
                value: _editingPermissions.excluirTarefas,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(excluirTarefas: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Alterar Status de Tarefas',
                subtitle: 'Permite mudar entre Pendente, Em Andamento e Concluído',
                icon: Icons.sync_alt,
                value: _editingPermissions.alterarStatus,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(alterarStatus: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Visualizar Desempenho e Métricas',
                subtitle: 'Libera acesso aos gráficos e indicadores da aba Desempenho',
                icon: Icons.pie_chart_outline,
                value: _editingPermissions.verDesempenho,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(verDesempenho: v),
                ),
              ),
              Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),
              _buildPermSwitch(
                title: 'Administrador (Gerenciar Permissões)',
                subtitle: 'Permite alterar cargos e permissões de todos os usuários',
                icon: Icons.security,
                value: _editingPermissions.gerenciarPermissoes,
                onChanged: (v) => setState(
                  () => _editingPermissions = _editingPermissions.copyWith(gerenciarPermissoes: v),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        ElevatedButton.icon(
          onPressed: _isSaving ? null : _saveCurrentToDatabase,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.save_outlined, color: Colors.white),
          label: Text(
            _isSaving ? 'SALVANDO NO MYSQL...' : 'SALVAR PERMISSÕES NO BANCO',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E2856),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.22), width: 1.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionsManagementTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF27272F),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'CADASTRAR NOVA FUNÇÃO PARA FUNCIONÁRIOS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _fnNameController,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  labelText: 'Nome da Função / Cargo *',
                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 12.5),
                  hintText: 'Ex: Coordenador de Talentos',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.work_outline, color: Colors.white70, size: 18),
                  filled: true,
                  fillColor: const Color(0xFF1E1E24),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _fnDeptController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Setor / Departamento',
                  labelStyle: const TextStyle(color: Colors.white70, fontSize: 12.5),
                  prefixIcon: const Icon(Icons.business_outlined, color: Colors.white70, size: 18),
                  filled: true,
                  fillColor: const Color(0xFF1E1E24),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text(
                    'Nível Base:',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _newFnTipo,
                          dropdownColor: const Color(0xFF1E1E24),
                          isExpanded: true,
                          style: const TextStyle(color: Colors.white, fontSize: 12.5),
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
                              _newFnTipo = val;
                              _newFnPermissions = UserPermissions.forTipo(val);
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              SwitchListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'Permitir Criar Tarefas nesta Função',
                  style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                ),
                value: _newFnPermissions.criarTarefas,
                activeThumbColor: Colors.greenAccent,
                onChanged: (val) => setState(
                  () => _newFnPermissions = _newFnPermissions.copyWith(criarTarefas: val),
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _isCreatingFn ? null : _createFunction,
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: Text(
                  _isCreatingFn ? 'CADASTRANDO...' : 'CADASTRAR FUNÇÃO',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2856),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.22)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'FUNÇÕES DISPONÍVEIS NO CADASTRO DE FUNCIONÁRIOS:',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        ..._functions.map((fn) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF27272F),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
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
                        '${fn.departamento} • Nível: ${fn.tipo.toUpperCase()}',
                        style: const TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _deleteFunction(fn),
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                  tooltip: 'Remover função',
                ),
              ],
            ),
          );
        }),
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
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
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
