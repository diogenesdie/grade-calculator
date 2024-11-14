import 'package:flutter/material.dart';
import 'package:calculadora_nota/model/tarefa_model.dart';
import 'package:calculadora_nota/presenter/tarefa_crud_presenter.dart';

class TarefaCRUDView extends StatefulWidget {
  final TarefaCRUDPresenter presenter;

  TarefaCRUDView({required this.presenter});

  @override
  _TarefaCRUDViewState createState() => _TarefaCRUDViewState();
}

class _TarefaCRUDViewState extends State<TarefaCRUDView> {
  List<Map<String, dynamic>> _tarefas = [];
  String _filtro = '';

  final _tituloController = TextEditingController();
  final _tipoController = TextEditingController();
  final _pesoController = TextEditingController();
  final _periodoController = TextEditingController();

  String? _docIdEditando;

  @override
  void initState() {
    super.initState();
    _carregarTarefas();
  }

  void _carregarTarefas() async {
    List<Tarefa> tarefas = await widget.presenter.getTarefas(_filtro);
    setState(() {
      _tarefas = tarefas.map((tarefa) => {
            'docId': tarefa.id,
            'tarefa': tarefa,
          }).toList();
    });
  }

  void _salvarTarefa() async {
    final titulo = _tituloController.text;
    final tipo = _tipoController.text;
    final peso = double.tryParse(_pesoController.text) ?? 1.0;
    final periodo = _periodoController.text;

    if (_docIdEditando == null) {
      Tarefa novaTarefa = Tarefa(
        id: '',
        titulo: titulo,
        tipo: tipo,
        peso: peso,
        periodo: periodo,
      );
      await widget.presenter.addTarefa(novaTarefa);
    } else {
      Tarefa tarefaAtualizada = Tarefa(
        id: _docIdEditando!,
        titulo: titulo,
        tipo: tipo,
        peso: peso,
        periodo: periodo,
      );
      await widget.presenter.updateTarefa(tarefaAtualizada, _docIdEditando!);
    }

    _tituloController.clear();
    _tipoController.clear();
    _pesoController.clear();
    _periodoController.clear();
    _docIdEditando = null;

    _carregarTarefas();
  }

  void _editarTarefa(Tarefa tarefa) {
    setState(() {
      _docIdEditando = tarefa.id;
      _tituloController.text = tarefa.titulo;
      _tipoController.text = tarefa.tipo;
      _pesoController.text = tarefa.peso.toString();
      _periodoController.text = tarefa.periodo;
    });
  }

  void _deletarTarefa(String docId) async {
    await widget.presenter.deleteTarefa(docId);
    _carregarTarefas();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _tipoController.dispose();
    _pesoController.dispose();
    _periodoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRUD de Tarefas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: _tituloController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _tipoController,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _pesoController,
                  decoration: const InputDecoration(
                    labelText: 'Peso',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _periodoController,
                  decoration: const InputDecoration(
                    labelText: 'Período',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _salvarTarefa,
                  child: Text(_docIdEditando == null ? 'Adicionar Tarefa' : 'Salvar Alterações'),
                ),
              ],
            ),
          ),
          const Divider(),

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
          const Divider(),

          Expanded(
            child: ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, index) {
                final tarefaData = _tarefas[index];
                final tarefa = tarefaData['tarefa'] as Tarefa;
                final docId = tarefaData['docId'] as String;

                return ListTile(
                  title: Text(tarefa.titulo),
                  subtitle: Text('Peso: ${tarefa.peso} - Nota: ${tarefa.nota ?? 0.0}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editarTarefa(tarefa),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => _deletarTarefa(docId),
                      ),
                    ],
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
