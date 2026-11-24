import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/cliente_service.dart';
import '../theme/app_colors.dart';
import '../widgets/controle_acesso.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});

  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  final _buscaController = TextEditingController();
  List<Cliente> _clientes = [];
  String _busca = '';
  bool _isLoading = true;
  String? _erro;

  bool get _temPermissao {
    final user = UserSession.current;
    return user.permissions.clientes || user.isAdmin;
  }

  @override
  void initState() {
    super.initState();
    if (_temPermissao) {
      _carregarClientes();
    } else {
      _isLoading = false;
    }
  }

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  List<Cliente> get _filtrados {
    final q = _busca.trim().toLowerCase();
    if (q.isEmpty) return _clientes;
    return _clientes.where((c) {
      final campos = <String?>[c.nome, c.email, c.telefone, c.cpfCnpj];
      return campos.any((v) => v != null && v.toLowerCase().contains(q));
    }).toList();
  }

  Future<void> _carregarClientes({bool mostrarLoading = true}) async {
    if (mostrarLoading) {
      setState(() {
        _isLoading = true;
        _erro = null;
      });
    }
    try {
      final lista = await ClienteService.listarClientes();
      if (!mounted) return;
      setState(() {
        _clientes = lista;
        _erro = null;
      });
    } on ClienteException catch (e) {
      if (!mounted) return;
      setState(() => _erro = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _erro = 'Erro inesperado ao carregar clientes.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarMensagem(String texto, {bool erro = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: erro ? Colors.redAccent : null,
      ),
    );
  }

  Future<void> _abrirFormulario({Cliente? cliente}) async {
    final salvo = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ClienteFormSheet(cliente: cliente),
    );

    if (salvo == true && mounted) {
      _mostrarMensagem(
        cliente == null ? 'Cliente cadastrado.' : 'Cliente atualizado.',
      );
      _carregarClientes(mostrarLoading: false);
    }
  }

  Future<void> _confirmarExclusao(Cliente cliente) async {
    final id = cliente.id;
    if (id == null) return;

    final confirmou = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          'Excluir cliente',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        content: Text(
          'Deseja excluir "${cliente.nome}"? Esta ação não pode ser desfeita.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'EXCLUIR',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );

    if (confirmou != true) return;

    try {
      await ClienteService.excluirCliente(id);
      if (!mounted) return;
      setState(() => _clientes.removeWhere((c) => c.id == id));
      _mostrarMensagem('Cliente excluído.');
    } on ClienteException catch (e) {
      _mostrarMensagem(e.message, erro: true);
    } catch (_) {
      _mostrarMensagem('Não foi possível excluir o cliente.', erro: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ControleAcessoGuard(
      hasPermission: _temPermissao,
      moduloNome: 'Clientes',
      child: Scaffold(
        backgroundColor: AppColors.bgMain,
        appBar: AppBar(
          backgroundColor: AppColors.bgMain,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
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
              onPressed: () => _abrirFormulario(),
            ),
          ],
        ),
        body: _buildCorpo(),
      ),
    );
  }

  Widget _buildCorpo() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_erro != null && _clientes.isEmpty) {
      return _EstadoVazio(
        icone: Icons.cloud_off_outlined,
        texto: _erro!,
        rotuloBotao: 'TENTAR NOVAMENTE',
        iconeBotao: Icons.refresh,
        onPressed: () => _carregarClientes(),
      );
    }

    if (_clientes.isEmpty) {
      return _EstadoVazio(
        icone: Icons.people_outline,
        texto: 'Nenhum cliente cadastrado no momento.',
        rotuloBotao: 'CADASTRAR PRIMEIRO CLIENTE',
        iconeBotao: Icons.add,
        onPressed: () => _abrirFormulario(),
      );
    }

    final lista = _filtrados;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: TextField(
            controller: _buscaController,
            style: const TextStyle(color: Colors.white),
            onChanged: (v) => setState(() => _busca = v),
            decoration: AppColors.darkInputDecoration(
              labelText: 'Buscar cliente',
              prefixIcon: Icons.search,
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _carregarClientes(mostrarLoading: false),
            child: lista.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text(
                            'Nenhum cliente encontrado.',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                    ],
                  )
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                    itemCount: lista.length,
                    itemBuilder: (context, index) {
                      final c = lista[index];
                      return _ClienteCard(
                        cliente: c,
                        onEditar: () => _abrirFormulario(cliente: c),
                        onExcluir: () => _confirmarExclusao(c),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}


class _EstadoVazio extends StatelessWidget {
  final IconData icone;
  final String texto;
  final String rotuloBotao;
  final IconData iconeBotao;
  final VoidCallback onPressed;

  const _EstadoVazio({
    required this.icone,
    required this.texto,
    required this.rotuloBotao,
    required this.iconeBotao,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 56, color: Colors.white.withValues(alpha: 0.35)),
            const SizedBox(height: 14),
            Text(
              texto,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(iconeBotao, color: Colors.white, size: 18),
              label: Text(
                rotuloBotao,
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ClienteCard extends StatelessWidget {
  final Cliente cliente;
  final VoidCallback onEditar;
  final VoidCallback onExcluir;

  const _ClienteCard({
    required this.cliente,
    required this.onEditar,
    required this.onExcluir,
  });

  @override
  Widget build(BuildContext context) {
    final c = cliente;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.borderSubtle),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onEditar,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 4, 14),
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
                      if (c.cpfCnpj != null)
                        Text(
                          c.cpfCnpj!,
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      if (c.email != null)
                        Text(
                          c.email!,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      if (c.telefone != null)
                        Text(
                          c.telefone!,
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  color: AppColors.bgCard,
                  icon: const Icon(Icons.more_vert, color: Colors.white70),
                  tooltip: 'Ações',
                  onSelected: (valor) {
                    if (valor == 'editar') {
                      onEditar();
                    } else if (valor == 'excluir') {
                      onExcluir();
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem<String>(
                      value: 'editar',
                      child: Text('Editar', style: TextStyle(color: Colors.white)),
                    ),
                    PopupMenuItem<String>(
                      value: 'excluir',
                      child: Text('Excluir', style: TextStyle(color: Colors.redAccent)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ClienteFormSheet extends StatefulWidget {
  final Cliente? cliente;

  const _ClienteFormSheet({this.cliente});

  @override
  State<_ClienteFormSheet> createState() => _ClienteFormSheetState();
}

class _ClienteFormSheetState extends State<_ClienteFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late final TextEditingController _cpfCnpj;
  late final TextEditingController _email;
  late final TextEditingController _telefone;

  bool _salvando = false;
  String? _erroApi;

  bool get _editando => widget.cliente != null;

  @override
  void initState() {
    super.initState();
    final c = widget.cliente;
    _nome = TextEditingController(text: c?.nome ?? '');
    _cpfCnpj = TextEditingController(text: c?.cpfCnpj ?? '');
    _email = TextEditingController(text: c?.email ?? '');
    _telefone = TextEditingController(text: c?.telefone ?? '');
  }

  @override
  void dispose() {
    _nome.dispose();
    _cpfCnpj.dispose();
    _email.dispose();
    _telefone.dispose();
    super.dispose();
  }

  String? _vazioParaNull(String texto) {
    final t = texto.trim();
    return t.isEmpty ? null : t;
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() {
      _salvando = true;
      _erroApi = null;
    });

    final dados = Cliente(
      id: widget.cliente?.id,
      nome: _nome.text.trim(),
      cpfCnpj: _vazioParaNull(_cpfCnpj.text),
      email: _vazioParaNull(_email.text),
      telefone: _vazioParaNull(_telefone.text),
    );

    try {
      if (_editando) {
        await ClienteService.atualizarCliente(dados);
      } else {
        await ClienteService.cadastrarCliente(dados);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on ClienteException catch (e) {
      _mostrarErro(e.message);
    } catch (_) {
      _mostrarErro('Não foi possível salvar o cliente.');
    }
  }

  void _mostrarErro(String mensagem) {
    if (!mounted) return;
    setState(() {
      _salvando = false;
      _erroApi = mensagem;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: AppColors.modalSheetDecoration(),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _editando ? 'EDITAR CLIENTE' : 'CADASTRAR NOVO CLIENTE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _salvando ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              Divider(color: AppColors.borderSubtle, height: 16),
              TextFormField(
                controller: _nome,
                enabled: !_salvando,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(color: Colors.white),
                decoration: AppColors.darkInputDecoration(
                  labelText: 'Nome do Cliente / Empresa *',
                  prefixIcon: Icons.business,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Informe o nome';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cpfCnpj,
                enabled: !_salvando,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: AppColors.darkInputDecoration(
                  labelText: 'CPF / CNPJ',
                  prefixIcon: Icons.badge_outlined,
                ),
                validator: (v) {
                  final texto = (v ?? '').trim();
                  if (texto.isEmpty) return null;
                  final digitos = texto.replaceAll(RegExp(r'\D'), '');
                  if (digitos.length != 11 && digitos.length != 14) {
                    return 'CPF (11) ou CNPJ (14 dígitos)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _email,
                enabled: !_salvando,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: AppColors.darkInputDecoration(
                  labelText: 'E-mail de Contato',
                  prefixIcon: Icons.email_outlined,
                ),
                validator: (v) {
                  final texto = (v ?? '').trim();
                  if (texto.isEmpty) return null;
                  final valido = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(texto);
                  return valido ? null : 'E-mail inválido';
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _telefone,
                enabled: !_salvando,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _salvar(),
                style: const TextStyle(color: Colors.white),
                decoration: AppColors.darkInputDecoration(
                  labelText: 'Telefone',
                  prefixIcon: Icons.phone_outlined,
                ),
              ),
              if (_erroApi != null) ...[
                const SizedBox(height: 12),
                Text(
                  _erroApi!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: _salvando ? null : _salvar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryNavy,
                  disabledBackgroundColor:
                      AppColors.primaryNavy.withValues(alpha: 0.6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _salvando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _editando ? 'SALVAR ALTERAÇÕES' : 'SALVAR CLIENTE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
