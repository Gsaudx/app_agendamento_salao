import 'package:flutter/material.dart';

import '../components/floating_button.dart';
import '../dependencias/dependencias_widget.dart';
import '../formatters/telefone_input_formatter.dart';
import '../modelos/cliente.dart';
import 'editclient_screen.dart';
import 'newclient_screen.dart';

class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  static const routeName = '/clients';

  @override
  Widget build(BuildContext context) {
    final clientesServico = DependenciasWidget.clientesDe(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes')),
      body: StreamBuilder<List<Cliente>>(
        stream: clientesServico.observarClientes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar os clientes.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final clientes = snapshot.data ?? const <Cliente>[];
          if (clientes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Cadastre seus primeiros clientes para visualizar aqui.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: clientes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final cliente = clientes[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      cliente.nome.isNotEmpty
                          ? cliente.nome.substring(0, 1).toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(cliente.nome),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (cliente.telefone.isNotEmpty)
                        Text(
                          TelefoneInputFormatter.formatValue(cliente.telefone),
                        ),
                      if (cliente.email?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(cliente.email!),
                      ],
                      if (cliente.observacoes?.isNotEmpty == true) ...[
                        const SizedBox(height: 4),
                        Text(cliente.observacoes!),
                      ],
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.create_outlined),
                    onPressed: () => _editarCliente(context, cliente),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingButton(
        label: 'Novo Cliente',
        onPressed: () => _abrirCadastroCliente(context),
      ),
    );
  }

  Future<void> _abrirCadastroCliente(BuildContext context) async {
    final resultado = await Navigator.pushNamed(
      context,
      NewClientScreen.routeName,
    );
    if (resultado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cliente cadastrado com sucesso.')),
      );
    }
  }

  Future<void> _editarCliente(BuildContext context, Cliente cliente) async {
    final resultado = await Navigator.pushNamed(
      context,
      EditClientScreen.routeName,
      arguments: cliente,
    );
    if (resultado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados do cliente atualizados.')),
      );
    }
  }
}
