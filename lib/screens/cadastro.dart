import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../routes/app_routes.dart';
import '../services/api_service.dart';
import '../widgets/function_selector_modal.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _authCodeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  List<JobFunction> _availableFunctions = [];
  JobFunction? _selectedFunction;
  String? _functionError;

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _availableFunctions = List.from(FunctionSession.functions);
    if (_availableFunctions.isNotEmpty) {
      _selectedFunction = _availableFunctions.first;
    }
    _loadFunctionsFromBackend();
  }

  Future<void> _loadFunctionsFromBackend() async {
    final loaded = await ApiService.listarFuncoes();
    if (!mounted) return;
    setState(() {
      _availableFunctions = List.from(loaded);
      if (_availableFunctions.isNotEmpty) {
        final currentId = _selectedFunction?.id;
        _selectedFunction = _availableFunctions.firstWhere(
          (f) => f.id == currentId,
          orElse: () => _availableFunctions.first,
        );
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _authCodeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Informe seu nome' : null;

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Informe seu e-mail';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'E-mail inválido';
    return null;
  }

  String? _validateAuthCode(String? value) =>
      (value == null || value.trim().isEmpty) ? 'Informe o código de autenticação' : null;

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Informe sua senha';
    if (value.length < 4) return 'A senha deve ter pelo menos 4 caracteres';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Confirme sua senha';
    if (value != _passwordController.text) return 'As senhas não coincidem';
    return null;
  }

  void _openCustomFunctionSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FunctionSelectorModal(
        functions: _availableFunctions,
        selectedFunction: _selectedFunction,
        onSelected: (fn) {
          setState(() {
            _selectedFunction = fn;
            _functionError = null;
          });
        },
      ),
    );
  }

  Future<void> _handleCadastro() async {
    final validForm = _formKey.currentState!.validate();
    if (_selectedFunction == null) {
      setState(() => _functionError = 'Selecione sua função na empresa');
      return;
    }
    if (!validForm) return;

    setState(() => _isLoading = true);

    final fn = _selectedFunction!;
    final created = await AuthService.cadastrar(
      nome: _nameController.text.trim(),
      email: _emailController.text.trim(),
      senha: _passwordController.text.trim(),
      tipo: fn.tipo,
      funcaoNome: fn.nome,
      departamento: fn.departamento,
      codigoUtilizado: _authCodeController.text.trim(),
      permissions: fn.permissions,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cadastro de ${created.name} realizado com sucesso!'),
          backgroundColor: const Color(0xFF15803D),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushReplacementNamed(AppRoute.dashboard.path);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao realizar cadastro no servidor. Verifique os dados.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F2),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 85,
                      child: Image.asset('assets/fotos/logo2.png', fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Crie sua conta',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Cadastre-se e selecione sua função na Folks RH',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      validator: _validateName,
                      decoration: const InputDecoration(
                        labelText: 'Nome Completo',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'E-mail Corporativo',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // INPUT DE SELEÇÃO PERSONALIZADO DE FUNÇÃO
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: _openCustomFunctionSelector,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: _functionError != null
                                    ? Colors.redAccent
                                    : const Color(0xFF1B2A6B).withValues(alpha: 0.45),
                                width: 1.3,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B2A6B),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.work_outline,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Função / Cargo na Empresa *',
                                        style: TextStyle(
                                          color: Color(0xFF1B2A6B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        _selectedFunction?.nome ?? 'Toque para selecionar sua função',
                                        style: TextStyle(
                                          color: _selectedFunction != null
                                              ? Colors.black87
                                              : Colors.black45,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (_selectedFunction != null)
                                        Text(
                                          '${_selectedFunction!.departamento} • Nível: ${_selectedFunction!.tipo.toUpperCase()}',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B2A6B).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Alterar',
                                        style: TextStyle(
                                          color: Color(0xFF1B2A6B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 2),
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF1B2A6B),
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_functionError != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 12, top: 4),
                            child: Text(
                              _functionError!,
                              style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _authCodeController,
                      validator: _validateAuthCode,
                      decoration: const InputDecoration(
                        labelText: 'Código de autenticação',
                        prefixIcon: Icon(Icons.key_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscurePassword,
                      validator: _validateConfirmPassword,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar senha',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _isLoading ? null : _handleCadastro,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF1B2A6B),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Criar conta'),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacementNamed(AppRoute.login.path);
                      },
                      child: const Text(
                        'Já tem uma conta? Faça login',
                        style: TextStyle(color: Color(0xFF1B2A6B)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
