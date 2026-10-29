import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../theme/app_colors.dart';

class FunctionSelectorModal extends StatefulWidget {
  final List<JobFunction> functions;
  final JobFunction? selectedFunction;
  final ValueChanged<JobFunction> onSelected;

  const FunctionSelectorModal({
    super.key,
    required this.functions,
    required this.selectedFunction,
    required this.onSelected,
  });

  @override
  State<FunctionSelectorModal> createState() => _FunctionSelectorModalState();
}

class _FunctionSelectorModalState extends State<FunctionSelectorModal> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.functions.where((f) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return f.nome.toLowerCase().contains(q) ||
          f.departamento.toLowerCase().contains(q) ||
          f.tipo.toLowerCase().contains(q);
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: AppColors.modalSheetDecoration(),
      padding: EdgeInsets.only(
        top: 18,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
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
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.work_outline, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'SELECIONE SUA FUNÇÃO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Text(
            'Funções cadastradas e gerenciadas pelo Administrador',
            style: TextStyle(color: Colors.white54, fontSize: 11.5),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: const TextStyle(color: Colors.white, fontSize: 13.5),
            decoration: AppColors.darkInputDecoration(
              hintText: 'Buscar função ou setor...',
              prefixIcon: Icons.search,
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: filtered.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(
                      child: Text(
                        'Nenhuma função encontrada.',
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final fn = filtered[index];
                      final isSelected = widget.selectedFunction?.id == fn.id &&
                          widget.selectedFunction?.nome == fn.nome;

                      return InkWell(
                        onTap: () {
                          widget.onSelected(fn);
                          Navigator.of(context).pop();
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryNavy : AppColors.bgInput,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.borderFocused : AppColors.borderSubtle,
                              width: isSelected ? 1.4 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(9),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.10),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  fn.permissions.criarTarefas
                                      ? Icons.manage_accounts_outlined
                                      : Icons.badge_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fn.nome,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      fn.departamento,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 11.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.black26,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                                ),
                                child: Text(
                                  fn.tipo.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 8),
                                const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
