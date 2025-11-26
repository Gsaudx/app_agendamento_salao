import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Resultado da seleção de foto
class FotoSelecionada {
  FotoSelecionada({
    required this.bytes,
    required this.extensao,
    required this.nome,
  });

  final Uint8List bytes;
  final String extensao;
  final String nome;
}

/// Widget para seleção e exibição de foto de cliente.
class FotoClienteSelector extends StatelessWidget {
  const FotoClienteSelector({
    super.key,
    this.fotoUrl,
    this.fotoSelecionada,
    required this.onFotoSelecionada,
    this.onRemoverFoto,
    this.carregando = false,
    this.radius = 80,
  });

  /// URL da foto atual (do Firebase Storage)
  final String? fotoUrl;

  /// Foto recém-selecionada (antes do upload)
  final FotoSelecionada? fotoSelecionada;

  /// Callback quando uma nova foto é selecionada
  final ValueChanged<FotoSelecionada?> onFotoSelecionada;

  /// Callback para remover a foto
  final VoidCallback? onRemoverFoto;

  /// Se está fazendo upload
  final bool carregando;

  /// Raio do CircleAvatar
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: carregando ? null : () => _mostrarOpcoes(context),
          child: Stack(
            children: [
              _buildAvatar(),
              if (carregando)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.5),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    ),
                  ),
                ),
              if (!carregando)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCF7072),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (!carregando)
          TextButton(
            onPressed: () => _mostrarOpcoes(context),
            child: Text(
              _temFoto ? 'Alterar foto' : 'Adicionar foto',
              style: const TextStyle(
                color: Color(0xFFCF7072),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  bool get _temFoto => fotoSelecionada != null || (fotoUrl?.isNotEmpty ?? false);

  Widget _buildAvatar() {
    // Prioriza foto recém-selecionada
    if (fotoSelecionada != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: MemoryImage(fotoSelecionada!.bytes),
      );
    }

    // Foto salva no Firebase
    if (fotoUrl != null && fotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: NetworkImage(fotoUrl!),
        onBackgroundImageError: (_, __) {},
        child: null,
      );
    }

    // Placeholder
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: radius * 1.2,
        color: Colors.white,
      ),
    );
  }

  void _mostrarOpcoes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Foto do cliente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFFCF7072)),
                title: const Text('Tirar foto'),
                onTap: () {
                  Navigator.pop(ctx);
                  _selecionarFoto(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Color(0xFFCF7072)),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(ctx);
                  _selecionarFoto(context, ImageSource.gallery);
                },
              ),
              if (_temFoto && onRemoverFoto != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remover foto', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(ctx);
                    onRemoverFoto?.call();
                  },
                ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selecionarFoto(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final imagem = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (imagem == null) return;

      final bytes = await imagem.readAsBytes();
      final extensao = imagem.name.split('.').last.toLowerCase();

      onFotoSelecionada(FotoSelecionada(
        bytes: bytes,
        extensao: extensao.isNotEmpty ? extensao : 'jpg',
        nome: imagem.name,
      ));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao selecionar foto: $e')),
        );
      }
    }
  }
}
