import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../widgets/custom_badges.dart';
import '../widgets/edit_profile_modal.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late UserProfile _profile;

  // Notificações locais simuladas
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _deadlineReminders = true;

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
            UserSession.current = updatedProfile;
          });
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dados do perfil atualizados com sucesso!'),
              backgroundColor: Color(0xFF1E2856),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
      ),
    );
  }

  void _showFolksModal({
    required String title,
    required Widget Function(BuildContext ctx, StateSetter? setModalState) contentBuilder,
    bool isScrollControlled = false,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
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
              top: 20,
              left: 20,
              right: 20,
              bottom: isScrollControlled
                  ? MediaQuery.of(context).viewInsets.bottom + 24
                  : 20,
            ),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 16),
                contentBuilder(context, setModalState),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPasswordModal() {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscure = true;

    _showFolksModal(
      title: 'ALTERAR SENHA DE ACESSO',
      isScrollControlled: true,
      contentBuilder: (ctx, setModalState) {
        InputDecoration inputDeco(String label, IconData icon, {Widget? suffix}) {
          return InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.white70, size: 20),
            suffixIcon: suffix,
            filled: true,
            fillColor: const Color(0xFF2E2E2E),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white24),
            ),
          );
        }

        return Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: obscure,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: inputDeco(
                    'Senha Atual *',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () => setModalState!(() => obscure = !obscure),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Informe sua senha atual' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: obscure,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: inputDeco('Nova Senha *', Icons.lock_reset),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Informe a nova senha';
                    if (v.length < 4) return 'Mínimo de 4 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: obscure,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: inputDeco('Confirmar Nova Senha *', Icons.lock_reset),
                  validator: (v) => (v != newPasswordController.text) ? 'As senhas não coincidem' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (!formKey.currentState!.validate()) return;
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Senha alterada com sucesso!'),
                        backgroundColor: Color(0xFF1E2856),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2856),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: Colors.white, width: 1.2),
                    ),
                  ),
                  child: const Text(
                    'ATUALIZAR SENHA',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationPreferencesModal() {
    _showFolksModal(
      title: 'PREFERÊNCIAS DE NOTIFICAÇÃO',
      contentBuilder: (ctx, setModalState) {
        Widget buildSwitch(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
          return SwitchListTile(
            title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 12)),
            value: value,
            activeThumbColor: const Color(0xFF1E2856),
            onChanged: (val) {
              setModalState!(() => onChanged(val));
              setState(() => onChanged(val));
            },
          );
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildSwitch('Notificações Push', 'Receber alertas de novas tarefas no app', _pushNotifications, (v) => _pushNotifications = v),
            buildSwitch('Alertas por E-mail', 'Resumo diário e atualizações de recrutamento', _emailAlerts, (v) => _emailAlerts = v),
            buildSwitch('Lembretes de Prazos', 'Avisar quando uma tarefa estiver próxima do vencimento', _deadlineReminders, (v) => _deadlineReminders = v),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2856),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.white, width: 1.2),
                ),
              ),
              child: const Text('CONCLUÍDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showHelpModal() {
    _showFolksModal(
      title: 'CENTRAL DE AJUDA & SUPORTE',
      contentBuilder: (ctx, _) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Folks RH - Sistema de Gestão de Recrutamento',
              style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Em caso de dúvidas sobre o gerenciamento de tarefas, cadastro de candidatos ou problemas de acesso, entre em contato com o suporte de TI.',
              style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2E2E2E),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.email_outlined, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text('suporte@folksrh.com.br', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.support_agent, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text('Ramal interno: #4040', style: TextStyle(color: Colors.white, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E2856),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: const BorderSide(color: Colors.white, width: 1.2),
                ),
              ),
              child: const Text('FECHAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF383838),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Colors.white24, width: 1.2),
        ),
        title: const Text('Sair da Conta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
              Navigator.of(ctx).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoute.login.path,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('SAIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
        return ProfileAvatar(
          size: 64,
          initials: _profile.initials,
        );
      case AvatarChoice.badge:
        return const ProfileAvatar(size: 64, icon: Icons.badge_outlined);
      case AvatarChoice.admin:
        return const ProfileAvatar(size: 64, icon: Icons.admin_panel_settings_outlined);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF404040),
      appBar: AppBar(
        backgroundColor: const Color(0xFF404040),
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
            // --- PROFILE MAIN CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF454545),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar with edit badge
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
                              color: const Color(0xFF1E2856),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1.2),
                            ),
                            child: const Icon(Icons.edit, color: Colors.white, size: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name
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

                  // Role & Department
                  Text(
                    '${_profile.role} • ${_profile.department}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status badge and Quick Edit button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E2856),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white54, width: 0.8),
                        ),
                        child: const Text(
                          'CONTA ATIVA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _openEditProfileModal,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white30, width: 0.8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.edit, color: Colors.white70, size: 11),
                              SizedBox(width: 4),
                              Text(
                                'EDITAR DADOS',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- CONTACT & BIO INFO CARD ---
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF454545),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white24, width: 1.0),
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
                    label: 'E-mail Corporativo',
                    value: _profile.email,
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  _buildContactItem(
                    icon: Icons.phone_outlined,
                    label: 'Telefone / WhatsApp',
                    value: _profile.phone,
                  ),
                  const Divider(color: Colors.white12, height: 16),
                  _buildContactItem(
                    icon: Icons.business_outlined,
                    label: 'Departamento',
                    value: _profile.department,
                  ),
                  if (_profile.bio.isNotEmpty) ...[
                    const Divider(color: Colors.white12, height: 16),
                    _buildContactItem(
                      icon: Icons.notes_outlined,
                      label: 'Sobre Mim',
                      value: _profile.bio,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // --- SETTINGS SECTION ---
            const Padding(
              padding: EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                'CONFIGURAÇÕES & SEGURANÇA',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
            ),

            _buildSettingTile(
              icon: Icons.person_outline,
              title: 'Dados Pessoais',
              subtitle: 'Editar nome, e-mail, cargo e avatar',
              onTap: _openEditProfileModal,
            ),
            _buildSettingTile(
              icon: Icons.notifications_none,
              title: 'Preferências de Notificação',
              subtitle: 'Alertas de tarefas, push e prazos',
              onTap: _showNotificationPreferencesModal,
            ),
            _buildSettingTile(
              icon: Icons.lock_outline,
              title: 'Segurança e Senha',
              subtitle: 'Alterar senha de acesso',
              onTap: _showPasswordModal,
            ),
            _buildSettingTile(
              icon: Icons.help_outline,
              title: 'Ajuda e Suporte',
              subtitle: 'Central de ajuda Folks RH',
              onTap: _showHelpModal,
            ),

            const SizedBox(height: 24),

            // --- LOGOUT BUTTON ---
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
                  side: const BorderSide(color: Colors.white54, width: 1.0),
                ),
                elevation: 2,
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
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
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
        color: const Color(0xFF454545),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24, width: 1.0),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E2856),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white30, width: 0.8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
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
        trailing: const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
        onTap: onTap,
      ),
    );
  }
}
