// Importação do modelo de tarefa, que define como as tarefas serão representadas
import 'package:calculadora_nota/model/tarefa_model.dart';
// Importação do pacote sqflite para manipulação de banco de dados SQLite
import 'package:sqflite/sqflite.dart';
// Importação do pacote path para trabalhar com caminhos de arquivos
import 'package:path/path.dart';

// Definição da classe TarefaDao, que é responsável por acessar e manipular o banco de dados das tarefas
class TarefaDao {
  // Singleton da classe TarefaDao, garantindo que apenas uma instância exista
  static final TarefaDao instance = TarefaDao._init();

  // Variável que armazenará a instância do banco de dados SQLite
  static Database? _database;

  // Construtor privado da classe (padrão singleton)
  TarefaDao._init();

  // Getter que retorna a instância do banco de dados, ou a inicializa caso ainda não esteja criado
  Future<Database> get database async {
    if (_database != null) return _database!; // Se já existir um banco, retorna-o
    _database = await _initDB('tarefas.db'); // Caso contrário, inicializa o banco de dados
    return _database!;
  }

  // Função para inicializar o banco de dados
  Future<Database> _initDB(String filePath) async {
    // Obtém o caminho do diretório onde o banco de dados será salvo
    final dbPath = await getDatabasesPath();
    // Cria o caminho completo combinando o diretório com o nome do arquivo do banco
    final path = join(dbPath, filePath);

    // Abre o banco de dados, criando-o se ainda não existir
    return await openDatabase(path, version: 1, onCreate: _createDB // Define a função que criará as tabelas na primeira execução
        );
  }

  // Função responsável por criar a tabela 'tarefas' no banco de dados
  Future _createDB(Database db, int version) async {
    // Comando SQL para criar a tabela 'tarefas' com suas colunas e tipos de dados
    await db.execute('''
      CREATE TABLE tarefas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,  
        tipo TEXT,                             
        titulo TEXT,                           
        periodo TEXT,                          
        peso REAL,                             
        nota REAL,                             
        timestamp TEXT                         
      )
    ''');
  }

  // Função para inserir uma nova tarefa no banco de dados
  Future<void> inserirTarefa(Tarefa tarefa) async {
    // Obtém a instância do banco de dados
    final db = await instance.database;
    // Insere a tarefa convertida em JSON na tabela 'tarefas'
    await db.insert('tarefas', tarefa.toJson());
  }

  // Função para listar todas as tarefas armazenadas no banco de dados
  Future<List<Tarefa>> listarTarefas(String filter) async {
    // Obtém a instância do banco de dados
    final db = await instance.database;

    // Se a string de busca não for nula ou vazia, aplica o filtro no SQL
    final result = await db.query(
      'tarefas',
      where: filter != null && filter.isNotEmpty ? 'titulo LIKE ?' : null,
      whereArgs: filter != null && filter.isNotEmpty ? ['%$filter%'] : null,
    );

    // Converte cada registro em um objeto Tarefa e retorna a lista de tarefas
    return result.map((json) => Tarefa.fromJson(json)).toList();
  }
}
