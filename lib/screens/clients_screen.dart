import 'package:flutter/material.dart';

import '../components/app_bar_padrao.dart';
import '../components/dialog_confirmacao.dart';
import '../components/floating_button.dart';
import '../components/floating_menu.dart';
import '../dependencias/dependencias_widget.dart';
import '../formatters/telefone_input_formatter.dart';
import '../modelos/cliente.dart';
import 'editclient_screen.dart';
import 'newclient_screen.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  static const routeName = '/clients';

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _chavesDasSecoes = {};
  String _filtro = '';
  String _letraAtual = '';

  static const _alfabeto = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_atualizarLetraAtual);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_atualizarLetraAtual);
    _scrollController.dispose();
    super.dispose();
  }

  void _atualizarLetraAtual() {
    if (!_scrollController.hasClients) return;

    String novaLetra = '';
    for (final entrada in _chavesDasSecoes.entries) {
      final chave = entrada.value;
      final contexto = chave.currentContext;
      if (contexto != null) {
        final caixa = contexto.findRenderObject() as RenderBox?;
        if (caixa != null && caixa.hasSize) {
          final posicao = caixa.localToGlobal(Offset.zero);
          if (posicao.dy <= 150) {
            novaLetra = entrada.key;
          }
        }
      }
    }
    if (novaLetra.isNotEmpty && novaLetra != _letraAtual) {
      setState(() => _letraAtual = novaLetra);
    }
  }

  void _rolarParaLetra(String letra) {
    final chave = _chavesDasSecoes[letra];
    if (chave?.currentContext != null) {
      Scrollable.ensureVisible(
        chave!.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Map<String, List<Cliente>> _agruparPorLetra(List<Cliente> clientes) {
    final agrupado = <String, List<Cliente>>{};
    for (final cliente in clientes) {
      final letra = cliente.nome.isNotEmpty
          ? cliente.nome[0].toUpperCase()
          : '#';
      agrupado.putIfAbsent(letra, () => []).add(cliente);
    }
    final chaves = agrupado.keys.toList()..sort();
    return {for (final k in chaves) k: agrupado[k]!};
  }

  List<Cliente> _filtrarClientes(List<Cliente> clientes) {
    if (_filtro.isEmpty) return clientes;
    final termo = _filtro.toLowerCase();
    return clientes.where((c) {
      final nome = c.nome.toLowerCase();
      final telefone = c.telefone.toLowerCase();
      return nome.contains(termo) || telefone.contains(termo);
    }).toList();
  }

  void _atualizarChavesDasSecoes(Iterable<String> letras) {
    final letrasAtuais = letras.toSet();
    _chavesDasSecoes.removeWhere((letra, _) => !letrasAtuais.contains(letra));
    for (final letra in letras) {
      _chavesDasSecoes.putIfAbsent(letra, () => GlobalKey());
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientesServico = DependenciasWidget.clientesDe(context);
    return Scaffold(
      appBar: const AppBarPadrao(),
      body: Column(
        children: [
          _buildCampoBusca(),
          Expanded(
            child: StreamBuilder<List<Cliente>>(
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
                final todosClientes = snapshot.data ?? const <Cliente>[];
                if (todosClientes.isEmpty) {
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

                return AnimatedBuilder(
                  animation: _searchController,
                  builder: (context, _) {
                    _filtro = _searchController.text;
                    final clientesFiltrados = _filtrarClientes(todosClientes);
                    final agrupados = _agruparPorLetra(clientesFiltrados);
                    
                    _atualizarChavesDasSecoes(agrupados.keys);

                    if (clientesFiltrados.isEmpty) {
                      return const Center(
                        child: Text('Nenhum cliente encontrado.'),
                      );
                    }

                    return Stack(
                      children: [
                        _buildListaClientes(agrupados),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: _buildIndiceAlfabetico(agrupados.keys.toSet()),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FloatingMenu(
        currentRoute: ClientsScreen.routeName,
      ),
      floatingActionButton: FloatingButton(
        label: 'Novo Cliente',
        onPressed: () => _abrirCadastroCliente(context),
      ),
    );
  }

  Widget _buildCampoBusca() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: AnimatedBuilder(
        animation: _searchController,
        builder: (context, _) {
          return TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por Cliente...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListaClientes(Map<String, List<Cliente>> agrupados) {
    final secoes = <Widget>[];
    
    for (final entrada in agrupados.entries) {
      final letra = entrada.key;
      final clientes = entrada.value;
      
      secoes.add(
        Container(
          key: _chavesDasSecoes[letra],
          width: double.infinity,
          color: Colors.grey[200],
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            letra,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
      
      for (final cliente in clientes) {
        secoes.add(_buildItemCliente(cliente));
      }
    }

    return ListView(
      controller: _scrollController,
      children: secoes,
    );
  }

  Widget _buildItemCliente(Cliente cliente) {
    return Dismissible(
      key: Key(cliente.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _confirmarExclusaoCliente(context, cliente);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        color: Colors.red,
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
          size: 28,
        ),
      ),
      child: InkWell(
        onTap: () => _editarCliente(context, cliente),
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              _buildFotoCliente(cliente),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cliente.nome,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (cliente.telefone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Telefone: ${TelefoneInputFormatter.formatValue(cliente.telefone)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndiceAlfabetico(Set<String> letrasDisponiveis) {
    return SizedBox(
      width: 24,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final alturaDisponivel = constraints.maxHeight;
          final alturaItem = alturaDisponivel / _alfabeto.length;
          
          return GestureDetector(
            onVerticalDragUpdate: (detalhes) {
              final indice = (detalhes.localPosition.dy / alturaItem)
                  .clamp(0, _alfabeto.length - 1)
                  .toInt();
              final letra = _alfabeto[indice];
              if (letrasDisponiveis.contains(letra)) {
                _rolarParaLetra(letra);
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _alfabeto.map((letra) {
                final disponivel = letrasDisponiveis.contains(letra);
                final selecionada = letra == _letraAtual;
                
                return Expanded(
                  child: GestureDetector(
                    onTap: disponivel ? () => _rolarParaLetra(letra) : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      alignment: Alignment.center,
                      decoration: selecionada
                          ? BoxDecoration(
                              color: const Color(0xFFCF7072),
                              borderRadius: BorderRadius.circular(10),
                            )
                          : null,
                      child: Text(
                        letra,
                        style: TextStyle(
                          fontSize: selecionada ? 12 : 10,
                          fontWeight: selecionada ? FontWeight.bold : FontWeight.normal,
                          color: selecionada
                              ? Colors.white
                              : disponivel
                                  ? Colors.grey[700]
                                  : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFotoCliente(Cliente cliente) {
    if (cliente.fotoUrl != null && cliente.fotoUrl!.isNotEmpty) {
      return ClipOval(
        child: SizedBox(
          width: 48,
          height: 48,
          child: Image.network(
            cliente.fotoUrl!,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: const Color(0xFFFEC8C8),
                child: const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFFCF7072),
                    ),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return _buildAvatarPadrao(cliente);
            },
          ),
        ),
      );
    }
    return _buildAvatarPadrao(cliente);
  }

  Widget _buildAvatarPadrao(Cliente cliente) {
    return CircleAvatar(
      radius: 24,
      backgroundColor: const Color(0xFFFEC8C8),
      child: Text(
        cliente.nome.isNotEmpty
            ? cliente.nome.substring(0, 1).toUpperCase()
            : '?',
        style: const TextStyle(
          color: Color(0xFFCF7072),
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
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

  Future<void> _confirmarExclusaoCliente(BuildContext context, Cliente cliente) async {
    final clientesServico = DependenciasWidget.clientesDe(context);
    
    final quantidadeAgendamentos = await clientesServico.contarAgendamentosDoCliente(cliente.id);
    
    if (quantidadeAgendamentos > 0) {
      if (!context.mounted) return;
      await DialogConfirmacao.mostrar(
        context: context,
        titulo: 'Não é possível excluir',
        mensagem: 'O cliente "${cliente.nome}" possui $quantidadeAgendamentos '
            '${quantidadeAgendamentos == 1 ? 'agendamento cadastrado' : 'agendamentos cadastrados'}.\n\n'
            'Cancele os agendamentos antes de excluir o cliente.',
        tipo: TipoDialogo.alerta,
        mostrarBotaoCancelar: false,
      );
      return;
    }

    if (!context.mounted) return;
    final confirmado = await DialogConfirmacao.mostrar(
      context: context,
      titulo: 'Excluir cliente',
      mensagem: 'Deseja realmente excluir o cliente "${cliente.nome}"?\n\nEssa ação não pode ser desfeita.',
      tipo: TipoDialogo.confirmacao,
      textoBotaoConfirmar: 'Excluir',
    );

    if (confirmado && context.mounted) {
      await clientesServico.excluirCliente(cliente.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cliente excluído com sucesso.')),
        );
      }
    }
  }
}
