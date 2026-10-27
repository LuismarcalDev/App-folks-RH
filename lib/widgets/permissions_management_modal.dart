import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class PermissionsManagementModal extends StatefulWidget {
  final VoidCallback? onPermissionsChanged;

  const PermissionsManagementModal({
    super.key,
    this.onPermissionsChanged,
  });

  @override
  State<PermissionsManagementModal> createState() => _PermissionsManagementModalState();
}

class _PermissionsManagementModalState extends State<PermissionsManagementModal> {
  List<UserProfile> _users = [];
  int _selectedUserIndex = 0;
  bool _isLoading = true;
  bool _isSaving = false;

  late String _editingTipo;
  late UserPermissions _editingPermissions;

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
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    final loaded = await ApiService.listarUsuarios();
    if (!mounted) return;
    setState(() {
      _users = List.from(loaded);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF383838),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white, width: 1.4),
          left: BorderSide(color: Colors.white, width: 1.4),
          right: BorderSide(color: Colors.white, width: 1.4),
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
                        color: Colors.white30,
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
                                'CONTROLE DE PERMISSÕES (ADMIN)',
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2856),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white38, width: 0.8),
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
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final u = _users[index];
                        final selected = index == _selectedUserIndex;
                        return InkWell(
                          onTap: () => _selectUser(index),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF1E2856) : const Color(0xFF2E2E2E),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selected ? Colors.white : Colors.white24,
                                width: selected ? 1.5 : 1.0,
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
                                      '${u.tipo.toUpperCase()} • ${u.email}',
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
                      color: const Color(0xFF2E2E2E),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _niveis.any((n) => n['value'] == _editingTipo) ? _editingTipo : 'assistente',
                        dropdownColor: const Color(0xFF2E2E2E),
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
                      color: const Color(0xFF2E2E2E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
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
                        const Divider(color: Colors.white12, height: 1),
                        _buildPermSwitch(
                          title: 'Editar Tarefas',
                          subtitle: 'Permite alterar título, prazo, prioridade e gestor',
                          icon: Icons.edit_note,
                          value: _editingPermissions.editarTarefas,
                          onChanged: (v) => setState(
                            () => _editingPermissions = _editingPermissions.copyWith(editarTarefas: v),
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        _buildPermSwitch(
                          title: 'Excluir Tarefas',
                          subtitle: 'Permite remover tarefas do sistema',
                          icon: Icons.delete_outline,
                          value: _editingPermissions.excluirTarefas,
                          onChanged: (v) => setState(
                            () => _editingPermissions = _editingPermissions.copyWith(excluirTarefas: v),
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        _buildPermSwitch(
                          title: 'Alterar Status de Tarefas',
                          subtitle: 'Permite mudar entre Pendente, Em Andamento e Concluído',
                          icon: Icons.sync_alt,
                          value: _editingPermissions.alterarStatus,
                          onChanged: (v) => setState(
                            () => _editingPermissions = _editingPermissions.copyWith(alterarStatus: v),
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 1),
                        _buildPermSwitch(
                          title: 'Visualizar Desempenho e Métricas',
                          subtitle: 'Libera acesso aos gráficos e indicadores da aba Desempenho',
                          icon: Icons.pie_chart_outline,
                          value: _editingPermissions.verDesempenho,
                          onChanged: (v) => setState(
                            () => _editingPermissions = _editingPermissions.copyWith(verDesempenho: v),
                          ),
                        ),
                        const Divider(color: Colors.white12, height: 1),
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
                        side: const BorderSide(color: Colors.white, width: 1.2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
