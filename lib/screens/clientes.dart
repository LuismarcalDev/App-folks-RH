import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/cliente_service.dart';
import '../theme/app_colors.dart';
import '../widgets/controle_acesso.dart';

/// Tela de Clientes — Estrutura preparada para o desenvolvedor responsável
/// Backend conectado: GET /api/clientes e POST /api/clientes
class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  List<Cliente> _clientes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    setState(() => _isLoading = true);
    final lista = await ClienteService.listarClientes();
    if (!mounted) return;
    setState(() {
      _clientes = lista;
      _isLoading = false;
    });
  }

  void _abrirCadastroCliente() {
    final nomeController = TextEditingController();
    final emailController = TextEditingController();
    final telefoneController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: AppColors.modalSheetDecoration(),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'CADASTRAR NOVO CLIENTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close, color: Colors.white70),
                ),
              ],
            ),
            Divider(color: AppColors.borderSubtle, height: 16),
            TextField(
              controller: nomeController,
              style: const TextStyle(color: Colors.white),
              decoration: AppColors.darkInputDecoration(
                labelText: 'Nome do Cliente / Empresa *',
                prefixIcon: Icons.business,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: AppColors.darkInputDecoration(
                labelText: 'E-mail de Contato',
                prefixIcon: Icons.email_outlined,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: telefoneController,
              style: const TextStyle(color: Colors.white),
              decoration: AppColors.darkInputDecoration(
                labelText: 'Telefone',
                prefixIcon: Icons.phone_outlined,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () async {
                if (nomeController.text.trim().isEmpty) return;
                await ClienteService.cadastrarCliente(
                  nome: nomeController.text.trim(),
                  email: emailController.text.trim(),
                  telefone: telefoneController.text.trim(),
                );
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                }
                if (mounted) {
                  _carregarClientes();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('SALVAR CLIENTE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = UserSession.current;
    final temPermissao = user.permissions.clientes || user.isAdmin;

    return ControleAcessoGuard(
      hasPermission: temPermissao,
      moduloNome: 'Clientes',
      child: Scaffold(
        backgroundColor: AppColors.bgMain,
        appBar: AppBar(
          backgroundColor: AppColors.bgMain,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'CLIENTES',
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
              icon: const Icon(Icons.add_business_outlined, color: Colors.white),
              tooltip: 'Novo Cliente',
              onPressed: _abrirCadastroCliente,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _clientes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.people_outline, size: 56, color: Colors.white.withValues(alpha: 0.35)),
                          const SizedBox(height: 14),
                          const Text(
                            'Nenhum cliente cadastrado no momento.',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _abrirCadastroCliente,
                            icon: const Icon(Icons.add, color: Colors.white, size: 18),
                            label: const Text('CADASTRAR PRIMEIRO CLIENTE', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryNavy,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    itemCount: _clientes.length,
                    itemBuilder: (context, index) {
                      final c = _clientes[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryNavy,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.business, color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c.nome,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (c.email != null)
                                    Text(c.email!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                  if (c.telefone != null)
                                    Text(c.telefone!, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
