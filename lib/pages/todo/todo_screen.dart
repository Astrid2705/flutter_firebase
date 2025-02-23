import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:firebase1/pages/login/login.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  TodoScreenState createState() => TodoScreenState();
}

class TodoScreenState extends State<TodoScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _tasks = []; //  Tambahkan final
  String _selectedCategory = 'Umum'; 
  final List<String> _categories = ['Umum', 'Kuliah', 'Kerja', 'Pribadi'];

  String _selectedFilter = 'Semua';
  DateTime? _selectedTime;
  bool _isDarkMode = false;

  ///  **Menambahkan Tugas**
  void _addTask() {
    if (_controller.text.isNotEmpty) {
      setState(() {
        _tasks.add({
          'task': _controller.text,
          'category': _selectedCategory,
          'isDone': false,
        });
        _controller.clear();
      });
    }
  }

  ///  **Menghapus Tugas**
  void _removeTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
  }

  ///  **Menandai Tugas Selesai**
  void _toggleTaskStatus(int index) {
    setState(() {
      _tasks[index]['isDone'] = !_tasks[index]['isDone'];
    });
  }

  ///  **Mengatur Pengingat**
  Future<void> _pickTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null && mounted) { //  Periksa mounted sebelum menggunakan context
      setState(() {
        _selectedTime = DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Pengingat diatur untuk ${pickedTime.format(context)}")),
      );
    }
  }

  ///  **Fungsi Logout**
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    
    if (mounted) { //  Periksa mounted sebelum menggunakan context
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const Login()), 
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ///  **Filter Tugas Berdasarkan Kategori**
    final filteredTasks = _selectedFilter == 'Semua'
        ? _tasks
        : _tasks.where((task) => task['category'] == _selectedFilter).toList();

    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List Animated'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.dark_mode : Icons.light_mode),
              onPressed: () {
                setState(() {
                  _isDarkMode = !_isDarkMode;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ///  **Input Tugas**
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Tambahkan tugas',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              ///  **Dropdown Pilihan Kategori**
              DropdownButtonFormField(
                value: _selectedCategory,
                items: _categories.map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Pilih Kategori',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),

              ///  **Tombol Tambah Tugas**
              ElevatedButton(
                onPressed: _addTask,
                child: const Text('Tambah'),
              ),
              const SizedBox(height: 10),

              ///  **Tombol Atur Pengingat**
              ElevatedButton(
                onPressed: _pickTime,
                child: const Text('Atur Pengingat'),
              ),
              const SizedBox(height: 10),

              ///  **Menampilkan Waktu Pengingat**
              _selectedTime == null
                  ? const Text("Pengingat belum diatur")
                  : Text("Pengingat: ${_selectedTime!.hour}:${_selectedTime!.minute}"),
              const SizedBox(height: 10),

              ///  **Dropdown Filter Kategori**
              DropdownButton<String>(
                value: _selectedFilter,
                items: ['Semua', ..._categories].map((String category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                },
              ),
              const SizedBox(height: 10),

              ///  **Daftar Tugas dengan Animasi**
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: Card(
                              margin: const EdgeInsets.symmetric(vertical: 5),
                              child: ListTile(
                                leading: Checkbox(
                                  value: filteredTasks[index]['isDone'],
                                  onChanged: (bool? newValue) {
                                    _toggleTaskStatus(
                                        _tasks.indexOf(filteredTasks[index]));
                                  },
                                ),
                                title: Text(
                                  filteredTasks[index]['task'],
                                  style: TextStyle(
                                    decoration: filteredTasks[index]['isDone']
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                subtitle:
                                    Text("Kategori: ${filteredTasks[index]['category']}"),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _removeTask(
                                      _tasks.indexOf(filteredTasks[index])),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
