import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:calculadora_nota/model/tarefa_model.dart';

class TarefaCRUDPresenter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionName = 'tarefas';

  Future<List<Tarefa>> getTarefas(String filtro) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(collectionName)
          .where('titulo', isGreaterThanOrEqualTo: filtro.isEmpty ? '' : filtro)
          .get();
      return snapshot.docs
          .map((doc) => Tarefa.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> addTarefa(Tarefa tarefa) async {
    try {
      print(tarefa.toJson());
      await _firestore.collection(collectionName).add(tarefa.toJson());
      print('Tarefa adicionada com sucesso!');
    } catch (e, stack) {
      print(e);
      print(stack);
    }
  }

  Future<void> updateTarefa(Tarefa tarefa, String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).update(tarefa.toJson());
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> deleteTarefa(String docId) async {
    try {
      await _firestore.collection(collectionName).doc(docId).delete();
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
