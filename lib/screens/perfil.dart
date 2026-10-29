import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_badges.dart';
import '../widgets/edit_profile_modal.dart';
import 'funcionarios.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late UserProfile _profile;

  @override
  void initState() {
    super.initState();
    _profile = UserSession.current;
  }

  void _openEditProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => EditProfileModal(
        profile: _profile,
        onProfileSaved: (updatedProfile) {
          setState(() {
            _profile = updatedProfile;
            UserSession.setCurrent(updatedProfile);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dados do perfil atualizados com sucesso!'),
              backgroundColor: AppColors.primaryNavy,
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _openFuncionariosScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const FuncionariosScreen()),
    ).then((_) {
      if (mounted) {
        setState(() {
          _profile = UserSession.current;
        });
      }
    });
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgModal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.borderSubtle, width: 1.0),
        ),
        title: const Text(
          'Sair da Conta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza de que deseja encerrar sua sessão no aplicativo?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCELAR', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              UserSession.logout();
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoute.login.path,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'SAIR',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    switch (_profile.avatarChoice) {
      case AvatarChoice.person:
        return const ProfileAvatar(size: 64, icon: Icons.person);
      case AvatarChoice.initials:
        return ProfileAvatar(size: 64, initials: _profile.initials);
      case AvatarChoice.badge:
        return const ProfileAvatar(size: 64, icon: Icons.badge_outlined);
      case AvatarChoice.admin:
        return const ProfileAvatar(size: 64, icon: Icons.admin_panel_settings_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        backgroundColor: AppColors.bgMain,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'MEU PERFIL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            tooltip: 'Editar Dados',
            onPressed: _openEditProfileModal,
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            // Card Principal
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _openEditProfileModal,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _buildAvatar(),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryNavy,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.borderStrong, width: 1.0),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _profile.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_profile.role} • ${_profile.department}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryNavy,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderMedium, width: 0.8),
                    ),
                    child: Text(
                      'NÍVEL: ${_profile.tipo.toUpperCase()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contato
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderSubtle, width: 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INFORMAÇÕES DE CONTATO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactItem(
                    icon: Icons.email_outlined,
                    label: 'E-mail',
                    value: _profile.email,
                  ),
                  Divider(color: Colors.white.withValues(alpha: 0.10), height: 16),
                  _buildContactItem(
                    icon: Icons.phone_outlined,
                    label: 'Telefone',
                    value: _profile.phone,
                  ),
                  Divider(color: Colors.white.withValues(alpha: 0.10), height: 16),
                  _buildContactItem(
                    icon: Icons.business_outlined,
                    label: 'Departamento',
                    value: _profile.department,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Permissões
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _profile.isAdmin
                      ? Colors.amberAccent.withValues(alpha: 0.35)
                      : AppColors.borderSubtle,
                  width: 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PERMISSÕES ATIVAS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildPermChip('Clientes', _profile.permissions.clientes),
                      _buildPermChip('Tarefas', _profile.permissions.tarefas),
                      _buildPermChip('Notificações', _profile.permissions.notificacoes),
                      _buildPermChip('Funcionários', _profile.permissions.funcionarios),
                      _buildPermChip('Criar Tarefas', _profile.permissions.criarTarefas),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Gestão
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'OPÇÕES',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
            ),

            if (_profile.permissions.funcionarios || _profile.isAdmin)
              _buildSettingTile(
                icon: Icons.admin_panel_settings,
                title: 'Gestão de Funcionários & Permissões',
                subtitle: 'Gerenciar cargos e permissões de usuários no MySQL',
                onTap: _openFuncionariosScreen,
              ),

            _buildSettingTile(
              icon: Icons.person_outline,
              title: 'Editar Dados Pessoais',
              subtitle: 'Nome, e-mail, cargo e avatar',
              onTap: _openEditProfileModal,
            ),

            const SizedBox(height: 24),

            // Logout
            ElevatedButton.icon(
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout, color: Colors.white, size: 18),
              label: const Text(
                'SAIR DA CONTA (LOGOUT)',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: AppColors.borderStrong),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSubtle, width: 1.0),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderMedium, width: 0.8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.white60, fontSize: 11.5),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildPermChip(String label, bool enabled) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: enabled ? AppColors.primaryNavy.withValues(alpha: 0.85) : Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled ? Colors.greenAccent.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.10),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            enabled ? Icons.check_circle_outline : Icons.block,
            color: enabled ? Colors.greenAccent : Colors.white38,
            size: 13,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: enabled ? Colors.white : Colors.white54,
              fontSize: 11,
              fontWeight: enabled ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
