import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:jaguar/jaguar.dart';

main() async {
  final server = Jaguar();
  Directory.current = p.dirname(Platform.script.toFilePath());

  server.get('/todos', (Context ctx) => getTodos());
  server.get('/todos/:id', (Context ctx) => getTodo(ctx.pathParams.getInt('id', 0)));
  server.post('/todo', (Context ctx) async {
    var data = await ctx.bodyAsText();
    createTodo(data);
  });
  await server.serve();
}

getTodos() async {
  var file = File('todo.json');
  String content;

  if (file.existsSync()) {
    content = await file.readAsStringSync();
  } else {
    content = '[]';
  }

  if (content.isEmpty) {
    content = '[]';
  }

  return content;
}

getTodo(int id) async {
  var todos = await getTodos();
  List todoList = jsonDecode(todos);
  var todoItem;
  try {
    todoItem = todoList[id];
  } catch (e) {
    todoItem = null;
  }
  return jsonEncode(todoItem);
}

createTodo(String data) async {
  var todos = await getTodos();
  var file = File('todo.json');
  List todoList = jsonDecode(todos);
  todoList.add(jsonDecode(data));
  if (!file.existsSync()) {
    file.createSync();
  }
  file.writeAsStringSync(jsonEncode(todoList));
}