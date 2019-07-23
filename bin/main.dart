import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:jaguar/jaguar.dart';

main() async {
  final server = Jaguar();
  Directory.current = p.dirname(Platform.script.toFilePath());

  server.get('/todos', (Context ctx) => readTodos());
  server.get(
      '/todos/:id', (Context ctx) => getTodo(ctx.pathParams.getInt('id', 0)));
  server.post('/todo', (Context ctx) async {
    var data = await ctx.bodyAsText();
    return createTodo(data);
  });
  server.put('/todo/:id', (Context ctx) async {
    var data = await ctx.bodyAsText();
    return modifyTodo(data, ctx.pathParams.getInt('id', -1));
  });
  server.delete(
      'todo/:id', (Context ctx) => deleteTodo(ctx.pathParams.getInt('id', -1)));
  await server.serve();
}

readTodos() async {
  var file = File('todo.json');
  String content;
  bool noFile = false;

  if (file.existsSync()) {
    content = await file.readAsStringSync();
  } else {
    file.createSync();
    noFile = true;
  }

  if (content.isEmpty || noFile) {
    content = '[]';
    file.writeAsStringSync(content);
  }

  return content;
}

writeTodos(List todoList) {
  var file = File('todo.json');

  if (!file.existsSync()) {
    file.createSync();
  }
  file.writeAsStringSync(jsonEncode(todoList));
}

getTodoList() async {
  var todos = await readTodos();
  return jsonDecode(todos);
}

getTodo(int id) async {
  var todoList = await getTodoList();
  var todoItem;
  try {
    todoItem = todoList[id];
  } catch (e) {
    todoItem = null;
  }
  return jsonEncode(todoItem);
}

createTodo(String data) async {
  List todoList = await getTodoList();
  String result;
  try {
    todoList.add(jsonDecode(data));
    writeTodos(todoList);
    result = 'success';
  } catch (e) {
    result = 'error';
  }
  return jsonEncode({'result': result});
}

modifyTodo(String data, int id) async {
  List todoList = await getTodoList();
  String result;
  try {
    todoList[id] = jsonDecode(data);
    writeTodos(todoList);
    result = 'success';
  } catch (e) {
    result = 'error';
  }
  return jsonEncode({'result': result});
}

deleteTodo(int id) async {
  List todoList = await getTodoList();
  String result;
  try {
    todoList.removeAt(id);
    writeTodos(todoList);
    result = 'success';
  } catch (e) {
    result = 'error';
  }
  return jsonEncode({'result': result});
}
