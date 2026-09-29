import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import 'custom_badges.dart';

class EditProfileModal extends StatefulWidget {
  final UserProfile profile;
  final Function(UserProfile updatedProfile) onProfileSaved;

  const EditProfileModal({
    super.key,
    required this.profile,
    required this.onProfileSaved,
  });

  @override
  State<EditProfileModal> createState() => _EditProfileModalState();
}

class _EditProfileModalState extends State<EditProfileModal> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _roleController;
  late TextEditingController _departmentController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;

  late AvatarChoice _selectedAvatar;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _emailController = TextEditingController(text: widget.profile.email);
    _roleController = TextEditingController(text: widget.profile.role);
    _departmentController = TextEditingController(text: widget.profile.department);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _bioController = TextEditingController(text: widget.profile.bio);
    _selectedAvatar = widget.profile.avatarChoice;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    _departmentController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final updated = widget.profile.copyWith(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: _roleController.text.trim(),
      department: _departmentController.text.trim(),
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
      avatarChoice: _selectedAvatar,
    );

    widget.onProfileSaved(updated);
    Navigator.of(context).pop();
  }

  String _getInitials(String name) {
    final clean = name.split('(').first.trim().replaceAll('-', ' ');
    final parts = clean.split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'RH';
    if (parts.length == 1) {
      return parts[0].substring(0, math.min(2, parts[0].length)).toUpperCase();
    }
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }

  Widget _buildAvatarPreview(AvatarChoice choice, {double size = 38}) {
    switch (choice) {
      case AvatarChoice.person:
        return ProfileAvatar(size: size, icon: Icons.person);
      case AvatarChoice.initials:
        return ProfileAvatar(
          size: size,
          initials: _getInitials(widget.profile.name),
        );
      case AvatarChoice.badge:
        return ProfileAvatar(size: size, icon: Icons.badge_outlined);
      case AvatarChoice.admin:
        return ProfileAvatar(size: size, icon: Icons.admin_panel_settings_outlined);
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData prefixIcon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70, fontSize: 13),
      hintText: hintText,
      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
      prefixIcon: Icon(prefixIcon, color: Colors.white70, size: 20),
      filled: true,
      fillColor: const Color(0xFF2E2E2E),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white24, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.4),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Bar Drag Handle
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

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'EDITAR DADOS PESSOAIS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 16),
              const SizedBox(height: 12),

              // --- AVATAR SELECTION SECTION ---
              const Text(
                'ESTILO DO AVATAR / FOTO',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: AvatarChoice.values.map((choice) {
                    final isSelected = _selectedAvatar == choice;
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedAvatar = choice;
                          });
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E2856) : const Color(0xFF2E2E2E),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.white24,
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              _buildAvatarPreview(choice, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                choice.label,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 20),

              // --- NOME COMPLETO ---
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration(
                  label: 'Nome Completo *',
                  prefixIcon: Icons.person_outline,
                  hintText: 'Ex: Alessandra Gomes',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // --- EMAIL ---
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration(
                  label: 'E-mail Corporativo *',
                  prefixIcon: Icons.email_outlined,
                  hintText: 'Ex: usuario@folksrh.com.br',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe seu e-mail';
                  }
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(value.trim())) {
                    return 'E-mail inválido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // --- CARGO / FUNÇÃO ---
              TextFormField(
                controller: _roleController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration(
                  label: 'Cargo / Função',
                  prefixIcon: Icons.badge_outlined,
                  hintText: 'Ex: Gestor de Recursos Humanos',
                ),
              ),
              const SizedBox(height: 14),

              // --- DEPARTAMENTO ---
              TextFormField(
                controller: _departmentController,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration(
                  label: 'Departamento / Unidade',
                  prefixIcon: Icons.business_outlined,
                  hintText: 'Ex: Folks RH - Recrutamento & Seleção',
                ),
              ),
              const SizedBox(height: 14),

              // --- TELEFONE / WHATSAPP ---
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration(
                  label: 'Telefone / WhatsApp',
                  prefixIcon: Icons.phone_outlined,
                  hintText: 'Ex: (11) 98765-4321',
                ),
              ),
              const SizedBox(height: 14),

              // --- BIOGRAFIA / RESUMO ---
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: _inputDecoration(
                  label: 'Sobre você / Resumo profissional',
                  prefixIcon: Icons.notes_outlined,
                  hintText: 'Descreva brevemente suas atividades e responsabilidades...',
                ),
              ),
              const SizedBox(height: 24),

              // --- BOTÕES DE AÇÃO ---
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Colors.white38, width: 1.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CANCELAR',
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check, color: Colors.white, size: 18),
                      label: const Text(
                        'SALVAR ALTERAÇÕES',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E2856),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(color: Colors.white, width: 1.2),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
