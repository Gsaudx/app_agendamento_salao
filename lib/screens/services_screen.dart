import 'package:app_paula_barros/components/floating_button.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../components/app_bar_padrao.dart';
import '../components/floating_menu.dart';
import '../modelos/servico.dart';
import '../dependencias/dependencias_widget.dart';
import 'editservice_screen.dart';
import 'newservice_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  static const routeName = '/services';

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final Map<String, GlobalKey> _chavesDasSecoes = {};
  final _letraAtualNotifier = ValueNotifier<String>('');

  static const _alfabeto = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M',
    'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  static const _iconesSalao = <IconData>[
    Icons.content_cut,
    Icons.dry_cleaning,
    Icons.face_retouching_natural,
    Icons.brush,
    Icons.spa,
    Icons.auto_fix_high,
    Icons.palette,
    Icons.wash,
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
    _letraAtualNotifier.dispose();
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
    if (novaLetra.isNotEmpty && novaLetra != _letraAtualNotifier.value) {
      _letraAtualNotifier.value = novaLetra;
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

  Map<String, List<Servico>> _agruparPorLetra(List<Servico> servicos) {
    final agrupado = <String, List<Servico>>{};
    for (final servico in servicos) {
      final letra = servico.nome.isNotEmpty
          ? servico.nome[0].toUpperCase()
          : '#';
      agrupado.putIfAbsent(letra, () => []).add(servico);
    }
    final chaves = agrupado.keys.toList()..sort();
    return {for (final k in chaves) k: agrupado[k]!};
  }

  void _atualizarChavesDasSecoes(Iterable<String> letras) {
    final letrasAtuais = letras.toSet();
    _chavesDasSecoes.removeWhere((letra, _) => !letrasAtuais.contains(letra));
    for (final letra in letras) {
      _chavesDasSecoes.putIfAbsent(letra, () => GlobalKey());
    }
  }

  List<Servico> _filtrarServicos(List<Servico> servicos, String filtro) {
    if (filtro.isEmpty) return servicos;
    final termo = filtro.toLowerCase();
    return servicos.where((s) => s.nome.toLowerCase().contains(termo)).toList();
  }

  IconData _obterIconeParaServico(Servico servico) {
    final hash = servico.id.hashCode.abs();
    return _iconesSalao[hash % _iconesSalao.length];
  }

  Future<void> _abrirCadastroServico(BuildContext context) async {
    final resultado = await Navigator.pushNamed(
      context,
      NewServiceScreen.routeName,
    );
    if (resultado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço cadastrado com sucesso.')),
      );
    }
  }

  Future<void> _editarServico(BuildContext context, Servico servico) async {
    final resultado = await Navigator.pushNamed(
      context,
      EditServiceScreen.routeName,
      arguments: servico,
    );
    if (resultado == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço atualizado com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicosServico = DependenciasWidget.servicosDe(context);

    return Scaffold(
      appBar: const AppBarPadrao(),
      body: StreamBuilder<List<Servico>>(
        stream: servicosServico.observarServicos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro ao carregar serviços:\n${snapshot.error}'),
              ),
            );
          }
          final todoServicos = snapshot.data ?? const <Servico>[];
          if (todoServicos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nenhum serviço cadastrado ainda.\nAdicione o primeiro usando o botão abaixo.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return AnimatedBuilder(
            animation: _searchController,
            builder: (context, _) {
              final filtro = _searchController.text;
              final servicos = _filtrarServicos(todoServicos, filtro);

              if (servicos.isEmpty) {
                return Column(
                  children: [
                    _buildBarraPesquisa(),
                    const Expanded(
                      child: Center(
                        child: Text('Nenhum serviço encontrado.'),
                      ),
                    ),
                  ],
                );
              }

              final agrupados = _agruparPorLetra(servicos);
              _atualizarChavesDasSecoes(agrupados.keys);

              return Column(
                children: [
                  _buildBarraPesquisa(),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildListaServicos(agrupados),
                        Positioned(
                          right: 0,
                          top: 0,
                          bottom: 0,
                          child: _buildIndiceAlfabetico(agrupados.keys.toSet()),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
      bottomNavigationBar: const FloatingMenu(currentRoute: ServicesScreen.routeName),
      floatingActionButton: FloatingButton(
        label: 'Novo Serviço',
        onPressed: () => _abrirCadastroServico(context),
      ),
    );
  }

  Widget _buildBarraPesquisa() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 40, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar serviço...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFCF7072)),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildListaServicos(Map<String, List<Servico>> agrupados) {
    final secoes = <Widget>[];

    for (final entrada in agrupados.entries) {
      final letra = entrada.key;
      final servicos = entrada.value;

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

      for (final servico in servicos) {
        secoes.add(_buildItemServico(context, servico));
      }
    }

    return ListView(
      controller: _scrollController,
      children: secoes,
    );
  }

  Widget _buildItemServico(BuildContext context, Servico servico) {
    final formatadorMoeda = NumberFormat.simpleCurrency(locale: 'pt_BR');
    final precoFormatado = formatadorMoeda.format(servico.preco);
    final icone = _obterIconeParaServico(servico);

    return InkWell(
      onTap: () => _editarServico(context, servico),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[100]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFEC8C8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icone,
                color: const Color(0xFFCF7072),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    servico.nome,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        servico.duracaoFormatada,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (servico.descricao?.isNotEmpty == true) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            servico.descricao!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[500],
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              precoFormatado,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFFCF7072),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
            ),
          ],
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
            child: ValueListenableBuilder<String>(
              valueListenable: _letraAtualNotifier,
              builder: (context, letraAtual, _) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _alfabeto.map((letra) {
                    final disponivel = letrasDisponiveis.contains(letra);
                    final selecionada = letra == letraAtual;

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
                );
              },
            ),
          );
        },
      ),
    );
  }
}
