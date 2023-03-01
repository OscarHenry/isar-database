import 'dart:async';

import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:isar_database/isar_database.dart';
import 'package:isar_database/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  IsarDataBase.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController = TextEditingController();
  late final IsarDataBase db = IsarDataBase();
  late final StreamSubscription subscription;
  @override
  void initState() {
    subscription = db.userCollection.watchLazy().listen((event) {
      if (mounted) {
        setState(() {});
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Isar DataBase'),
        actions: [
          Center(child: Text('Size ${db.db.getSizeSync()} bytes')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      hintText: 'Name',
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState?.validate() == true) {
                        _formKey.currentState!.save();
                        User user = User(name: nameController.text, age: 28);
                        final index = db.create<User>(user);
                        nameController.clear();
                        if (index != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text('User has been created with id $index'),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Create user Fail'),
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
            FutureBuilder<List<User>>(
              future: db.userCollection.where().findAll(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text(snapshot.error.toString());
                }

                if (snapshot.hasData) {
                  final users = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    primary: false,
                    padding: EdgeInsets.zero,
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users.elementAt(index);
                      return UserItem(
                        user: user,
                        onTap: () {
                          /// update
                          showDialog(
                            context: context,
                            builder: (context) => SimpleDialog(
                              contentPadding: const EdgeInsets.all(24),
                              title: const Text('Update User Data'),
                              children: [
                                Form(
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        initialValue: user.name,
                                        decoration: const InputDecoration(
                                          hintText: 'Name',
                                        ),
                                        onFieldSubmitted: (value) {
                                          user.name = value;
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    db.update<User>(user);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Submit'),
                                ),
                              ],
                            ),
                          );
                        },
                        onTrailingTap: () {
                          /// remove
                          db.delete<User>(user.id!);
                        },
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class UserItem extends StatelessWidget {
  const UserItem({
    Key? key,
    required this.user,
    this.onTap,
    this.onTrailingTap,
  }) : super(key: key);

  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onTrailingTap;
  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Text('${user.id}'),
      title: Text('Name: ${user.name}'),
      subtitle: Text('Age: ${user.age}'),
      trailing: IconButton(
        onPressed: onTrailingTap,
        icon: const Icon(Icons.delete),
      ),
    );
  }
}
