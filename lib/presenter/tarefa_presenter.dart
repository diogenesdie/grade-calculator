import 'dart:convert';
import 'package:calculadora_nota/dao/tarefa_dao.dart';
import 'package:calculadora_nota/model/tarefa_model.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TarefaPresenter {
  final TarefaDao db;

  TarefaPresenter(this.db);

  // Carregar JSON trasnformando em uma lista de tarefas
  Future<List<Tarefa>> carregarTarefas() async {
    final jsonString = await rootBundle.loadString('assets/notas.json');
    final List<dynamic> jsonData = json.decode(jsonString);
    return jsonData.map((item) => Tarefa.fromJson(item)).toList();
  }

  // Calcular a nota final
  double calcularNotaFinal(List<Tarefa> tarefas) {
    double somaPonderada = 0;
    double somaPesos = 0;
    double notaProva = 10;

    // Cálculo da Média Ponderada Convertida
    for (var tarefa in tarefas) {
      somaPonderada += (tarefa.nota! / 10) * 3 * tarefa.peso;
      somaPesos += tarefa.peso;
    }

    double mediaPonderadaConvertida = somaPonderada / somaPesos;

    // Cálculo da Nota Final
    double notaFinal = mediaPonderadaConvertida + (notaProva / 10) * 7;

    return notaFinal;
  }

  // Salvar notas no banco
  Future<void> salvarTarefas(List<Tarefa> tarefas) async {
    for (var tarefa in tarefas) {
      tarefa.timestamp = DateTime.now();
      await db.inserirTarefa(tarefa);
    }
  }

  Future<void> salvaCalculo(double notaFinal) async {
    DateTime dataAtual = DateTime.now();

    //save on shared preferences as a json list of all calculated notes
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> notas = prefs.getStringList('notas') ?? [];
    notas.add(
      '{"notaFinal": $notaFinal, "data": "${dataAtual.toString()}"}',
    );
    prefs.setStringList('notas', notas);
  }

  Future<List<dynamic>> getCalculos() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> notas = prefs.getStringList('notas') ?? [];

    List<Map<String, dynamic>> calculos = [];

    for (var nota in notas) {
      calculos.add(json.decode(nota));
    }

    print(calculos);

    return calculos;
  }
}
