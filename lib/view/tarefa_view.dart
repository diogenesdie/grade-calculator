import 'package:calculadora_nota/model/tarefa_model.dart';
import 'package:calculadora_nota/presenter/tarefa_presenter.dart';
import 'package:flutter/material.dart';

class TarefaView extends StatefulWidget {
  final TarefaPresenter presenter;

  TarefaView({required this.presenter});

  @override
  _TarefasViewState createState() => _TarefasViewState();
}

class _TarefasViewState extends State<TarefaView> {
  late Future<List<Tarefa>> _tarefas;
  List<dynamic> _calculos = [];

  @override
  void initState() {
    super.initState();
    _tarefas = widget.presenter.carregarTarefas();
    _loadCalculos();
  }

  void _loadCalculos() async {
    List<dynamic> calculos =  await widget.presenter.getCalculos();

    setState(() {
      _calculos = calculos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas dos Trabalhos'),
      ),
      body: Column(
        children: [
          // Exibe a lista de tarefas
          Expanded(
            child: FutureBuilder<List<Tarefa>>(
              future: _tarefas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Erro ao carregar tarefas'));
                }

                final tarefas = snapshot.data!;

                return ListView.builder(
                  itemCount: tarefas.length,
                  itemBuilder: (context, index) {
                    final tarefa = tarefas[index];

                    return ListTile(
                      title: Text(tarefa.titulo),
                      subtitle: Text('Peso: ${tarefa.peso}'),
                      trailing: SizedBox(
                        width: 100,
                        child: TextField(
                          decoration: const InputDecoration(labelText: 'Nota'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            tarefa.nota = double.tryParse(value);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(),
          // Exibe a lista de cálculos
          Expanded(
            child: ListView.builder(
              itemCount: _calculos.length,
              itemBuilder: (context, index) {
                final calculo = _calculos[index];

                return ListTile(
                  title: Text('Nota Final: ${calculo['notaFinal']}'),
                  subtitle: Text('Data: ${calculo['data']}'),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.save),
        onPressed: () async {
          try {
            final tarefas = await _tarefas;
            await widget.presenter.salvarTarefas(tarefas);

            double notaFinal = widget.presenter.calcularNotaFinal(tarefas);
            await widget.presenter.salvaCalculo(notaFinal);

            List<dynamic> calculos =  await widget.presenter.getCalculos();

            setState(() {
              _calculos = calculos;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Notas salvas com sucesso')),
            );

          } catch (e, stack) {
            print(e);
            print(stack);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Erro ao salvar notas')),
            );
          }
        },
      ),
    );
  }
}
