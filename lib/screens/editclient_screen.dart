import 'package:app_paula_barros/components/button.dart';
import 'package:app_paula_barros/components/input_date.dart';
import 'package:app_paula_barros/components/input_textarea.dart';
import 'package:flutter/material.dart';
import 'package:app_paula_barros/components/input.dart';

class EditClientScreen extends StatelessWidget {
  const EditClientScreen({super.key});

  static const routeName = '/edit-client';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Cliente')),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            // TODO: abrir seletor de imagem
                          },
                          child: CircleAvatar(
                            radius: 120, // maior tamanho
                            backgroundColor: Colors.grey[300],
                            child: const Icon(
                              Icons.person,
                              size: 200, // ajusta o ícone ao novo raio
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            // TODO: abrir seletor de imagem
                          },
                          child: const Text('Adicionar foto'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Input(
                  label: 'Nome',
                  controller: TextEditingController(),
                  placeholder: 'Digite o nome da cliente',
                ),
                Input(
                  label: 'Telefone',
                  controller: TextEditingController(),
                  keyboardType: TextInputType.phone,
                  placeholder: '(11) 99999-9999',
                ),
                InputDate(
                  label: 'Data de Nascimento',
                  controller: TextEditingController(),
                  keyboardType: TextInputType.phone,
                ),
                Input(
                  label: 'Email',
                  controller: TextEditingController(),
                  keyboardType: TextInputType.emailAddress,
                  placeholder: 'email@exemplo.com',
                ),
                Textarea(
                  label: 'Anotações',
                  controller: TextEditingController(),
                  maxLines: 6,
                ),
                const SizedBox(height: 20),
                Button(label: 'Salvar Cliente', onPressed: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
