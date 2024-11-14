import 'package:calculadora_nota/model/tarefa_model.dart';
import 'package:calculadora_nota/presenter/tarefa_crud_presenter.dart';
import 'package:calculadora_nota/presenter/tarefa_presenter.dart';
import 'package:flutter/material.dart';
import 'package:calculadora_nota/view/tarefa_crud_view.dart';

class TarefaView extends StatefulWidget {
  final TarefaPresenter presenter;
  final TarefaCRUDPresenter crudPresenter;

  TarefaView({required this.presenter, required this.crudPresenter});

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
    _carregarTarefas();
    _loadCalculos();
  }

  void _loadCalculos() async {
    List<dynamic> calculos = await widget.presenter.getCalculos();

    setState(() {
      _calculos = calculos;
    });
  }

  void _carregarTarefas() async {
    List<Tarefa> tarefas = await widget.crudPresenter.getTarefas(_filtro);

    setState(() {
      _tarefas = tarefas;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas dos Trabalhos'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TarefaCRUDView(presenter: TarefaCRUDPresenter())),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar Tarefa',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _filtro = value;
                });
                _carregarTarefas();
              },
            ),
          ),
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
