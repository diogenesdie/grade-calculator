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
  List<Tarefa> _tarefas = [];
  List<dynamic> _calculos = [];
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _carregarTarefas(insere: true);
    _loadCalculos();
  }

  void _loadCalculos() async {
    List<dynamic> calculos = await widget.presenter.getCalculos();

    setState(() {
      _calculos = calculos;
    });
  }

  void _carregarTarefas({bool insere = false}) async {
    if (insere) {
      await widget.presenter.inserirTarefas();
    }
    List<Tarefa> tarefas = await widget.presenter.carregarTarefas(_filtro);

    setState(() {
      _tarefas = tarefas;
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
          // Barra de busca para filtrar as tarefas
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar Tarefa',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _filtro = value; // Atualiza o valor do filtro
                });
                _carregarTarefas(); // Recarrega a lista com o novo filtro
              },
            ),
          ),
          // Exibe a lista de tarefas filtradas ou todas
          Expanded(
            child: ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                final tarefa = _tarefas[index];

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

            double notaFinal = widget.presenter.calcularNotaFinal(tarefas);
            await widget.presenter.salvaCalculo(notaFinal);

            List<dynamic> calculos = await widget.presenter.getCalculos();

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
