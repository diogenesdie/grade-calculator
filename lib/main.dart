import 'package:calculadora_nota/dao/tarefa_dao.dart';
import 'package:calculadora_nota/presenter/tarefa_crud_presenter.dart';
import 'package:calculadora_nota/presenter/tarefa_presenter.dart';
import 'package:calculadora_nota/view/tarefa_view.dart';
import 'package:flutter/material.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Inicializa os bindings do Flutter para garantir que o framework esteja pronto
  WidgetsFlutterBinding.ensureInitialized();

  // Obtém a instância única (singleton) de TarefaDao para acesso ao banco de dados
  final tarefaDao = TarefaDao.instance;

  // Cria uma instância de TarefaPresenter para gerenciar a lógica de negócios
  final tarefaPresenter = TarefaPresenter(tarefaDao);
  final crudPresenter = TarefaCRUDPresenter();

  // Inicializa o aplicativo com o presenter de tarefas
  runApp(MyApp(tarefaPresenter: tarefaPresenter, crudPresenter: crudPresenter));
}

class MyApp extends StatelessWidget {
  final TarefaPresenter tarefaPresenter;
  final TarefaCRUDPresenter crudPresenter;

  // Construtor que recebe o presenter de tarefas
  MyApp({required this.tarefaPresenter, required this.crudPresenter});

  @override
  Widget build(BuildContext context) {
    // Define a estrutura do app com MaterialApp e a view inicial
    return MaterialApp(
      title: 'Calculadora de Notas', // Define o título do app
      theme: ThemeData(
        primarySwatch: Colors.blue, // Define o tema principal como azul
      ),
      // Define a tela inicial como TarefaView, passando o presenter
      home: TarefaView(presenter: tarefaPresenter, crudPresenter: crudPresenter),
    );
  }
}
