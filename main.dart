import 'package:flutter/material.dart';

void main() {
  runApp(RebenziaTasksApp());
}

class TaskModel {
  String title;
  String description;
  DateTime dueDate;
  bool isComplete;
  String priority;

  TaskModel({
    required this.title,
    required this.description,
    required this.dueDate,
    this.isComplete = false,
    this.priority = 'Medium',
  });
}

class RebenziaTasksApp extends StatefulWidget {
  @override
  State<RebenziaTasksApp> createState() => _RebenziaTasksAppState();
}

class _RebenziaTasksAppState extends State<RebenziaTasksApp> {
  bool isLoggedIn = false;
  bool isLoading = false;
  final List<TaskModel> tasks = [];
  String searchQuery = "";

  void login() async {
    setState(() => isLoading = true);
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      isLoggedIn = true;
      isLoading = false;
    });
  }

  void addTask(String title, String desc) {
    final task = TaskModel(
      title: title,
      description: desc,
      dueDate: DateTime.now(),
    );
    setState(() => tasks.add(task));
  }

  void deleteTask(TaskModel task) {
    setState(() => tasks.remove(task));
  }

  void toggleStatus(TaskModel task) {
    final index = tasks.indexOf(task);
    tasks[index].isComplete = !tasks[index].isComplete;
    setState(() {});
  }

  void updateSearch(String query) {
    setState(() => searchQuery = query);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rebenzia Tasks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.pinkAccent,
        fontFamily: 'Montserrat',
      ),
      home: isLoggedIn
          ? HomeView(
              tasks: tasks,
              addTask: addTask,
              deleteTask: deleteTask,
              toggleStatus: toggleStatus,
              searchQuery: searchQuery,
              updateSearch: updateSearch,
            )
          : LoginView(login: login, isLoading: isLoading),
    );
  }
}

class LoginView extends StatelessWidget {
  final VoidCallback login;
  final bool isLoading;

  LoginView({required this.login, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(color: Colors.pink)
            : ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('Simulated Login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  foregroundColor: Colors.white,
                ),
                onPressed: login,
              ),
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  final List<TaskModel> tasks;
  final Function(String, String) addTask;
  final Function(TaskModel) deleteTask;
  final Function(TaskModel) toggleStatus;
  final String searchQuery;
  final Function(String) updateSearch;

  HomeView({
    required this.tasks,
    required this.addTask,
    required this.deleteTask,
    required this.toggleStatus,
    required this.searchQuery,
    required this.updateSearch,
  });

  @override
  Widget build(BuildContext context) {
    final filteredTasks = searchQuery.isEmpty
        ? tasks
        : tasks.where((task) {
            final matches =
                task.title.toLowerCase().contains(searchQuery.toLowerCase());
            return task.isComplete && matches;
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Rebenzia's Tasks"),
        backgroundColor: Colors.pinkAccent,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        color: Colors.pink,
        onRefresh: () async => await Future.delayed(Duration(seconds: 1)),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Search completed tasks...",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.pink),
                  ),
                ),
                onChanged: updateSearch,
              ),
            ),
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                      child: Text(
                        "No matching completed tasks.",
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = filteredTasks[index];
                        return Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) async {
                            if (task.isComplete) return true;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text("Complete task before deleting"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return false;
                          },
                          onDismissed: (_) => deleteTask(task),
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.pink.shade300,
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                          child: Card(
                            margin: EdgeInsets.all(10),
                            color: task.isComplete
                                ? Colors.pink.shade100
                                : Colors.white,
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(task.title),
                              subtitle: Text(task.description),
                              trailing: IconButton(
                                icon: Icon(
                                  task.isComplete
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: Colors.pink,
                                ),
                                onPressed: () => toggleStatus(task),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.pink,
        child: Icon(Icons.add),
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) => AddTaskSheet(addTask: addTask),
        ),
      ),
    );
  }
}

class AddTaskSheet extends StatefulWidget {
  final Function(String, String) addTask;
  AddTaskSheet({required this.addTask});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final titleController = TextEditingController();
  final descController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Wrap(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: "Task Title"),
            ),
            TextField(
              controller: descController,
              decoration: InputDecoration(labelText: "Description"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.addTask(titleController.text, descController.text);
                titleController.clear();
                descController.clear();
                Navigator.pop(context);
              },
              child: Text("Save"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
            )
          ],
        ),
      ),
    );
  }
}
