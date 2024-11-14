import 'dart:convert';
import 'package:calculadora_nota/dao/tarefa_dao.dart';
import 'package:calculadora_nota/model/tarefa_model.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TarefaPresenter {
  final TarefaDao db;

  TarefaPresenter(this.db);

    double calcularNotaFinal(List<Tarefa> tarefas) {
    double somaPonderada = 0;
    double somaPesos = 0;
    double notaProva = 10;

    for (var tarefa in tarefas) {
      somaPonderada += (tarefa.nota! / 10) * 3 * tarefa.peso;
      somaPesos += tarefa.peso;
    }

    double mediaPonderadaConvertida = somaPonderada / somaPesos;

    double notaFinal = mediaPonderadaConvertida + (notaProva / 10) * 7;

    return notaFinal;
  }

  Future<void> salvaCalculo(double notaFinal) async {
    DateTime dataAtual = DateTime.now();

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
