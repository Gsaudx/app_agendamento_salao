import 'package:app_paula_barros/components/select.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/Input.dart';
import '../components/input_date.dart';
import '../components/input_textarea.dart';
import '../formatters/telefone_input_formatter.dart';

class NewAppointmentScreen extends StatefulWidget {
  const NewAppointmentScreen({super.key});

  static const routeName = '/new-appointment';

  @override
  State<NewAppointmentScreen> createState() => _NewAppointmentScreenState();
}

class _NewAppointmentScreenState extends State<NewAppointmentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 218, 218),
        title: const Text('Novo Agendamento'),
      ),
      body: Column(
        // Removi o mainAxisAlignment: MainAxisAlignment.spaceBetween por não ser mais necessário
        // se o botão for mantido dentro do ListView.
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Select<int>(
                  label: 'Adicionar Cliente: ',
                  placeholder: 'Selecione o cliente',
                  items: [],
                  value: 12,
                ),
                // Campos de Formulário
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
                  inputFormatters: const [TelefoneInputFormatter()],
                ),
                Row(
                  children: [
                    Expanded(
                      child: InputDate(
                        label: 'Data',
                        controller: TextEditingController(),
                        keyboardType: TextInputType.datetime,
                      ),
                    ),
                    Expanded(
                      child: Input(
                        label: 'Valor',
                        controller: TextEditingController(),
                        placeholder: '0,00',
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Select<int>(
                        label: 'Hora Início',
                        placeholder: '00:00',
                        items: [],
                        value: 12,
                      ),
                    ),
                    Expanded(
                      child: Select<int>(
                        label: 'Hora Fim',
                        placeholder: '00:00',
                        items: [],
                        value: 12,
                      ),
                    ),
                  ],
                ),
                Textarea(
                  label: 'Observações',
                  controller: TextEditingController(),
                  maxLines: 6,
                ),

                // Botão de Ação
                const SizedBox(height: 20),
                Button(
                  color: const Color(0xFFCF7072),
                  label: 'Agendar',
                  onPressed: () {}, // Uso da função de salvar
                ),
                const SizedBox(height: 20), // Espaço adicional no fim da lista
              ],
            ),
          ),
        ],
      ),
    );
  }
}
